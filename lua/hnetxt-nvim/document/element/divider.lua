table = require("hneutil.table")

local Object = require("util.object")
local Config = require("hnetxt-lua.config")
local Color = require("hneutil-nvim.color")

local Divider = Object:extend()
Divider.config = Config.get("divider")
Divider.default_size = Divider.config.default_size
Divider.fill_char = Divider.config.fill_char
Divider.highlight_cmd = [[syn region KEY start="^\s*DIVIDER$" end="$" containedin=ALL]]

function Divider:new(size)
    self.size = size or self.default_size
    self.highlight_key = self.size .. "Divider"

    for k, v in pairs(self.config.sizes[self.size]) do
        self[k] = v
    end

end

function Divider:__tostring()
    local str = self.start_string
    return str .. string.rep(self.fill_char, self.width - (str:len()))
end

function Divider:set_highlight()
    cmd = self.highlight_cmd:gsub("KEY", self.highlight_key)
    cmd = cmd:gsub("DIVIDER", tostring(self))
    vim.cmd(cmd)

    Color.set_highlight({name = self.highlight_key, val = {fg = self.color}})
end

function Divider.set_highlights()
    for size, _ in pairs(Divider.config.sizes) do
        Divider(size):set_highlight()
    end
end

function Divider:line_is_a(index, lines)
    return tostring(self) == lines[index]
end

function Divider.dividers_by_size()
    local dividers_by_size = {}
    for size, _ in pairs(Divider.config.sizes) do
        dividers_by_size[size] = Divider(size)
    end

    return dividers_by_size
end


return Divider
