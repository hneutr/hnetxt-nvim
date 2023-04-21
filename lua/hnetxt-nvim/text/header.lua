table = require("hneutil.table")
string = require("hneutil.string")

local Object = require("util.object")
local Config = require("hnetxt-lua.config")
local Color = require("hneutil-nvim.color")

local Divider = require("hnetxt-nvim.text.divider")

local Header = Object:extend()
Header.config = Config.get("header")
Header.default_size = Header.config.default_size
Header.highlight_cmd = [[syn match KEY /^CONTENT_START\s/ contained]]

function Header:new(args)
    self = table.default(self, args or {}, {size = Header.default_size, content = ''})
    self.divider = Divider(self.size)

    for k, v in pairs(self.config.sizes[self.size]) do
        self[k] = v
    end
    self.highlight_key = self.size .. "HeaderStart" 

    self.content_type = type(self.content)
    self.has_input = self.content_type == 'string' and self.content:len() == 0

    if self.content_type == 'string' then
        self.content_value = self.content
    elseif self.content_type == 'function' then
        self.content_value = self.content()
    else
        self.content_value = ''
    end

end

function Header:__tostring()
    local content = self.content_start

    if self.content_value:len() > 0 then
        content = content .. " " .. self.content_value
    end

    lines = {
        tostring(self.divider),
        content,
        tostring(self.divider),
        "",
    }

    return lines
end

function Header:add_syntax_highlighting()
    cmd = self.highlight_cmd:gsub("KEY", self.highlight_key)
    cmd = cmd:gsub("CONTENT_START", self.content_start)
    vim.cmd(cmd)

    Color.set_highlight({name = self.highlight_key, val = {fg = self.divider.color}})
end

function Header.add_syntax_highlights()
    for size, _ in pairs(Header.config.sizes) do
        Header({size = size}):add_syntax_highlighting()
    end
end

function Header:line_is_start(index, lines)
    if #lines < index + 2 then
        return false
    end

    return self:lines_are_a(lines[index], lines[index + 1], lines[index + 2])
end

function Header:line_is_content(index, lines)
    if index - 1 < 1 or #lines < index + 1 then
        return false
    end

    return self:lines_are_a(lines[index - 1], lines[index], lines[index + 1])
end

function Header:line_is_end(index, lines)
    if index - 2 < 1 then
        return false
    end

    return self:lines_are_a(lines[index - 2], lines[index - 1], lines[index])
end

function Header:line_is_a(index, lines)
    if not self:line_is_start(index, lines) then
        if not self:line_is_content(index, lines) then
            if not self:line_is_end(index, lines) then
                return false
            end
        end
    end

    return true
end

function Header:lines_are_a(l1, l2, l3)
    local divider_str = tostring(self.divider)

    if l1 == divider_str then
        if type(l2) == 'string' and l2:startswith(self.content_start) then
            if l3 == divider_str then
                return true
            end
        end
    end
    
    return false
end

function Header.headers_by_size()
    local headers_by_size = {}
    for size, _ in pairs(Header.config.sizes) do
        headers_by_size[size] = Header({size = size})
    end

    return headers_by_size
end

return Header
