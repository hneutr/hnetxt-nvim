local Fold = require("hnetxt-nvim.document.fold")

local Divider = require("hnetxt-nvim.document.element.divider")
local Header = require("hnetxt-nvim.document.element.header")
local List = require("hnetxt-nvim.document.element.list")

describe("barrier_starts_fold", function()
    it("-: start of header", function()
        assert.falsy(Fold():barrier_starts_fold(1, tostring(Header())))
    end)

    it("+: header", function()
        assert.are.same(Header(), Fold():barrier_starts_fold(3, tostring(Header())))
    end)

    it("+: divider", function()
        assert.are.same(Divider(), Fold():barrier_starts_fold(3, {1, 2, tostring(Divider())}))
    end)

    it("+: vary size", function()
        assert.are.same(Divider("large"), Fold():barrier_starts_fold(3, {1, 2, tostring(Divider("large"))}))
    end)
end)

describe("list_line_starts_fold", function()
    before_each(function()
        vim.b.list_types = nil
    end)

    it("-: non-fold type, inappropriate suffix", function()
        assert.falsy(Fold():list_line_starts_fold(1, {"- list item"}))
    end)

    it("+: fold type list line", function()
        vim.b.list_types = {"question"}
        local expected = List.ListLine.get_class("question")({text = "question", line_number = 1})
        assert.are.same(expected, Fold():list_line_starts_fold(1, {"? question"}))
    end)

    it("+: appropriate suffix", function()
        local expected = List.Line({text = "item >", line_number = 1})
        assert.are.same(expected, Fold():list_line_starts_fold(1, {"item >"}))
    end)
end)

describe("start_size_fold", function()
    it("small", function()
        local fold = Fold()
        fold:start_size_fold("small")
        assert.are.same({0, 3}, fold.level_stack)
        assert.are.same({-1, -1}, fold.indent_stack)
    end)

    it("large", function()
        local fold = Fold()
        fold:start_size_fold("large")
        assert.are.same({0, 1}, fold.level_stack)
        assert.are.same({-1, -1}, fold.indent_stack)
    end)
end)

describe("start_indent_fold", function()
    it("first indent", function()
        local fold = Fold()
        fold:start_indent_fold(2)
        assert.are.same({0, 4}, fold.level_stack)
        assert.are.same({-1, 2}, fold.indent_stack)
    end)

    it("second indent", function()
        local fold = Fold()
        fold:start_indent_fold(2)
        fold:start_indent_fold(4)
        assert.are.same({0, 4, 5}, fold.level_stack)
        assert.are.same({-1, 2, 4}, fold.indent_stack)
    end)
end)

describe("barrier_ends_fold", function()
    it("+: start of header", function()
        assert.are.same(Header(), Fold():barrier_ends_fold(1, tostring(Header())))
    end)

    it("-: end of header", function()
        assert.falsy(Fold():barrier_ends_fold(3, tostring(Header())))
    end)

    it("+: divider", function()
        assert.are.same(Divider(), Fold():barrier_ends_fold(3, {1, 2, tostring(Divider())}))
    end)

    it("+: vary size", function()
        assert.are.same(Divider("large"), Fold():barrier_ends_fold(3, {1, 2, tostring(Divider("large"))}))
    end)
end)

describe("list_line_ends_fold", function()
    it("+: indented fold, same indent", function()
        local fold = Fold()
        fold.level_stack = {0, 4}
        fold.indent_stack = {-1, 2}

        local str = "  - list item"
        local expected = List.Line.get_if_str_is_a(str, 1)
        assert.are.same(expected, fold:list_line_ends_fold(1, {str}))
    end)

    it("+: indented fold, lower indent", function()
        local fold = Fold()
        fold.level_stack = {0, 4}
        fold.indent_stack = {-1, 4}

        local str = "  - list item"
        local expected = List.Line.get_if_str_is_a(str, 1)
        assert.are.same(expected, fold:list_line_ends_fold(1, {str}))
    end)

    it("+: 0-indented fold, same indent", function()
        local fold = Fold()
        fold.level_stack = {0, 4}
        fold.indent_stack = {-1, 0}

        local str = "- list item"
        local expected = List.Line.get_if_str_is_a(str, 1)
        assert.are.same(expected, fold:list_line_ends_fold(1, {str}))
    end)

    it("-: non-indented fold, no indent", function()
        local fold = Fold()
        fold.level_stack = {0, 3}
        fold.indent_stack = {-1, -1}

        local str = "- list item"
        assert.falsy(fold:list_line_ends_fold(1, {str}))
    end)

    it("-: indented fold, higher indent", function()
        local fold = Fold()
        fold.level_stack = {0, 4}
        fold.indent_stack = {-1, 0}

        local str = "  - list item"
        assert.falsy(fold:list_line_ends_fold(1, {str}))
    end)
end)

describe("end_size_fold", function()
    it("small", function()
        local fold = Fold()
        fold.level_stack = {0, 1, 2, 3, 4}
        fold.indent_stack = {-1, -1, -1, -1, 4}

        fold:end_size_fold("small")
        assert.are.same({0, 1, 2}, fold.level_stack)
        assert.are.same({-1, -1, -1}, fold.indent_stack)
    end)

    it("large", function()
        local fold = Fold()
        fold.level_stack = {0, 1, 2, 3, 4}
        fold.indent_stack = {-1, -1, -1, -1, 4}

        fold:end_size_fold("large")
        assert.are.same({0}, fold.level_stack)
        assert.are.same({-1}, fold.indent_stack)
    end)
end)

describe("end_indent_fold", function()
    it("first indent", function()
        local fold = Fold()
        fold.level_stack = {0, 1, 4, 5}
        fold.indent_stack = {-1, -1, 2, 4}

        fold:end_indent_fold(4)
        assert.are.same({0, 1, 4}, fold.level_stack)
        assert.are.same({-1, -1, 2}, fold.indent_stack)
    end)

    it("second indent", function()
        local fold = Fold()
        fold.level_stack = {0, 1, 4, 5}
        fold.indent_stack = {-1, -1, 2, 4}

        fold:end_indent_fold(2)
        assert.are.same({0, 1}, fold.level_stack)
        assert.are.same({-1, -1}, fold.indent_stack)
    end)
end)

describe("get_line_levels", function()
    before_each(function()
        vim.b.list_types = nil
    end)

    it("no folds", function()
        local lines = {"a", "b", "c"}
        local expected = {0, 0, 0}
        assert.are.same(expected, Fold():get_line_levels(lines))
    end)

    it("indent but folds", function()
        local lines = {"a", "  b", "c"}
        local expected = {0, 0, 0}
        assert.are.same(expected, Fold():get_line_levels(lines))
    end)

    it("indent", function()
        local lines = {"a", "  b >", "    c", "d"}
        local expected = {0, 0, 4, 0}
        assert.are.same(expected, Fold():get_line_levels(lines))
    end)

    it("multiple indents", function()
        vim.b.list_types = {"question"}

        local lines = {
            "a",
            "? b",
            "  ? c",
            "    d",
            "  ? e",
            "    f",
            "g",
        }
        local expected = {0, 0, 4, 5, 4, 5, 0}
        assert.are.same(expected, Fold():get_line_levels(lines))
    end)

    it("divider", function()
        local lines = {tostring(Divider()), "a", "b"}
        local expected = {0, 3, 3}
        assert.are.same(expected, Fold():get_line_levels(lines))
    end)

    it("multiple dividers", function()
        local lines = {
            tostring(Divider("large")),
            "a",
            tostring(Divider("small")),
            "b",
            tostring(Divider("large")),
            "c",
        }
        local expected = {0, 1, 1, 3, 0, 1}
        assert.are.same(expected, Fold():get_line_levels(lines))
    end)
end)
