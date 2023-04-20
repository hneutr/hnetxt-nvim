local Divider = require("hnetxt-nvim.document.element.divider")

local dividers = {
    small = "----------------------------------------",
    medium = "=-----------------------------------------------------------",
    large = "#-------------------------------------------------------------------------------",
}

describe("__tostring", function()
    it("small", function()
        assert.equal(dividers.small, tostring(Divider("small")))
    end)

    it("medium", function()
        assert.equal(dividers.medium, tostring(Divider("medium")))
    end)

    it("large", function()
        assert.equal(dividers.large, tostring(Divider("large")))
    end)
end)

describe("line_is_a", function()
    it("+", function()
        assert(Divider():line_is_a(1, {dividers.small}))
    end)

    it("-: wrong divider", function()
        assert.falsy(Divider():line_is_a(1, {dividers.large}))
    end)

    it("-: not a divider", function()
        assert.falsy(Divider():line_is_a(1, {"text"}))
    end)
end)
