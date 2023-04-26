--[[
TODO test:
- Line:
    - write
    - get_if_str_is_a
- ListLine:
    - set_highlights
    - map_toggle
- misc:
    - toggle
    - set_selected_lines
    - get_min_indent_line
    - get_new_line_class
--]]
local List = require("hnetxt-nvim.text.list")

describe("join", function()
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
        List.join()
        assert_lines_match_expectation({""})
    end)

    it("single line", function()
        set_buf_lines({"single line"})
        List.join()
        assert_lines_match_expectation({"single line"})
    end)

    it("l1 + l2 → 11 l2", function()
        set_buf_lines({"l1", "l2"})
        List.join()
        assert_lines_match_expectation({"l1 l2"})
    end)

    it("pre + l1 + l2 + post → pre + l1 l2 + post", function()
        set_buf_lines({"pre", "l1", "l2", "post"})
        cursor_start_pos = {2, 1}
        vim.api.nvim_win_set_cursor(0, cursor_start_pos)

        List.join()
        assert_lines_match_expectation({"pre", "l1 l2", "post"})
    end)
end)
