local stub = require('luassert.stub')
local Mark = require("hnetxt-nvim.text.mark")


describe("goto", function() 
    local lines = {
        "line 1",
        "line 2",
        "[marker 1]()",
        "[reference 1](abc)",
        "",
        "[marker 2]()",
        "[reference 2](marker 3)",
    }

    local nvim_win_set_cursor

    before_each(function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_command("buffer " .. buf)
        vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)

        vim.api.nvim_win_set_cursor(0, {4, 0})

        nvim_win_set_cursor = stub(vim.api, "nvim_win_set_cursor")
    end)

    after_each(function()
        nvim_win_set_cursor:revert()
    end)

    it("doesn't find the mark, doesn't move the cursor", function()
        Mark.goto("marker 3")
        assert.stub(nvim_win_set_cursor).was_not_called()
    end)

    it("finds the mark, moves the cursor", function()
        Mark.goto("marker 1")
        assert.stub(nvim_win_set_cursor).was_called_with(0, {3, 0})
    end)
end)
