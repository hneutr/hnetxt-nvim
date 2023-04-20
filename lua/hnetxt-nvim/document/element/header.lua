table = require("hneutil.table")
string = require("hneutil.string")

local Object = require("util.object")
local Config = require("hnetxt-lua.config")
local Color = require("hneutil-nvim.color")

local Divider = require("hnetxt-nvim.document.element.divider")

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

function Header:set_highlight()
    cmd = self.highlight_cmd:gsub("KEY", self.highlight_key)
    cmd = cmd:gsub("CONTENT_START", self.content_start)
    vim.cmd(cmd)

    Color.set_highlight({name = self.highlight_key, val = {fg = self.divider.color}})
end

function Header.set_highlights()
    for size, _ in pairs(Header.config.sizes) do
        Header({size = size}):set_highlight()
    end
end

function Header:line_is_a(index, lines)
    local candidate_index_sets = {
        {index, index + 1, index + 2},
        {index - 1, index, index + 1},
        {index - 2, index - 1, index},
    }

    for _, index_set in ipairs(candidate_index_sets) do
        local lines_set = {}
        for _, i in ipairs(index_set) do
            if 1 <= i and i <= #lines then
                lines_set[#lines_set + 1] = lines[i]
            end
        end

        if self:lines_are_a(unpack(lines_set)) then
            return true
        end
    end

    return false
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

return Header
