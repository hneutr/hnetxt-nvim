if vim.b.hnetxt_project_root then
    vim.wo.statusline = require('htn.ui.statusline')()
end
