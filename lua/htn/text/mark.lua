local BufferLines = require("hn.buffer_lines")

local Mark = require("htl.text.mark")

function Mark.goto(label)
    local line = Mark.find(label, BufferLines.get())

    if line then
        vim.api.nvim_win_set_cursor(0, {line, 0})
        vim.cmd("normal zz")
    end
end

return Mark
