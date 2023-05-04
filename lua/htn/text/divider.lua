local Color = require("hn.color")

local Divider = require("htl.text.divider"):extend()
Divider.highlight_cmd = [[syn region KEY start="^\s*DIVIDER$" end="$" containedin=ALL]]

function Divider:add_syntax_highlighting()
    cmd = self.highlight_cmd:gsub("KEY", self.highlight_key)
    cmd = cmd:gsub("DIVIDER", tostring(self))
    vim.cmd(cmd)

    Color.set_highlight({name = self.highlight_key, val = {fg = self.color}})
end

function Divider.add_syntax_highlights()
    for size, _ in pairs(Divider.config.sizes) do
        Divider(size):add_syntax_highlighting()
    end
end

return Divider
