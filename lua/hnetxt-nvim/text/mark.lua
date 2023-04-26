local BufferLines = require("hneutil-nvim.buffer_lines")

local Mark = require("hnetxt-lua.text.mark"):extend()

function Mark.goto(label)
    for i, line in ipairs(BufferLines.get()) do
        if line:len() > 0 then
            if Mark.str_is_a(line) and Mark.from_str(line).label == label then
                vim.api.nvim_win_set_cursor(0, {i, 0})
                vim.cmd("normal zz")
                break
            end
        end
    end
end

return Mark
