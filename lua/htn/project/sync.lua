------------------------------------- syncing ----------------------------------
-- "syncing" is updating references when makes change
--
-- there are two kinds of reference updates that we want to handle:
-- 1. renames: an existing marker's label changes
-- 2. moves: an existing marker is moved from one file to another
--
-- RENAMES:
-- - we look to see if the existing line contains a marker
-- - if it does, and there was a marker with a different label there prior to the edit
-- - then we consider that a rename
--
-- MOVES:
-- - when a marker is deleted from a file, add it to the "deleted" list
-- - when a marker is added to another file, check to see if it was in the
--   "deleted" list
-- - if so, queue up a "delete move"
-- - if a marker is deleted from a file:
--   - remove it from the "delete move" list
--   - add it back onto the "deleted" list
--------------------------------------------------------------------------------
local BufferLines = require("hn.buffer_lines")
local Path = require("hn.path")

local Location = require("htn.text.location")
local Reference = require("htl.text.reference")
local Mark = require("htl.text.mark")

local M = {}

function M.if_active(fn)
    return function()
        if vim.b.hnetxt_project_root and vim.b.hnetxt_sync then
            fn()
        end
    end
end

function M.buf_enter()
    if not vim.g.deleted_markers then
        vim.g.deleted_markers = {}
    end

    if not vim.g.referenced_markers then
        local referenced_markers = {}
        for i, location in ipairs(Reference.get_referenced_mark_locations(vim.b.hnetxt_project_root)) do
            location = tostring(location)
            if not Path.is_relative_to(location, vim.b.hnetxt_project_root) then
                location = Path.join(vim.b.hnetxt_project_root, location)
            end
            referenced_markers[location] = true
        end
        vim.g.referenced_markers = referenced_markers
    end

    vim.b.markers = M.read_markers() -- format: marker: path
    vim.b.renamed_markers = {} -- format: old_name: new_name
    vim.b.deleted_markers = {}
    vim.b.created_markers = {}
end

function M.read_markers()
    local markers = {}
    for i, str in ipairs(BufferLines.get()) do
        if Mark.str_is_a(str) then
            markers[Mark.from_str(str).label] = i
        end
    end

    return markers
end

--------------------------------------------------------------------------------
-- on change functions
--------------------------------------------------------------------------------
function M.buf_change()
    local new_markers = M.read_markers()
    local old_markers = vim.b.markers
    local renamed_markers = vim.b.renamed_markers

    local deletions = M.get_deletions(old_markers, new_markers)
    local creations = M.get_creations(old_markers, new_markers)

    if M.check_rename(old_markers, new_markers, creations, deletions) then
        vim.b.renamed_markers = M.update_renames(deletions[1], creations[1], vim.b.renamed_markers)
    else
        vim.b.created_markers = M.update_creations(deletions, creations, vim.b.created_markers)
        vim.b.deleted_markers = M.update_deletions(deletions, creations, vim.b.deleted_markers)
    end

    vim.b.markers = new_markers
end

function M.get_deletions(old, new)
    local deletions = {}
    for marker, line in pairs(old) do
        if not vim.tbl_get(new, marker) then
            table.insert(deletions, marker)
        end
    end

    return deletions
end

function M.get_creations(old, new)
    local creations = {}
    for marker, line in pairs(new) do
        if not vim.tbl_get(old, marker) then
            table.insert(creations, marker)
        end
    end

    return creations
end

function M.check_rename(old_markers, new_markers, creations, deletions)
    if vim.tbl_count(creations) == 1 and vim.tbl_count(deletions) == 1 then
        local old_marker, new_marker = deletions[1], creations[1]

        if old_markers[old_marker] == new_markers[new_marker] then
            return true
        end
    end

    return false
end

function M.update_renames(old_marker, new_marker, renames)
    if #old_marker > 0 and #new_marker > 0 then
        Location.update(
            tostring(Location({path = Path.current_file(), label = old_marker})),
            tostring(Location({path = Path.current_file(), label = new_marker}))
        )
    end

    for other_old_marker, other_new_marker in pairs(renames) do
        -- if we're renaming the rename of something else, cut out the middle man
        if old_marker == other_new_marker then
            renames[other_old_marker] = nil
            old_marker = other_old_marker
        end
    end

    if old_marker ~= new_marker then
        renames[old_marker] = new_marker
    end

    return renames
end

function M.update_creations(new_deletions, new_creations, creations)
    for i, marker in ipairs(new_creations) do
        creations[marker] = true
    end

    for i, marker in ipairs(new_deletions) do
        creations[marker] = nil
    end

    return creations
end

function M.update_deletions(new_deletions, new_creations, deletions)
    for i, marker in ipairs(new_deletions) do
        deletions[marker] = true
    end

    for i, marker in ipairs(new_creations) do
        deletions[marker] = nil
    end

    return deletions
end


--------------------------------------------------------------------------------
-- on leave functions
--
--  - TODO: add references in file to `References`?
--  - anything created could be from `g:deleted_markers`
--  - anything deleted should go into `g:deleted_markers`
--  - TODO: use renames to update references
--
-- only run updates if they have references somewhere
-- - take the things from `updates`
--      - check to see if they're in `references`
--          - if so:
--              - remove the old location and insert the new one
--              - run an update
--
-- only add something to g:deleted_markers if it is referenced
-- - look to see if the old location is in references
--      - if so:
--          - remove the old location and insert the new one
--          - add the element to `g:deleted_markers`
--------------------------------------------------------------------------------
function M.buf_leave()
    local creations = vim.b.created_markers
    local deletions = vim.b.deleted_markers
    local renames = vim.b.renamed_markers
    local old_deletions = vim.g.deleted_markers
    local references = vim.g.referenced_markers
    local updates, cupdates = {}, {}

    updates, renames, references = M.process_renames(renames, deletions, creations, references)
    vim.g.updates = updates

    if vim.tbl_count(creations) then
        cupdates, old_deletions, references  = M.process_creations(creations, renames, old_deletions, references)

        for i, update in ipairs(cupdates) do
            table.insert(updates, update)
        end
    end

    if vim.tbl_count(deletions) then
        old_deletions = M.process_deletions(deletions, old_deletions, references)
    end

    vim.g.deleted_markers = old_deletions
    vim.g.referenced_markers = references

    M.process_updates(updates)
    return updates
end


function M.process_renames(renames, deletions, creations, references)
    local updates = {}
    for old, new in pairs(renames) do
        local old_loc = tostring(Location({path = Path.current_file(), label = old}))
        local new_loc = tostring(Location({path = Path.current_file(), label = new}))

        references[new_loc] = vim.tbl_get(references, old_loc)
        references[old_loc] = nil

        if vim.tbl_get(deletions, new) then
            table.removekey(renames, old)
        elseif not vim.tbl_get(creations, old) and vim.tbl_get(references, new_loc) then
            table.insert(updates, {old_location = old_loc, new_location = new_loc})
        end

    end

    -- updates `references` with things referenced in this file
    local referenced_markers = {}
    for i, location in ipairs(Reference.get_referenced_mark_locations(Path.current_file())) do
        referenced_markers[tostring(location)] = true
    end
    references = vim.tbl_extend("keep", references, referenced_markers)

    return updates, renames, references
end


function M.process_creations(creations, renames, old_deletions, references)
    local updates = {}
    for marker, _ in pairs(creations) do
        local old_location = Location({path = Path.current_file(), label = marker})
        local new_location = Location({path = Path.current_file(), label = marker})

        if vim.tbl_get(renames, marker) then
            new_location.label = table.removekey(renames, marker)
        end

        if vim.tbl_get(old_deletions, marker) then
            old_location.path = table.removekey(old_deletions, marker)
        end

        new = tostring(new_location)
        old = tostring(old_location)

        references[new] = vim.tbl_get(references, new) or vim.tbl_get(references, old)
        references[old] = nil

        if vim.tbl_get(references, new) then
            table.insert(updates, { old_location = old, new_location = new })
        end
    end

    return updates, old_deletions, references
end


function M.process_deletions(deletions, old_deletions, references)
    for marker, i in pairs(deletions) do
        local location = Location({path = Path.current_file(), label = marker})
        if vim.tbl_get(references, tostring(location)) then
            old_deletions[marker] = location.path
        end
    end

    return old_deletions
end

function M.process_updates(updates)
    if vim.tbl_count(updates) == 0 then
        return
    end

    local formatted_updates = {}
    for i, update in ipairs(updates) do
        formatted_updates[update.old_location] = update.new_location
    end

    Reference.update_locations(formatted_updates)
end

return M
