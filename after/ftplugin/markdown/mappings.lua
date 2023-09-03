require("htn.text.list").map_toggles(vim.g.mapleader .. "t")
require("htn.ui.opener").map()

if vim.b.hnetxt_project_root then
    local Scratch = require("htn.project.scratch")
    local Fuzzy = require("htn.ui.fuzzy")

    local args = {silent = true, buffer = true}

    -- fuzzy
    vim.keymap.set("n", " df", Fuzzy.goto, args)
    vim.keymap.set("n", "<c-/>", Fuzzy.put, args)
    vim.keymap.set("i", "<c-/>", Fuzzy.insert, args)

    -- scratch
    vim.keymap.set("n", " s", function() Scratch('n') end, args)
    vim.keymap.set("v", " s", [[:'<,'>lua require('htn.project.scratch')('v')<cr>]], args)
end
