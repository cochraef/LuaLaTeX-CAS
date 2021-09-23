require("algebra._init")

local function test(expected, actual)
    print(tostring(expected) .. " (Expected: " .. tostring(actual) .. ")")
end

local a = BinaryOperation(BinaryOperation.ADD, {Integer(3), Integer(5)})

test(a, "(3 + 5)")
test(a:evaluate(), 8)