local List = require("hnetxt-nvim.document.element.list")

print(require("inspect")(require("hneutil-lua")))

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
