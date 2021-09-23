require("algebra._init")

local function test(expected, actual)
    print(tostring(expected) .. " (Expected: " .. tostring(actual) .. ")")
end

-- Integer Testing
local a = Integer(5)
local b = Integer(3)
local c = Integer(-12)

tostring(c)

print("Testing integer operations...")
test(-c, 12)
test(a + b, 8)
test(b - c, 15)
test(a * c, -60)
test(a // b, 1)
test(a % b, 2)
test(c ^ a, -248832)
print()

print("Testing integer comparisons...")
test(a == b, false)
test(b < a, true)
test(a <= a, true)
print()

local d = Integer(16)

print("Testing integer conversions...")
test(a / b, "5/3")
test(d / c, "-4/3")
test(c / b, -4)
print()

-- Rational Testing
local x = Integer(8) / Integer(5)
local y = Integer(1) / Integer(12)
local z = Integer(-7) / Integer(10)

print("Testing rational operations...")
test(-x, "-8/5")
test(x + y, "101/60")
test(z - y, "-47/60")
test(x * z, "-28/25")
test(x / y, "96/5")
print()

print("Testing rational comparisons...")
test(y<x, true)
test(z<z, false)
test(z<=z, true)
print()

-- Combined Integer/Rational Testing
print("Testing combined integer/rational operations...")
test(a + x, "33/5")
test(x + a, "33/5")
test(b - y, "35/12")
test(y - b, "-35/12")
test(c * y, -1)
test(y * c, -1)
test(a / x, "25/8")
test(x / a, "8/25")
print()

local e = Integer(8)

print("Testing combined integer/rational comparisons...")
test(a/e == x, false)
test(e/a == x, false)
test(y < b , true)
test(b < y, false)