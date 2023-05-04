table = require("hneutil.table")
string = require("hneutil.string")

local Object = require("hneutil.object")
local Color = require("hneutil-nvim.color")
local BufferLines = require("hneutil-nvim.buffer_lines")

local List = require("hnetxt-lua.text.list")

--------------------------------------------------------------------------------
--                                 LineSyntax                                 --
--------------------------------------------------------------------------------
local LineSyntax = Object:extend()
LineSyntax.style = {
    sigil = {
        pattern = [[^\s*STR\s]],
        cmd = [[syn match KEY /PATTERN/ contained]],
    },
    text = {
        pattern = [[start="SIGIL_PATTERN\+" end="$"]],
        cmd = [[syn region KEY PATTERN containedin=ALL contains=SIGIL_KEY,mkdLink]],
    },
}
LineSyntax.defaults = {
    highlight = true,
    highlights = {
        sigil = {fg = "blue"},
        text = {},
    },
}
function LineSyntax:add_syntax_highlighting()
    if not self.highlight then return end

    -- sigils
    sigil_key = self.name .. "ListLineSigil"
    sigil_pattern = LineSyntax.style.sigil.pattern:gsub("STR", self.sigil_regex or self.sigil)
    sigil_cmd = LineSyntax.style.sigil.cmd:gsub("KEY", sigil_key)
    sigil_cmd = sigil_cmd:gsub("PATTERN", sigil_pattern)

    vim.cmd(sigil_cmd)
    Color.set_highlight({name = sigil_key, val = self.highlights.sigil})

    -- text
    text_key = self.name .. "ListLineText"
    text_pattern = LineSyntax.style.text.pattern:gsub("SIGIL_PATTERN", sigil_pattern)
    text_cmd = LineSyntax.style.text.cmd:gsub("SIGIL_KEY", sigil_key)
    text_cmd = text_cmd:gsub("PATTERN", text_pattern)
    text_cmd = text_cmd:gsub("KEY", text_key)

    vim.cmd(text_cmd)
    Color.set_highlight({name = text_key, val = self.highlights.text})
end

--------------------------------------------------------------------------------
--                                 LineToggle                                 --
--------------------------------------------------------------------------------
local LineToggle = Object:extend()
LineToggle.mapping_rhs = [[:lua require('hnetxt-nvim.text.list').toggle('MODE', 'NAME')<cr>]]
LineToggle.defaults = {
    toggle_key = '',
    toggle = {to = 'bullet'},
}
function LineToggle:map_toggle(lhs_prefix)
    if not self.toggle_key then return end

    lhs = (lhs_prefix or '') .. self.toggle_key

    for _, mode in ipairs({'n', 'v'}) do
        vim.keymap.set(
            mode,
            lhs,
            LineToggle.mapping_rhs:gsub("MODE", mode):gsub("NAME", self.name),
            {silent = true, buffer = true}
        )
    end
end

function LineToggle.set_selected_lines(args)
    args = table.default(args, {mode = 'n', lines = {}, new_line_class = nil})

    local new_lines = {}
    for i, line in ipairs(args.lines) do
        line = args.new_line_class({text = line.text, indent = line.indent, line_number = line.line_number})
        table.insert(new_lines, tostring(line))
    end

    return BufferLines.selection.set({mode = args.mode, replacement = new_lines})
end

function LineToggle.get_new_line_class(lines, toggle_line_type_name)
    local min_indent_line = LineToggle.get_min_indent_line(lines)

    if min_indent_line then
        if min_indent_line.name == toggle_line_type_name then
            return ListLine.get_class(min_indent_line.toggle.to)
        else
            return ListLine.get_class(toggle_line_type_name)
        end
    end
end

function LineToggle.get_min_indent_line(lines)
    local min_indent, min_indent_line = 1000, nil
    for _, line in ipairs(lines) do
        if line.indent:len() < min_indent then
            min_indent = line.indent:len()
            min_indent_line = line
        end
    end

    return min_indent_line
end


--------------------------------------------------------------------------------
--                                    etc                                     --
--------------------------------------------------------------------------------
local function get_parser()
    local parser = List.Parser(vim.b.list_types)
    for name, Class in pairs(parser.classes) do
        Class:implement(LineSyntax)
        Class:implement(LineToggle)
        Class.defaults = table.default(Class.defaults, LineSyntax.defaults, LineToggle.defaults)
    end
    return parser
end

local function toggle(mode, toggle_line_class_name)
    local parser = get_parser()
    lines = parser:parse(BufferLines.selection.get({mode = mode}))

    local new_line_class = LineToggle.get_new_line_class(lines, toggle_line_class_name)

    if new_line_class then
        LineToggle.set_selected_lines({mode = mode, lines = lines, new_line_class = new_line_class})
    end
end

local function join(buffer_id)
    buffer_id = buffer_id or 0
    local parser = get_parser()
    local cursor_pos  = vim.api.nvim_win_get_cursor(buffer_id)
    local first_line_number = cursor_pos[1] - 1
    local second_line_number = first_line_number + 1

    local lines = BufferLines.get({
        buffer = buffer_id,
        start_line = first_line_number,
        end_line = second_line_number + 1,
    })

    if vim.tbl_count(lines) ~= 2 then
        return
    end

    local first = parser:parse_line(lines[1], first_line_number)
    local second = parser:parse_line(lines[2], second_line_number)

    first:merge(second)

    BufferLines.set({
        buffer = buffer_id,
        start_line = first_line_number,
        end_line = second_line_number + 1,
        replacement = {tostring(first)}
    })
end

local function continue()
    local parser = get_parser()
    local chars = {}
    for name, Class in pairs(parser.classes) do
        table.insert(chars, Class.defaults.sigil)
    end

	local current_line = vim.fn.getline(vim.fn.line("."))
    current_line = current_line:match("%s*(.*)")

	local preceding_line = vim.fn.getline(vim.fn.line(".") - 1)

    if preceding_line:match("^%s*%d+%.%s") then
		local next_list_index = preceding_line:match("%d+") + 1
		vim.fn.setline(".", preceding_line:match("^%s*") .. next_list_index .. ". ")
        vim.api.nvim_input("<esc>A")
    elseif vim.tbl_count(chars) > 0 then
        for _, char in ipairs(chars) do
            local pattern = "^%s*" .. char:escape() .. "%s"
            local matched_content = preceding_line:match(pattern)
            if matched_content then
                vim.fn.setline(".", matched_content .. current_line)
                vim.api.nvim_input("<esc>A")
                return
            end
        end
	end
end

local function map_toggles(lhs_prefix)
    for _, Class in pairs(get_parser().classes) do
        Class():map_toggle(lhs_prefix)
    end
end

local function add_syntax_highlights()
    for name, Class in pairs(get_parser().classes) do
        Class():add_syntax_highlighting()
    end
end


return {
    join = join,
    continue = continue,
    continue_cmd = [[<cmd>lua require('hnetxt-nvim.text.list').continue()<cr>]],
    toggle = toggle,
    map_toggles = map_toggles,
    add_syntax_highlights = add_syntax_highlights,
}
