local Path = require("hneutil.path")

function Path.current_file()
    return vim.fn.expand('%:p')
end

function Path.open(path, open_command)
    open_command = open_command or "edit"

    if Path.suffix(path):len() > 0 then
        Path.mkdir(Path.parent(path))
    else
        Path.mkdir(path)
    end

    if Path.is_dir(path) then
        -- if it's a directory, open a terminal at that directory
        vim.cmd("silent " .. open_command)
        vim.cmd("silent terminal")

        local term_id = vim.b.terminal_job_id

        vim.cmd("silent call chansend(" .. term_id .. ", 'cd " .. tostring(path) .. "\r')")
        vim.cmd("silent call chansend(" .. term_id .. ", 'clear\r')")
    else
        Path.touch(path)
        vim.cmd("silent " .. open_command .. " " .. tostring(path))
    end
end

return Path
