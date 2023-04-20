local Header = require("hnetxt-nvim.document.element.header")
local Divider = require("hnetxt-nvim.document.element.divider")

describe("__tostring", function()
    it("small", function()
        local divider_string = tostring(Divider("small"))
        assert.are.same(
            {
                divider_string,
                "> heading",
                divider_string,
                ""
            },
            tostring(Header({size = "small", content = "heading"}))
        )
    end)

    it("medium", function()
        local divider_string = tostring(Divider("medium"))
        assert.are.same(
            {
                divider_string,
                "= heading",
                divider_string,
                ""
            },
            tostring(Header({size = "medium", content = "heading"}))
        )
    end)

    it("large", function()
        local divider_string = tostring(Divider("large"))
        assert.are.same(
            {
                divider_string,
                "# heading",
                divider_string,
                ""
            },
            tostring(Header({size = "large", content = "heading"}))
        )
    end)

    it("no content", function()
        local divider_string = tostring(Divider("small"))
        assert.are.same(
            {
                divider_string,
                ">",
                divider_string,
                ""
            },
            tostring(Header({size = "small", content = ""}))
        )
    end)

    it("function content", function()
        local divider_string = tostring(Divider("small"))
        assert.are.same(
            {
                divider_string,
                "> function",
                divider_string,
                ""
            },
            tostring(Header({size = "small", content = function() return "function" end}))
        )
    end)
end)

describe("lines_are_a", function()
    it("+", function()
        local l1, l2, l3 = unpack(tostring(Header()))
        assert(Header():lines_are_a(l1, l2, l3))
    end)

    it("+: with content", function()
        local l1, l2, l3 = unpack(tostring(Header({content = "content"})))
        assert(Header():lines_are_a(l1, l2, l3))
    end)

    it("-: bad first divider", function()
        local l1, l2, l3 = unpack(tostring(Header()))
        assert.falsy(Header():lines_are_a("bad", l2, l3))
    end)

    it("-: bad content line", function()
        local l1, l2, l3 = unpack(tostring(Header()))
        assert.falsy(Header():lines_are_a(l1, "# content", l3))
    end)

    it("-: bad second divider", function()
        local l1, l2, l3 = unpack(tostring(Header()))
        assert.falsy(Header():lines_are_a(l1, l2, "bad"))
    end)

    it("-: bad header size", function()
        local l1, l2, l3 = unpack(tostring(Header()))
        assert.falsy(Header({size = 'large'}):lines_are_a(l1, l2, l3))
    end)
end)

describe("line_is_start", function()
    it("+: line = first divider", function()
        assert(Header():line_is_start(1, tostring(Header())))
    end)

    it("-: line = content", function()
        assert.falsy(Header():line_is_start(2, tostring(Header())))
    end)

    it("-: line = last divider", function()
        assert.falsy(Header():line_is_start(3, tostring(Header())))
    end)
end)

describe("line_is_content", function()
    it("-: line = first divider", function()
        assert.falsy(Header():line_is_content(1, tostring(Header())))
    end)

    it("+: line = content", function()
        assert(Header():line_is_content(2, tostring(Header())))
    end)

    it("-: line = last divider", function()
        assert.falsy(Header():line_is_content(3, tostring(Header())))
    end)
end)

describe("line_is_end", function()
    it("-: line = first divider", function()
        assert.falsy(Header():line_is_end(1, tostring(Header())))
    end)

    it("-: line = content", function()
        assert.falsy(Header():line_is_end(2, tostring(Header())))
    end)

    it("+: line = last divider", function()
        assert(Header():line_is_end(3, tostring(Header())))
    end)
end)

describe("line_is_a", function()
    it("+: line = first divider", function()
        local lines = tostring(Header())
        local index = 1
        assert(Header():line_is_a(index, lines))
    end)

    it("+: line = content", function()
        local lines = tostring(Header())
        local index = 2
        assert(Header():line_is_a(index, lines))
    end)

    it("+: line = last divider", function()
        local lines = tostring(Header())
        local index = 3
        assert(Header():line_is_a(index, lines))
    end)

    it("-: too few lines after", function()
        local lines = tostring(Header())
        local index = 1
        assert.falsy(Header():line_is_a(index, {lines[1], lines[2]}))
    end)

    it("-: too few lines before", function()
        local lines = tostring(Header())
        local index = 1
        assert.falsy(Header():line_is_a(index, {lines[2], lines[3]}))
    end)

    it("-: too few lines before & after", function()
        local lines = tostring(Header())
        local index = 1
        assert.falsy(Header():line_is_a(index, {lines[2]}))
    end)
end)
