local stub = require('luassert.stub')

local Path = require("hneutil-nvim.path")
local Location = require("hnetxt-nvim.text.location")


describe("new", function() 
    local path_current_file

    before_each(function()
        path_current_file = stub(Path, "current_file")
    end)

    after_each(function()
        path_current_file:revert()
    end)

    it("defaults the path", function()
        local location = Location({label = "label"})
        assert.stub(path_current_file).was_called()
    end)

end)

describe("__tostring", function() 
    it("+", function()
        local one = Location({path = 'a', label = 'b'})
        local two = Location({path = 'c'})
        assert.equals("a:b", tostring(one))
        assert.equals("c", tostring(two))
    end)
end)

describe("from_str", function() 
    it("relativizes", function()
    end)
end)


-- describe("goto", function() 
--     local lines = {
--         "line 1",
--         "line 2",
--         "[marker 1]()",
--         "[reference 1](abc)",
--         "",
--         "[marker 2]()",
--         "[reference 2](marker 3)",
--     }

--     local mark_goto

--     before_each(function()
--         local buf = vim.api.nvim_create_buf(false, true)
--         vim.api.nvim_command("buffer " .. buf)
--         vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)

--         vim.api.nvim_win_set_cursor(0, {4, 0})

--         nvim_win_set_cursor = stub(vim.api, "nvim_win_set_cursor")
--         mark_goto = stub(Mark, "goto")
--     end)

--     after_each(function()
--         mark_goto:revert()
--     end)

--     it("doesn't find the mark, doesn't move the cursor", function()
--         Mark.goto("marker 3")
--         assert.stub(mark_goto).was_not_called()
--     end)

--     it("finds the mark, moves the cursor", function()
--         Mark.goto("marker 1")
--         assert.stub(mark_goto).was_called_with()
--     end)
-- end)


describe("update", function() 
end)
