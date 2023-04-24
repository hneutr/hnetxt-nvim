local List = require("hnetxt-nvim.text.list")

local args = {silent = true}

-- remove list characters when joining lines
vim.keymap.set("n", "J", function() List.Parser():join_lines() end, args)

-- continue lists
vim.keymap.set("i", "<cr>", [[<cr>]] .. List.Parser.continue_cmd, args)
vim.keymap.set("n", "o", "o" .. List.Parser.continue_cmd, args)
