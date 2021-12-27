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

-- Integer Testing
local a = Integer(5)
local b = Integer(3)
local c = Integer(-12)
local d = Integer("-54321")
local e = Integer("99989999999999999989999999999999999999999999999999999999989999999999999999999999999998999999999999999999999999989999999998")
local f = Integer("-1267650600228229401496703205376")

print("Testing integer construction...")
test(a, 5)
test(b, 3)
test(c, -12)
test(d, "-54321")
test(e, "99989999999999999989999999999999999999999999999999999999989999999999999999999999999998999999999999999999999999989999999998")
test(f, "-1267650600228229401496703205376")
print()

print("Testing integer operations...")
test(-c, 12)
test(a + b, 8)
test(b - c, 15)
test(d - d, 0)
test(e + f, "99989999999999999989999999999999999999999999999999999999989999999999999999999999999998999998732349399771770598493296794622")
print()

test(a * c, -60)
test(f * f, "1606938044258990275541962092341162602522202993782792835301376")
test(e * f, "-126752383516820657842978847503263945985032967946239999999987323493997717705985032967944972349399771770598503296781947493995182404784576509143246593589248")
print()

test(a // b, 1)
test(a % b, 2)
test(f // d, "23336289836862896513258283")
test(f % d, "-14533")
test(e // -f, "78878201913048970415230130190415677050906625793723347950240237316957169209243093407705758276")
test(e % -f, "1011644662020502370048160308222")
print()

test(c ^ a, -248832)
test(d ^ a, "-472975648731213834575601")
print()

print("Testing integer comparisons...")
test(a == b, false)
test(b < a, true)
test(a <= a, true)
test(f < d, true)
test(e <= f, false)
print()

local g = Integer(16)

print("Testing integer conversions...")
test(a / b, "5/3")
test(g / c, "-4/3")
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

local g = Integer(8)

print("Testing combined integer/rational comparisons...")
test(a/g == x, false)
test(g/a == x, true)
test(y < b , true)
test(b < y, false)
print()

local f = Integer(3)
local g = Integer(216)
local h = Integer(945)
local i = Integer("7766999")
local j = Integer(4)
local k = Integer(8)
local m = Integer(16)
local n = Integer(100000000003)
local o = Integer(200250077)

print("Testing Miller-Rabin Primes...")
test(f:isprime(), true, f)
test(g:isprime(), false, g)
test(h:isprime(), false, h)
test(i:isprime(), false, i)

-- local profiler = newProfiler()
-- profiler:start()

test(n:isprime(), true, n)

-- profiler:stop()
-- local outfile = io.open( "profile.txt", "w+" )
-- profiler:report( outfile )
-- outfile:close()

test(o:isprime(), false, o)
print()


print("Testing Pollard Rho Algorithm...")
test(f:findafactor(), 3, f)
test(g:findafactor(), 2, g)
test(h:findafactor(), 3, h)
test(i:findafactor(), 41, i)
test(j:findafactor(), 2, j)
test(k:findafactor(), 2, k)
test(m:findafactor(), 2, m)
print()

print("Testing Prime Factorization...")
test(f:primefactorization(), "(* (3 ^ 1))", f)
test(g:primefactorization(), "((2 ^ 3) * (3 ^ 3))", g)
test(h:primefactorization(), "((3 ^ 3) * (5 ^ 1) * (7 ^ 1))", h)
test(i:primefactorization(), "((41 ^ 1) * (189439 ^ 1))", i)


-- local profiler = newProfiler()
-- profiler:start()

test(o:primefactorization(), "((10007 ^ 1) * (20011 ^ 1))", o)

-- profiler:stop()
-- local outfile = io.open( "profile.txt", "w+" )
-- profiler:report( outfile )
-- outfile:close()