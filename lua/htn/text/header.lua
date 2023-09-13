local Color = require("hn.color")

local Header = require("htl.text.header"):extend()
Header.highlight_cmd = [[syn match KEY /^CONTENT_START\s/ containedin=ALL]]

function Header:add_syntax_highlighting()
    local highlight_key = self.size .. "HeaderStart" 
    cmd = self.highlight_cmd:gsub("KEY", highlight_key)
    cmd = cmd:gsub("CONTENT_START", self.content_start)
    vim.cmd(cmd)

    Color.set_highlight({name = highlight_key, val = {fg = self.divider.color}})
end

function Header.add_syntax_highlights()
    for size, _ in pairs(Header.config.sizes) do
        Header({size = size}):add_syntax_highlighting()
    end
end

return Header
