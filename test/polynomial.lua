require("algebra._init")


local function test(expected, actual)
    print(tostring(expected) .. " (Expected: " .. tostring(actual) .. ")")
end

local a = PolynomialRing({
    Integer(1),
    Integer(2),
    Integer(3),
    Integer(4),
    Integer(5)
}, "x")

local b = PolynomialRing({
    Integer(1) / Integer(3),
    Integer(1) / Integer(12),
    Integer(6) / Integer(3),
}, "x")

local c = PolynomialRing({
    Integer(12),
    Integer(4)
}, "x")

print("Testing polynomial addition and subtraction...")
test(b, "2x^2+1/12x+1/3")
-- print(a + a)
-- print(a + b)
-- print(b + a)
-- print(a - b)
-- print(b:multiplyDegree(4))
-- print(a:multiplyDegree(12))
-- print()

-- print("Testing polynomial degrees...")
-- print(a:getDegree())
-- print(b:getDegree())
-- print(b:multiplyDegree(4):getDegree())
-- print()

-- print("Testing polynomial multiplication...")
-- print(c * c)
-- print(a * c)
-- print(c * a)
-- print(b * c)

-- -- Unfortunately operator overloading can only return one value, and we need to return two - the quotient and the remainder
-- print("Testing polynomial division...")
-- print(a:divide(c))
-- print(a:divide(b))
-- print(b:divide(c))
