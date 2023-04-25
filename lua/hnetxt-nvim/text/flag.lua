local Object = require("util.object")

local Flag = Object:extend()

function Flag.add_syntax_highlights()
    vim.fn.matchadd("Conceal", "|.*|", 10)
end

return Flag
