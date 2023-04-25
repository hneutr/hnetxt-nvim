local Path = require('hneutil-nvim.path')

function get_path()
    local path = Path.current_file()
    if Path.is_relative_to(path, vim.b.hnetxt_project_root) then
        return Path.relative_to(path, vim.b.hnetxt_project_root)
    else
        return path
    end
end

function get_column_number() return "%c" end

function get_statusline()
    return table.concat({
        get_path(),
        "%=",
        get_column_number(),
    })
end

return get_statusline
