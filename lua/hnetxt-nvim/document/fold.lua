table = require("hneutil.table")
local Object = require("util.object")

local BufferLines = require("hneutil-nvim.buffer_lines")
local Color = require("hneutil-nvim.color")

local Config = require("hnetxt-lua.config")
local Header = require("hnetxt-nvim.document.element.header")
local Divider = require("hnetxt-nvim.document.element.divider")
local List = require("hnetxt-nvim.document.element.list")

local Fold = Object:extend()
Fold.config = Config.get("fold")
Fold.line_suffix = Fold.config.line_suffix
Fold.default_line_level = Fold.config.default_line_level

function Fold:new(args)
    self = table.default(self, args or {}, {list_parser = List.Parser()})
    self.headers_by_size = Header.headers_by_size()
    self.dividers_by_size = Divider.dividers_by_size()
    self.level_stack = {0}
    self.indent_stack = {-1}
end

--------------------------------------------------------------------------------
-- get_line_levels
-- ---------------
-- for each line:
-- 1. updates the current fold level
-- 2. records the fold level for the line
-- 3. sets the subsequent fold level
--------------------------------------------------------------------------------
function Fold:get_line_levels(lines)
    local line_levels = {}
    for index, line in ipairs(lines) do
        self:set_current_fold(index, lines)
        line_levels = self:set_line_level(index, lines, line_levels)
        self:set_subsequent_fold(index, lines)
    end

    return line_levels
end

--------------------------------------------------------------------------------
-- set_line_level
-- --------------
-- sets the level of the current line. 
-- If the current line is a barrier and the previous line is blank, set its level to the current
-- line's level
--------------------------------------------------------------------------------
function Fold:set_line_level(index, lines, line_levels)
    if 1 < index and self:barrier_ends_fold(index, lines) and lines[index - 1]:len() == 0 then
        line_levels[#line_levels] = self.level_stack[#self.level_stack]
    end

    line_levels[#line_levels + 1] = self.level_stack[#self.level_stack]

    return line_levels
end

--------------------------------------------------------------------------------
--                                                                            --
--                                                                            --
--                                fold closing                                --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
-- set_current_fold
-- ----------------
-- closes a fold if warranted by the current content.
--
-- content that causes a fold to be closed:
-- - the start of a header
-- - a divider
-- - a list_line that with indent <= indent_stack[-1]
--------------------------------------------------------------------------------
function Fold:set_current_fold(index, lines)
    local barrier_ends_fold = self:barrier_ends_fold(index, lines)

    if barrier_ends_fold then
        self:end_size_fold(barrier_ends_fold.size)
        return
    end

    local list_line_ends_fold = self:list_line_ends_fold(index, lines)
    if list_line_ends_fold then
        self:end_indent_fold(list_line_ends_fold.indent:len())
    end
end

function Fold:barrier_ends_fold(index, lines)
    for size, header in pairs(self.headers_by_size) do
        if header:line_is_a(index, lines) then
            if header:line_is_start(index, lines) then
                return header
            end
        else
            local divider = self.dividers_by_size[size]
            if divider:line_is_a(index, lines) then
                return divider
            end
        end
    end

    return false
end

function Fold:list_line_ends_fold(index, lines)
    local list_line = List.Line.get_if_str_is_a(lines[index], index)
    if list_line.indent:len() <= self.indent_stack[#self.indent_stack] then
        return list_line
    end

    return false
end

-- pop until the value on the fold_stack is less than the new level
function Fold:end_size_fold(size)
    local level = self.config.size_to_level[size]
    while self.level_stack[#self.level_stack] >= level do
        self.level_stack[#self.level_stack] = nil
        self.indent_stack[#self.indent_stack] = nil
    end
end

-- pop until the indent_stack is < than the new indent
function Fold:end_indent_fold(indent)
    while self.indent_stack[#self.indent_stack] >= indent do
        self.level_stack[#self.level_stack] = nil
        self.indent_stack[#self.indent_stack] = nil
    end
end

--------------------------------------------------------------------------------
--                                                                            --
--                                                                            --
--                                fold opening                                --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------
--                                      
--------------------------------------------------------------------------------
-- set_subsequent_fold
-- -------------------
-- starts a new fold if warranted by the current content.
-- 
-- content that causes a new fold to be started:
-- - the end of a header
-- - a divider
-- - a list_line that has `fold` = true
-- - a list_line that ends with the `line_suffix`
--------------------------------------------------------------------------------
function Fold:set_subsequent_fold(index, lines)
    local barrier_starts_fold = self:barrier_starts_fold(index, lines)

    if barrier_starts_fold then
        self:start_size_fold(barrier_starts_fold.size)
        return
    end

    local list_line_starts_fold = self:list_line_starts_fold(index, lines)
    if list_line_starts_fold then
        self:start_indent_fold(list_line_starts_fold.indent:len())
    end
end

function Fold:barrier_starts_fold(index, lines)
    for size, header in pairs(self.headers_by_size) do
        if header:line_is_a(index, lines) then
            if header:line_is_end(index, lines) then
                return header
            end
        else
            local divider = self.dividers_by_size[size]
            if divider:line_is_a(index, lines) then
                return divider
            end
        end
    end

    return false
end

function Fold:list_line_starts_fold(index, lines)
    local list_line = self.list_parser:parse_line(lines[index], index)

    if list_line.fold or list_line.text:endswith(self.line_suffix) then
        return list_line
    end

    return false
end

function Fold:start_size_fold(size)
    self.level_stack[#self.level_stack + 1] = self.config.size_to_level[size]
    self.indent_stack[#self.indent_stack + 1] = -1
end

-- - when we encounter a list_line that starts a fold:
--     - if required_indent_stack[-1] = 0:
--         - fold_stack.push(4)
--         - required_indent_stack.push(list_line.indent)
--     - else:
--         - fold_stack.push(fold_stack[-1] + 1)
--         - required_indent_stack.push(list_line.indent)
function Fold:start_indent_fold(indent)
    local previous_level = self.level_stack[#self.level_stack]
    local level = self.default_line_level
    
    if level <= previous_level then
        level = previous_level + 1
    end

    self.level_stack[#self.level_stack + 1] = level
    self.indent_stack[#self.indent_stack + 1] = indent
end

--------------------------------------------------------------------------------
--                                                                            --
--                                                                            --
--                          vim interface functions                           --
--                                                                            --
--                                                                            --
--------------------------------------------------------------------------------
function Fold.get_text(lnum)
    local text = BufferLines.line.get({start_line = lnum})
    local whitespace, text = text:match("^(%s*)(.*)")
    return whitespace .. "..."
end

function Fold.get_indic(lnum)
    if not vim.b.fold_levels then
        vim.b.fold_levels = Fold():get_line_levels(BufferLines.get())
    end

    return vim.b.fold_levels[lnum]
end

function Fold.set_options()
    vim.wo.foldenable = true
    vim.wo.foldnestmax = 20
    vim.wo.foldtext = "hnetxt_nvim#foldtext()"
    vim.wo.fillchars = "fold: "
    vim.wo.foldlevel = 2
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'hnetxt_nvim#foldexpr()'

    Color.set_highlight({name = "Folded", val = {fg = 'magenta'}})
end

return Fold
