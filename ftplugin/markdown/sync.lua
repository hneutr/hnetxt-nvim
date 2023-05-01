local Sync = require('hnetxt-nvim.project.sync')
vim.b.hnetxt_sync = true

local pattern = "*.md"
local group = vim.api.nvim_create_augroup('hnetxt_sync', {clear = true})

vim.api.nvim_create_autocmd(
    {"BufEnter"},
    {pattern=pattern, group=group, callback=Sync.if_active(Sync.buf_enter)}
)

vim.api.nvim_create_autocmd(
    {'TextChanged', 'InsertLeave'},
    {pattern=pattern, group=group, callback=Sync.if_active(Sync.buf_change)}
)

vim.api.nvim_create_autocmd(
    {'BufLeave', 'VimLeave'},
    {pattern=pattern, group=group, callback=Sync.if_active(Sync.buf_leave)}
)
