local cmd = vim.api.nvim_buf_create_user_command

local Path = require("hn.path")
local Journal = require("htl.journal")
local Goals = require("htl.goals.set")

cmd(0, "Journal", function() Path.open(Journal(vim.b.hnetxt_project_root)) end, {})
cmd(0, "Aim", function() Path.open(Goals.touch()) end, {})
