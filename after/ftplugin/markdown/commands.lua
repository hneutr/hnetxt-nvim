if vim.b.hnetxt_project_root then
    local cmd = vim.api.nvim_buf_create_user_command

    local Path = require("hneutil-nvim.path")
    local Journal = require("hnetxt-lua.journal")
    local Registry = require("hnetxt-lua.project.registry")
    local Goals = require("hnetxt-lua.goals")

    local project = Registry():get_entry_name(vim.b.hnetxt_project_root)

    cmd(0, "Journal", function() Path.open(Journal({project = project})) end, {})
    cmd(0, "Goals", function() Path.open(Goals()) end, {})
end
