require("algebra._init")

local function test(actual, expected, initial)
    if initial then
        if tostring(expected) == tostring(actual) then
            print(tostring(initial) .. " -> " .. tostring(actual))
        else
            print(tostring(initial) .. " -> " .. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
        end
    else
        if tostring(expected) == tostring(actual) then
            print("Result: " .. tostring(actual))
        else
            print("Result: ".. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
        end
    end
end

-- Basic Testing
local a = IntegerModN(Integer(5), Integer(3))
local b = IntegerModN(Integer(1), Integer(3))
local c = IntegerModN(Integer(-12), Integer(3))

print("Testing modular arithmetic...")
test(a, "2")
test(b, "1")
test(c, "0")

test(a + b, "0")
test(a - b, "1")
test(a * b, "2")
test(a:inv(), "2")
test(b:inv(), "1")

local d = IntegerModN(Integer(16), Integer(36))
local e = IntegerModN(Integer(27), Integer(36))

test(d * e, "0")
-- test(a * d, "2")