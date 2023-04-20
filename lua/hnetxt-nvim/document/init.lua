table = require("hneutil.table")
local Object = require("util.object")
local BufferLines = require("hneutil-nvim.buffer_lines")
local Config = require("hnetxt-lua.config")

local Header = require("hnetxt-nvim.document.element.header")
local Divider = require("hnetxt-nvim.document.element.divider")
local List = require("hnetxt-nvim.document.element.list")

Document = Object:extend()

function Document:new()
    self.list_parser = List.Parser()
    self.fold_levels = {}
    self.lines = BufferLines.get()
end

function Document:get_line_fold_level(lnum)
end

-- - parse each line in the file:
--     - check if the current_fold ends before the line (current_fold.end_before(line))
--     - if current_fold.ends_before(line):
--         - current_fold = current_fold.parent
--     - line.fold_level = current_fold.level
--     - if current_fold.fold_begins_after(line):
--         - new_fold.parent = current_fold
--         - current_fold = new_fold

return Document
