if vim.b.hnetxt_project_root then
    vim.wo.statusline = require('hnetxt-nvim.ui.statusline')()
end
