local Path = require("hn.path")
local BufferLines = require("hn.buffer_lines")

local Metadata = require("hd.metadata")

function Metadata.open_new(open_command)
    local m = Metadata()
    m:write()
    Path.open(m:path(), open_command)
    m:goto()
    vim.cmd("normal di[")
    vim.cmd("startinsert")
end

function Metadata:goto()
    for i, line in ipairs(BufferLines.get()) do
        if self:str_is_definition(line) then
            vim.api.nvim_win_set_cursor(0, {i, 0})
            vim.cmd("normal zz")
            return
        end
    end
end

return Metadata
