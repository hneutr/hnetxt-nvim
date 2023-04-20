--[[
TODO test:
- Line:
    - write
    - get_if_str_is_a
- ListLine:
    - get_sigil_pattern
    - get_sigil_class
    - set_highlights
    - map_toggle
    - get_class
- Parser:
    - toggle
    - set_selected_lines
    - get_min_indent_line
    - get_new_line_class
--]]
local List = require("hnetxt-nvim.document.element.list")

describe("Line", function()
    describe(":new", function() 
        it("makes an empty Item", function()
            local item1 = List.Line({text = "1"})
            local item2 = List.Line({text = "2"})

            assert.equal(item1.text, '1')
            assert.equal(item2.text, '2')
        end)
    end)

    describe(":tostring: ", function()
        it("works", function()
            local x = List.Line({text = '    text'})
            assert.equal(tostring(x), "    text")
        end)
    end)

    describe(":merge: ", function()
        it("Line + Line", function()
            local one = List.Line({text = '1'})
            local two = List.Line({text = ' 2'})

            assert.equal(tostring(one), '1')

            one:merge(two)

            assert.equal(tostring(one), '1 2')
        end)

        it("Line + ListLine", function()
            local one = List.Line({text = '    1    '})
            local two = List.ListLine({text = '2', indent = '    '})

            assert.equal(tostring(one), '    1    ')
            assert.equal(tostring(two), '    - 2')

            one:merge(two)

            assert.equal(tostring(one), '    1 2')
        end)
    end)
end)

describe("ListLine", function()
    describe(":new", function() 
        it("makes an empty Item", function()
            local item1 = List.ListLine({text = "1"})
            local item2 = List.ListLine({text = "2"})

            assert.equal(item1.text, '1')
            assert.equal(item2.text, '2')
        end)
    end)

    describe(":tostring:", function()
        it("basic case", function()
            local item = List.ListLine({text = 'text', indent = '    '})

            assert.equal(tostring(item), "    - text")
        end)
    end)

    describe(".get_if_str_is_a:", function()
        it("-", function()
            assert.is_nil(List.ListLine.get_if_str_is_a("string", 0))
        end)

        it("+", function()
            assert.are.same(
                List.ListLine.get_if_str_is_a("    - string", 0),
                List.ListLine({text = "string", indent = "    ", line_number = 0})
            )
        end)
    end)
end)

describe("NumberedListLine", function()
    describe(":new", function() 
        it("makes an empty Item", function()
            assert.equal(List.NumberedListLine().number, 1)
        end)
    end)

    describe(":tostring", function()
        it("basic case", function()
            local item = List.NumberedListLine({text = 'text', indent = '    '})
            assert.equal(tostring(item), "    1. text")
        end)
    end)

    describe("._get_if_str_is_a", function()
        it("-", function()
            assert.is_nil(List.NumberedListLine._get_if_str_is_a("- string", 0))
        end)

        it("+", function()
            assert.are.same(
                List.NumberedListLine._get_if_str_is_a("    10. string", 0),
                List.NumberedListLine({number = 10, text = "string", indent = "    ", line_number = 0})
            )
        end)
    end)
end)

describe("Parser", function()
    before_each(function()
        vim.b.list_types = nil
        parser = List.Parser()
    end)

    describe("new", function()
        it("gets default list types", function()
            assert.are.same(Parser.default_types, parser.types)
        end)

        it("accepts added types", function()
            vim.b.list_types = {"question"}
            parser = List.Parser()
            assert.are.same({"bullet", "dot", "number", "todo", "done", "reject", "question"}, parser.types)
        end)
    end)

    describe("parse_line", function()
        it("basic line", function()
            assert.are.same(
                List.Line({text="text", line_number = 1}),
                parser:parse_line("text", 1)
            )
        end)

        it("list line", function()
            assert.are.same(
                List.ListLine.get_class("bullet")({text="text", line_number = 1}),
                parser:parse_line("- text", 1)
            )
        end)

        it("numbered list line", function()
            assert.are.same(
                List.NumberedListLine({text="text", number = 10, line_number = 1}),
                parser:parse_line("10. text", 1)
            )
        end)

        it("handles vim.b.list_types", function()
            expected = List.Line({text="? text", line_number = 1})
            assert.are.same(expected, parser:parse_line("? text", 1))
        
            vim.b.list_types = {"question"}
            parser = List.Parser()
        
            expected = List.ListLine.get_class("question")({text="text", line_number = 1})
            assert.are.same(expected, parser:parse_line("? text", 1))
        end)
    end)

    describe("join_lines", function()
        local cursor_start_pos

        local set_buf_lines = function(lines)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        end

        local assert_lines_match_expectation = function(expected)
            assert.are.same(
                vim.api.nvim_buf_get_lines(0, 0, vim.fn.line('$'), false),
                expected
            )
        end

        before_each(function()
            local _buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_command("buffer " .. _buf)

            cursor_start_pos = vim.api.nvim_win_get_cursor(0)
        end)

        after_each(function()
            assert.are.same(cursor_start_pos, vim.api.nvim_win_get_cursor(0))
        end)

        it("no lines", function()
            parser:join_lines()
            assert_lines_match_expectation({""})
        end)

        it("single line", function()
            set_buf_lines({"single line"})
            parser:join_lines()
            assert_lines_match_expectation({"single line"})
        end)

        it("l1 + l2 → 11 l2", function()
            set_buf_lines({"l1", "l2"})
            parser:join_lines()
            assert_lines_match_expectation({"l1 l2"})
        end)

        it("pre + l1 + l2 + post → pre + l1 l2 + post", function()
            set_buf_lines({"pre", "l1", "l2", "post"})
            cursor_start_pos = {2, 1}
            vim.api.nvim_win_set_cursor(0, cursor_start_pos)

            parser:join_lines()
            assert_lines_match_expectation({"pre", "l1 l2", "post"})
        end)
    end)
end)
