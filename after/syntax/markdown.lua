require("htn.text.divider").add_syntax_highlights()
require("htn.text.header").add_syntax_highlights()
require("htn.text.list").add_syntax_highlights()
require("htn.ui.fold").add_syntax_highlights()

local Color = require("hn.color")
local Syntax = require("htl.config").get('syntax')

local Dict = require("hl.Dict")

Dict(Syntax):foreach(Color.add_to_syntax)
