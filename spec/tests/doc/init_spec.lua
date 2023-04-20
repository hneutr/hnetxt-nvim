local stub = require('luassert.stub')

describe("init", function()
    it("tries a test", function()
        assert(require("hnetxt-nvim.doc") == 5)
    end)
end)
