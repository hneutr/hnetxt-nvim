local List = require("hnetxt-nvim.text.list")

-- remove list characters when joining lines
vim.keymap.set("n", "J", function() List.Parser():join_lines() end, {silent = true})

-- continue lists
vim.keymap.set("i", "<cr>", [[<cr>]] .. List.Parser.continue_cmd, {silent = true})
vim.keymap.set("n", "o", "o" .. List.Parser.continue_cmd, {silent = true})
