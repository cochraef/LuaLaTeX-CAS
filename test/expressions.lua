require("algebra._init")

local function test(expected, actual)
    if(tostring(expected) == tostring(actual)) then
        print("Result: " .. tostring(expected))
    else
        print("Result: ".. tostring(expected) .. " (Expected: " .. tostring(actual) .. ")")
    end
end

local a = BinaryOperation(BinaryOperation.ADD, {Integer(3), Integer(5)})

test(a, "(3 + 5)")
test(a:evaluate(), 8)