local stub = require('luassert.stub')

local Location = require("hnetxt-nvim.text.location")
local Mark = require("hnetxt-nvim.text.mark")

local Path = require("hneutil-nvim.path")


describe("goto", function() 
    local open_command = "edit"
    local current_file
    local open_path
    local buf

    before_each(function()
        vim.b.hnetxt_project_root = nil

        current_file = Path.current_file
        Path.current_file = function() return "file" end

        stub(Path, "open")
        stub(Mark, "goto")
    end)

    after_each(function()
        vim.b.hnetxt_project_root = nil

        Path.current_file = current_file

        Path.open:revert()
        Mark.goto:revert()
    end)

    it("str: -; Path.open: -; Mark.goto: +", function()
        local lines = {
            "a",
            "b",
            "[m1]()",
            "[r1](file:m3)",
            "",
            "[m2]()",
            "[r2](m2)",
        }

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_command("buffer " .. buf)
        vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)

        vim.api.nvim_win_set_cursor(0, {4, 0})

        Location.goto(open_command)

        assert.stub(Path.open).was_not_called()
        assert.stub(Mark.goto).was_called_with("m3")
    end)

    it("str: +; project_root: +; Path.open: +; Mark.goto: -", function()
        vim.b.hnetxt_project_root = "dir"
        Location.goto(open_command, "[a](f1)")

        assert.stub(Path.open).was_called()
        assert.stub(Mark.goto).was_not_called()
    end)
end)
