local BufferLines = require("hneutil-nvim.buffer_lines")
local Path = require("hneutil-nvim.path")

local Location = require("hnetxt-lua.text.location"):extend()
local Link = require("hnetxt-lua.text.link")
local Mark = require("hnetxt-nvim.text.mark")


function Location.goto(open_command, str)
    if not str then
        local current_line = BufferLines.cursor.get()
        local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
        str = Link.get_nearest(current_line, cursor_col).location
    end

    local location = Location.from_str(str, {relative_to = vim.b.hnetxt_project_root})

    if location.path ~= Path.current_file() then
        Path.open(location.path, open_command)
    end

    if location.label:len() > 0 then
        Mark.goto(location.label)
    end
end


function Location.update(old_location, new_location)
    local old = old_location:gsub('/', '\\/')
    local new = new_location:gsub('/', '\\/')

    local cursor = vim.api.nvim_win_get_cursor(0)

    local cmd = "%s/\\](" .. old .. ")/\\](" .. new .. ")/g"
    pcall(function() vim.cmd(cmd) return end)

    vim.api.nvim_win_set_cursor(0, cursor)
end

return Location
