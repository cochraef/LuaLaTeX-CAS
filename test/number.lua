require("algebra._init")

-- Integer Testing
local a = Integer(5)
local b = Integer(3)
local c = Integer(-12)

tostring(c)

print("Testing integer operations...")
print(tostring(-c) .. " (Expected: 12)")
print(tostring(a + b) .. " (Expected: 8)")
print(tostring(b - c) .. " (Expected: 15)")
print(tostring(a * c) .. " (Expected: -60)")
print(tostring(a // b) .. " (Expected: 1)")
print(tostring(a % b) .. " (Expected: 2)")
print(tostring(c ^ a) .. " (Expected: -248832)")
print()

print("Testing integer comparisons...")
print(tostring(a == b) .. " (Expected: false)")
print(tostring(b < a) .. " (Expected: false)")
print(tostring(a <= a) .. " (Expected: true)")
print()

local d = Integer(16)

-- print("Testing integer conversions...")
-- print(a / b)
-- print(d / c)
-- print(c / b)
-- print()

-- -- Rational Testing
-- local x = Integer(8) / Integer(5)
-- local y = Integer(1) / Integer(12)
-- local z = Integer(-7) / Integer(10)

-- print("Testing rational operations...")
-- print(-x)
-- print(x + y)
-- print(z - y)
-- print(x * z)
-- print(x / y)
-- print()

-- -- Combined Integer/Rational Testing
-- print("Testing combined integer/rational operations...")
-- print(a + x)
-- print(x + a)
-- print(b - y)
-- print(y - b)
-- print(c * y)
-- print(y * c)
-- print(a / x)
-- print(x / a)
-- print()

-- local e = Integer(8)

-- print("Testing combined integer/rational comparisons...")
-- print(a/e == x)
-- print(e/a == x)
-- print(y < b) -- Honestly I don't think this should work but I am not complaining
-- print(b < y)