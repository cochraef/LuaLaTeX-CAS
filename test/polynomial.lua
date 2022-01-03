require("algebra._init")
require("_lib.pepperfish")


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

print("Testing polynomial construction...")
test(a, "5x^4+4x^3+3x^2+2x^1+1x^0")
test(a.degree, 4)
test(b, "2x^2+1/12x^1+1/3x^0")
test(b.degree, 2)
print()

print("Testing polynomial addition and subtraction...")
test(a + a, "10x^4+8x^3+6x^2+4x^1+2x^0")
test(a + b, "5x^4+4x^3+5x^2+25/12x^1+4/3x^0")
test(b + a, "5x^4+4x^3+5x^2+25/12x^1+4/3x^0")
test(a - a, "0x^0")
test(a - b, "5x^4+4x^3+1x^2+23/12x^1+2/3x^0")
print()

print("Testing polynomial multiplication...")
test(b:multiplyDegree(4), "2x^6+1/12x^5+1/3x^4+0x^3+0x^2+0x^1+0x^0")
test(a:multiplyDegree(12), "5x^16+4x^15+3x^14+2x^13+1x^12+0x^11+0x^10+0x^9+0x^8+0x^7+0x^6+0x^5+0x^4+0x^3+0x^2+0x^1+0x^0")
test(c * c, "16x^2+96x^1+144x^0")
test(a * c, "20x^5+76x^4+60x^3+44x^2+28x^1+12x^0")
test(c * a, "20x^5+76x^4+60x^3+44x^2+28x^1+12x^0")
test(b * c, "8x^3+73/3x^2+7/3x^1+4x^0")
print()

-- Unfortunately operator overloading can only return one value, and we need to return two - the quotient and the remainder
print("Testing polynomial division...")
local q, r = a:divremainder(c)
test(q, "5/4x^3+-11/4x^2+9x^1+-53/2x^0")
test(r, "319x^0")

q, r = a:divremainder(b)
test(q, "5/2x^2+91/48x^1+1157/1152x^0")
test(r, "17755/13824x^1+2299/3456x^0")
print()

local x = Integer(3)
local y = Integer(-1) / Integer(6)

print("Testing combined polynomial/coefficient operations...")
test(a + x, "5x^4+4x^3+3x^2+2x^1+4x^0")
test(x + a, "5x^4+4x^3+3x^2+2x^1+4x^0")
test(b - y, "2x^2+1/12x^1+1/2x^0")
test(a * x, "15x^4+12x^3+9x^2+6x^1+3x^0")
test(x * a, "15x^4+12x^3+9x^2+6x^1+3x^0")
print()

print("Testing polynomial formal derrivatives...")
test(a:derrivative(), "20x^3+12x^2+6x^1+2x^0")
test(b:derrivative(), "4x^1+1/12x^0")
test(c:derrivative():derrivative(), "0x^0")
print()

local d = PolynomialRing({Integer(21), Integer(10), Integer(1)}, "x")
local e = PolynomialRing({Integer(-6), Integer(1), Integer(1)}, "x")

local f = PolynomialRing({Integer(-1), Integer(-2), Integer(15), Integer(36)}, "x")
local g = PolynomialRing({Integer(1), Integer(7), Integer(15), Integer(9)}, "x")

print("Testing polynomial gcd...")
test(PolynomialRing.gcd(d, e), "1x^1+3x^0")
test(PolynomialRing.gcd(b, c), "1x^0")
test(PolynomialRing.gcd(f, g), "1x^2+2/3x^1+1/9x^0")
print()

local h = PolynomialRing({Integer(2), Integer(3), Integer(1)}, "x")
local i = PolynomialRing({Integer(8), Integer(20), Integer(18), Integer(7), Integer(1)}, "x")
local j = PolynomialRing({Integer(108), Integer(324), Integer(387), Integer(238), Integer(80), Integer(14), Integer(1)}, "x")
local k = PolynomialRing({Integer(30), Integer(11), Integer(1)}, "x")
local l = PolynomialRing({Integer(6), Integer(11), Integer(6), Integer(1)}, "z")
local m = PolynomialRing({Integer(1), Integer(10), Integer(45), Integer(120), Integer(210), Integer(252), Integer(210), Integer(120), Integer(45), Integer(10), Integer(1)}, "x")
local n = PolynomialRing({Integer(24), Integer(50), Integer(35), Integer(10), Integer(1), Integer(0), Integer(24), Integer(50), Integer(35), Integer(10), Integer(1)}, "x")
local o = PolynomialRing({Integer(24), Integer(50), Integer(59), Integer(60), Integer(36), Integer(10), Integer(1)}, "x")
local p = PolynomialRing({Integer(-110592), Integer(59904), Integer(-5760), Integer(720), Integer(-48), Integer(1)}, "x")

print("Testing square-free factorization...")
test(h:squarefreefactorization(),  "(1 * (1x^2+3x^1+2x^0 ^ 1))")
test(i:squarefreefactorization(), "(1 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 3))")
test((Integer(2)*i):squarefreefactorization(), "(2 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 3))")
test(j:squarefreefactorization(), "(1 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 2) * (1x^1+3x^0 ^ 3))")
test(o:squarefreefactorization(), "(1 * (1x^6+10x^5+36x^4+60x^3+59x^2+50x^1+24x^0 ^ 1))")

-- local profiler = newProfiler()
-- profiler:start()

-- test(n:factor(), "(1 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 1) * (1x^2+0x^1+1x^0 ^ 1) * (1x^1+3x^0 ^ 1) * (1x^1+4x^0 ^ 1) * (1x^4+0x^3+-1x^2+0x^1+1x^0 ^ 1))")

-- profiler:stop()
-- local outfile = io.open( "profile.txt", "w+" )
-- profiler:report( outfile )
-- outfile:close()

print()

print("Testing factorization...")
test(c:factor(), "(4 * (1x^1+3x^0 ^ 1))", c)
test(h:factor(), "(1 * (1x^1+2x^0 ^ 1) * (1x^1+1x^0 ^ 1))", h)
test(k:factor(), "(1 * (1x^1+6x^0 ^ 1) * (1x^1+5x^0 ^ 1))", k)
test(j:factor(), "(1 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 2) * (1x^1+3x^0 ^ 3))", j)
test(p:factor(), "(1 * (1x^1+-24x^0 ^ 1) * (1x^2+-24x^1+48x^0 ^ 1) * (1x^2+0x^1+96x^0 ^ 1))", p)
test(l:factor(), "(1 * (1z^1+3z^0 ^ 1) * (1z^1+2z^0 ^ 1) * (1z^1+1z^0 ^ 1))", l)
test(m:factor(), "(1 * (1x^1+1x^0 ^ 10))", m)
test(b:factor(), "(1/12 * (24x^2+1x^1+4x^0 ^ 1))", b)
test(o:factor(), "(1 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 1) * (1x^2+0x^1+1x^0 ^ 1) * (1x^1+4x^0 ^ 1) * (1x^1+3x^0 ^ 1))", o)
test(n:factor(), "(1 * (1x^1+1x^0 ^ 1) * (1x^1+2x^0 ^ 1) * (1x^2+0x^1+1x^0 ^ 1) * (1x^1+3x^0 ^ 1) * (1x^1+4x^0 ^ 1) * (1x^4+0x^3+-1x^2+0x^1+1x^0 ^ 1))", n)