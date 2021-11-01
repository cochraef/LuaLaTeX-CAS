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
local f = IntegerModN(Integer(100), Integer(62501))

print("Testing modular arithmetic...")
test(a, "2")
test(b, "1")
test(c, "0")

test(a + b, "0")
test(a - b, "1")
test(a * b, "2")
test(a:inv(), "2")
test(b:inv(), "1")
test(f:inv(), "61876")
print()

local d = IntegerModN(Integer(16), Integer(36))
local e = IntegerModN(Integer(27), Integer(36))

test(d * e, "0")
test(a * d, "2")


local p = PolynomialRing({a, b, a}, "x")

test(p, "2x^2+1x^1+2x^0")
test(p + p, "1x^2+2x^1+1x^0")


local f = IntegerModN(Integer(3), Integer(13));
local q = PolynomialRing({IntegerModN(Integer(2), Integer(13)),
                            IntegerModN(Integer(6), Integer(13)),
                            IntegerModN(Integer(4), Integer(13))}, "z")

test(q, "4z^2+6z^1+2z^0")
test(f * q, "12z^2+5z^1+6z^0")