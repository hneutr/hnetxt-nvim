vim.wo.foldenable = true
vim.wo.foldlevel = 2
vim.wo.foldnestmax = 20
vim.wo.foldminlines = 0
vim.wo.fillchars = "fold: "
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'hnetxt_nvim#foldexpr()'
vim.wo.foldtext = "hnetxt_nvim#foldtext()"

local pattern = "*.md"
local group = vim.api.nvim_create_augroup('hnetxt_fold_cmds', {clear = true})
local Fold = require('hnetxt-nvim.ui.fold')

vim.api.nvim_create_autocmd({'TextChanged', 'InsertLeave'}, {
    pattern=pattern,
    group=group,
    callback=Fold.set_fold_levels,
})
