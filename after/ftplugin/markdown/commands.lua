if vim.b.hnetxt_project_root then
    local cmd = vim.api.nvim_buf_create_user_command

    local Path = require("hn.path")
    local Journal = require("htl.journal")
    local Registry = require("htl.project.registry")
    local Goals = require("htl.goals")

    local project = Registry():get_entry_name(vim.b.hnetxt_project_root)

    cmd(0, "Journal", function() Path.open(Journal({project = project})) end, {})
    cmd(0, "Goals", function() Path.open(Goals()) end, {})
end
