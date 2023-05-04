local BufferLines = require("hn.buffer_lines")

local Reference = require("htl.text.reference")
local Location = require("htn.text.location")

local fuzzy_actions = {
    ["default"] = "edit",
    ["ctrl-j"] = "split",
    ["ctrl-l"] = "vsplit",
    ["ctrl-t"] = "tabedit",
}

M = { sink = {} }

function M._do(fn)
    local actions = {}
    for key, action in pairs(fuzzy_actions) do
        actions[key] = function(selected) fn(selected[1], action) end
    end

    require('fzf-lua').fzf_exec(Location.get_all_locations(vim.b.hnetxt_project_root), {actions = actions})
end

function M.goto()
    M._do(function(location, action) Location.goto(action, location) end)
end

function M.put()
    M._do(function(location)
        vim.api.nvim_put({tostring(Reference({location = Location.from_str(location)}))} , 'c', 1, 0)
    end)
end

function M.insert()
    M._do(M.insert_selection)
end

function M.insert_selection(location)
    local line = BufferLines.cursor.get()
    local line_number, column = unpack(vim.api.nvim_win_get_cursor(0))

    local insert_command = 'i'

    if column == line:len() - 1 then
        column = column + 1
        insert_command = 'a'
    elseif column == 0 then
        insert_command = 'a'
    end

    local content = tostring(Reference({location = Location.from_str(location)}))

    local new_line = line:sub(1, column) .. content .. line:sub(column + 1)
    local new_column = column + content:len()

    BufferLines.cursor.set({replacement = {new_line}})

    vim.api.nvim_win_set_cursor(0, {line_number, new_column})
    vim.api.nvim_input(insert_command)
end

return M
