local BufferLines = require("hneutil-nvim.buffer_lines")
local Color = require("hneutil-nvim.color")

local Fold = require("hnetxt-lua.parse.fold"):extend()

function Fold.get_text(lnum)
    local text = BufferLines.line.get({start_line = lnum})
    local whitespace, text = text:match("^(%s*)(.*)")
    return whitespace .. "..."
end

function Fold.set_fold_levels()
    vim.b.fold_levels = Fold():get_line_levels(BufferLines.get())
end

function Fold.get_indic(lnum)
    if not vim.b.fold_levels then
        Fold.set_fold_levels()
    end

    return vim.b.fold_levels[lnum]
end

function Fold.add_syntax_highlights()
    Color.set_highlight({name = "Folded", val = {fg = 'magenta'}})
end

return Fold
