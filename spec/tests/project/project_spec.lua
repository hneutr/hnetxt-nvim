local Project = require("hnetxt-nvim.project")

local constants

describe("set", function()
    -- local find = m.file.find
    -- local build = m.file.build

    -- before_each(function()
    --     m.file.build = function() return { test = 1 } end
    --     vim.g.lex_configs = nil
    -- end)

    -- after_each(function()
    --     m.file.find = find
    --     m.file.build = build
    --     vim.g.lex_configs = nil
    -- end)

    -- it("doesn't find a file", function()
    --     m.file.find = function() return end

    --     m.set()
    --     assert.is_nil(vim.b.lex_config_path)
    --     assert.is_true(vim.tbl_isempty(vim.g.lex_configs))
    -- end)

    -- it("finds a file without predefined config", function()
    --     m.file.find = function() return "test" end

    --     m.set()
    --     assert.equals(vim.b.lex_config_path, 'test')
    --     assert.equals(vim.tbl_count(vim.g.lex_configs.test), 1)
    --     assert.equals(vim.g.lex_configs.test.test, 1)
    -- end)

    -- it("finds a file with predefined config", function()
    --     build = stub(m.file, "build")

    --     m.file.find = function() return "test" end
    --     vim.g.lex_configs = { test = { test = 1 } }

    --     m.set()
    --     assert.equals(vim.b.lex_config_path, 'test')
    --     assert.equals(vim.tbl_count(vim.g.lex_configs.test), 1)
    --     assert.equals(vim.g.lex_configs.test.test, 1)

    --     assert.stub(build).was_not_called()

    --     build:revert()
    -- end)
end)

describe("get", function()
    it("checks that things are ok without anything defined", function()
        assert.is_true(vim.tbl_isempty(m.get()))
    end)
end)
