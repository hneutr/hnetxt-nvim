local Project = require("hnetxt-lua.project")
local Path = require("hneutil-nvim.path")

local M = {}

-- function M.file.build(path)
--     local config = vim.fn.json_decode(vim.fn.readfile(path))

--     config['root'] = vim.fn.fnamemodify(path, ':h')

--     local mirrors = {}
--     for kind, kind_data in pairs(constants.mirror_defaults) do
--         for mirror, mirror_data in pairs(kind_data.mirrors) do
--             mirror_data = _G.default_args(vim.tbl_get(config, 'mirrors', mirror), mirror_data)
--             mirror_data.kind = kind
--             mirror_data.dir = Path.join(config['root'], kind_data.dir, mirror)

--             if not vim.tbl_get(mirror_data, "disable") then
--                 mirrors[mirror] = mirror_data
--             end
--         end
--     end

--     config['mirrors'] = mirrors

--     return config
-- end

--------------------------------------------------------------------------------
-- config
--------------------------------------------------------------------------------
function M.set(start_path)
    start_path = start_path or Path.current_file()

    if type(start_path) == 'table' then
        start_path = start_path.match
    end

    local project = Project.from_path(path)

    if project then
        vim.b.hnetxt_project_root = project.root
    end
end

-- function M.get()
--     return vim.tbl_get(vim.g.lex_configs or {}, vim.b.lex_config_path) or {}
-- end

function M.push()
    vim.fn.system("cd " .. vim.tbl_get(M.get(), 'root') or '.')
    vim.fn.system("git add .")
    vim.fn.system("git commit -m " .. vim.fn.strftime("%Y%m%d"))
    vim.fn.system("git push")
end



return M
