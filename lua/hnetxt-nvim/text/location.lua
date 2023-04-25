local BufferLines = require("hneutil-nvim.buffer_lines")

local Location = require("hnetxt-lua.element.location"):extend()
local Link = require("hnetxt-lua.element.link")
local Mark = require("hnetxt-nvim.text.mark")

local Path = require("hneutil-nvim.path")

function Location:new(args)
    Location.super.new(self, args)
    if self.path:len() == 0 then
        self.path = Path.current_file()
    end
end

function Location:__tostring()
    -- TODO: relativize based on project root
    local str = Location.super.__tostring(self)
    return str
end

function Location.from_str(str)
    -- TODO: relativize based on project root
    local str = Location.super.from_str(str)
    return str
end

function Location.goto(open_command, str)
    if not str then
        local current_line = BufferLines.cursor.get()
        local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
        str = Link.get_nearest(current_line, cursor_col).location
    end

    local location = Location.from_str(str)

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
