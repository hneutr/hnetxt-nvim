local Project = require("hnetxt-nvim.project")

Project.set()

vim.api.nvim_create_autocmd(
    {"BufEnter"},
    {
        pattern="*.md",
        group=vim.api.nvim_create_augroup('hnetxt_project_set', {clear = true}),
        callback=Project.set
    }
)
