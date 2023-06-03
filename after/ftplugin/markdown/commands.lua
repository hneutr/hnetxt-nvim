if vim.b.hnetxt_project_root then
    local cmd = vim.api.nvim_buf_create_user_command

    local Path = require("hn.path")
    local Journal = require("htl.journal")
    local Goals = require("htl.goals")

    cmd(0, "Journal", function() Path.open(Journal(vim.b.hnetxt_project_root)) end, {})
    cmd(0, "Goals", function() Path.open(Goals()) end, {})
end
