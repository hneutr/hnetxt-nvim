local List = require("hl.list")

-- https://github.com/altercation/vim-colors-solarized
local solarized = {
    cterm = {
        black    = 0,
        white    = 7,
        gray     = 10,

        red      = 1,
        orange   = 9,
        yellow   = 3,
        green    = 2,
        blue     = 4,
        cyan     = 6,
        magenta  = 5,
        violet   = 13,

        brblack  = 8,
        brwhite  = 15,

        bryellow = 11,
        brblue   = 12,
        brcyan   = 14,
    },
}

local mocha = require("catppuccin.palettes").get_palette("mocha")
local macchiato = require("catppuccin.palettes").get_palette("macchiato")

-- flamingo = "#f2cdce",

-- maroon = "#eba0ad",
-- mauve = "#cba6f8",

-- red = "#f38ba9",
-- peach = "#fab388",
-- yellow = "#f9e2b0",
-- green = "#a6e3a2",

-- pink = "#f5c2e8",
-- rosewater = "#f5e0dd",

-- sapphire = "#74c7ed",
-- sky = "#89dcec",

-- teal = "#94e2d6",
-- blue = "#89b4fb",
-- lavender = "#b4beff",

-- crust = "#11111c",
-- mantle = "#181826",

-- text = "#cdd6f5",
-- base = "#1e1e2f",

-- subtext0 = "#abadc9",
-- subtext1 = "#bac2df",

-- surface0 = "#313245",
-- surfacel = "#45475b",
-- surface2 = "#585b71",

-- overlay0 = "#6c7087",
-- overlay1 = "#7f849d",
-- overlay2 = "#9399b3",

local M = {}

M.C = macchiato

function M.add_to_syntax(key, args)
    local cmd = List({
        "syn match",
        key,
        "/" .. args.string .. "/",
        "containedin=ALL"
    }):join(" ")

    vim.cmd(cmd)
    M.set_highlight({name = key, val = {fg = args.color}})
end

function M.set_highlight(args)
    args = _G.default_args(args, {namespace = 0, name = '', val = {}})

    local allowed_keys = {
        'fg',
        'bg',
        'sp',
        'bold',
        'standout',
        'underline',
        'undercurl',
        'underdouble',
        'underdotted',
        'underdashed',
        'strikethrough',
        'italic',
        'reverse',
        'link',
    }
    local val = {}

    for _, key in ipairs(allowed_keys) do
        val[key] = args.val[key]
    end

    for _, key in ipairs({'fg', 'bg'}) do
        if val[key] ~= nil then
            val[key] = M.C[table.removekey(val, key)]
            -- val["cterm" .. key] = M.C.cterm[table.removekey(val, key)]
            -- val[key] = M.C.cterm[table.removekey(val, key)]
        end
    end

    if args.name then
        vim.api.nvim_set_hl(args.namespace, args.name, val)
    end
end

return M
