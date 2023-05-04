require("htn.text.list").map_toggles(vim.g.mapleader .. "t")

if vim.b.hnetxt_project_root then
    local Scratch = require("htn.project.scratch")
    local Fuzzy = require("htn.ui.fuzzy")
    local Opener = require("htn.ui.opener")

    local args = {silent = true, buffer = true}

    -- fuzzy
    vim.keymap.set("n", " df", Fuzzy.goto, args)
    -- "  is <c-/> (the mapping only works if it's the literal character)
    vim.keymap.set("n", "", Fuzzy.put, args)
    vim.keymap.set("i", "", Fuzzy.insert, args)

    -- scratch
    vim.keymap.set("n", " s", function() Scratch('n') end, args)
    vim.keymap.set("v", " s", [[:'<,'>lua require('htn.project.scratch')('v')<cr>]], args)

    -- opener
    Opener.map()
end
