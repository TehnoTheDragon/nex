local unit = require("tests.unit")

local unitEnsure = unit.new("Unit Ensure")
unitEnsure:nofine("undefined variables", function()
    _ = x + x
end)
unitEnsure:fine("zero divided by", function()
    _ = 0 / 1
end)
unitEnsure:equal("return sum of a and b", function(a, b)
    return a + b
end, 30, 10, 20)
print(unitEnsure())