local Project = require("htl.project")
local Path = require("hn.path")

local M = {}

function M.set(start_path)
    start_path = start_path or Path.current_file()

    if type(start_path) == 'table' then
        start_path = start_path.match
    end

    vim.b.hnetxt_project_root = Project.root_from_path(path)
end

return M
