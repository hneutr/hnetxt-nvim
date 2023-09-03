local List = require("hl.list")
local Mirror = require('htn.project.mirror')
local Location = require("htn.text.location")
local Entry = require("htn.text.metadata")

local M = {}

local default_lhs_to_cmd = {e = 'e', o = 'e', l = 'vs', v = 'vs', j = 'sp', s = 'sp'}

local all_mappings = {
    nearest_location = {
        fn = Location.goto,
        lhs_to_cmd = {
            ["<M-l>"] = "vsplit",
            ["<M-j>"] = "split",
            ["<M-e>"] = "edit",
            ["<M-t>"] = "tabedit",
        },
        map_args = {},
    },
    new_entry = {
        lhs_prefix = "<leader>n",
        fn = Entry.open_new,
    },
}

function M.get()
    if not vim.g.ht_opener_mappings then
        M.set()
    end

    return vim.g.ht_opener_mappings
end

function M.set()
    local mappings = List({all_mappings.new_entry})

    if vim.b.hnetxt_project_root then
        mappings:append(all_mappings.nearest_location)
        mappings:extend(Mirror.get_mappings())
    end

    vim.g.ht_opener_mappings = M.format_all(mappings)
end

function M.format_all(raw_mappings)
    local mappings = {}
    for i, raw_mapping in ipairs(raw_mappings) do
        for j, mapping in ipairs(M.format(raw_mapping)) do
            table.insert(mappings, mapping)
        end
    end

    return mappings
end

function M.format(args)
    args = _G.default_args(args, {
        fn = nil,
        lhs_to_cmd = default_lhs_to_cmd,
        lhs_prefix = '',
        map_args = {silent = true, buffer = 0},
    })

    local mappings = {}
    for lhs, cmd in pairs(args.lhs_to_cmd) do
        lhs = args.lhs_prefix .. lhs

        local rhs = function() args.fn(cmd) end
        table.insert(mappings, {lhs = lhs, rhs = rhs, args = args.map_args})
    end

    return mappings
end

function M.map()
    for _, mapping in ipairs(M.get()) do
        vim.keymap.set('n', mapping.lhs, mapping.rhs, mapping.args)
    end
end

return M
