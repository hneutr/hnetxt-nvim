if vim.b.hnetxt_project_root then
    local cmd = vim.api.nvim_buf_create_user_command

    local Path = require("hneutil-nvim.path")
    local project = require("hnetxt-lua.project").from_path(vim.b.hnetxt_project_root)
    cmd(0, "Journal", function() Path.open(project:get_journal_path()) end, {})
    cmd(0, "Goals", function() Path.open(require('hnetxt-lua.goals').get_path()) end, {})
end
