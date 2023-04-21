-- lists
vim.b.list_types = {"question", "important", "maybe", "detail", "possibility"}

-- folds
vim.wo.foldenable = true
vim.wo.foldlevel = 2
vim.wo.foldnestmax = 20
vim.wo.fillchars = "fold: "
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'hnetxt_nvim#foldexpr()'
vim.wo.foldtext = "hnetxt_nvim#foldtext()"
