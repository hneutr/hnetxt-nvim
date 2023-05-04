local BufferLines = require("hn.buffer_lines")
local Color = require("hn.color")

local Fold = require("htl.parse.fold"):extend()

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
