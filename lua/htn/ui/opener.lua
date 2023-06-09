local Mirror = require('htn.project.mirror')
local Location = require("htn.text.location")

local M = {}

local default_lhs_to_cmd = {e = 'e', o = 'e', l = 'vs', v = 'vs', j = 'sp', s = 'sp'}

function M.get()
    if not vim.g.lex_opener_mappings then
        M.set()
    end

    return vim.g.lex_opener_mappings
end

function M.set()
    local mappings = {
        {prefix = 'n', fn = function(open_cmd) Location.goto(open_cmd) end},
    }

    for mirror_type, type_config in pairs(Mirror.type_configs) do
        local mirror_keymap_prefix = type_config.keymap_prefix
        if type(mirror_keymap_prefix) == 'string' and #mirror_keymap_prefix > 0 then
            table.insert(mappings, {
                prefix = mirror_keymap_prefix,
                fn = function(open_cmd) Mirror.open(mirror_type, open_cmd) end,
            })
        end
    end

    for i, mapping in ipairs(mappings) do
        mapping.lhs_prefix = vim.b.hnetxt_opener_prefix .. table.removekey(mapping, 'prefix')
    end

    table.insert(mappings, {
        fn = function(open_cmd) Location.goto(open_cmd) end,
        lhs_to_cmd = {
            ["<M-l>"] = "vsplit",
            ["<M-j>"] = "split",
            ["<M-e>"] = "edit",
            ["<M-t>"] = "tabedit",
        },
        map_args = {},
    })

    vim.g.lex_opener_mappings = M.format_all(mappings)
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
        map_args = { silent = true, buffer = 0 },
    })

    local mappings = {}
    for lhs, cmd in pairs(args.lhs_to_cmd) do
        lhs = args.lhs_prefix .. lhs

        local rhs = function() args.fn(cmd) end
        table.insert(mappings, { lhs = lhs, rhs = rhs, args = args.map_args })
    end

    return mappings
end

function M.map()
    for _, mapping in ipairs(M.get()) do
        vim.keymap.set('n', mapping.lhs, mapping.rhs, mapping.args)
    end
end

return M
