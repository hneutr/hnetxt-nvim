if vim.b.hnetxt_project_root then
    local fuzzy = require("hnetxt-nvim.ui.fuzzy")
    require("hnetxt-nvim.text.list").Parser():map_toggles(vim.g.mapleader .. "t")

    local args = {silent = true, buffer = true}

    -- fuzzy find stuff
    vim.keymap.set("n", " df", fuzzy.goto, args)
    -- "  is <c-/> (the mapping only works if it's the literal character)
    vim.keymap.set("n", "", fuzzy.put, args)
    vim.keymap.set("i", "", fuzzy.insert, args)
end
