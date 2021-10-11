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

local a = BinaryOperation.ADDEXP
                ({Integer(3),
                Integer(5)})

local b = BinaryOperation.MULEXP
                ({BinaryOperation.ADDEXP
                    ({Integer(13),
                    Integer(12)}),
                Integer(-4)})

local c = BinaryOperation.DIVEXP
                ({SymbolExpression("x"),
                SymbolExpression("y")})

local d = BinaryOperation.DIVEXP
            ({BinaryOperation.ADDEXP
                ({Integer(4),
                Integer(-3)}),
            SymbolExpression("y")})

local e = BinaryOperation.ADDEXP
                            ({Integer(3),
                            Integer(4),
                            Integer(5),
                            Integer(6)})

print("Testing expression construction...")
test(a, "(3 + 5)")
test(b, "((13 + 12) * -4)")
test(c, "(x / y)")
test(d, "((4 + -3) / y)")
test(e, "(3 + 4 + 5 + 6)")
print()

print("Testing expression evaluation...")
test(a:evaluate(), 8)
test(b:evaluate(), -100)
test(c:evaluate(), "(x / y)")
test(d:evaluate(), "(1 / y)")
test(e:evaluate(), "18")
print()

print("Testing expression substitution...")
test(a:substitute({x=Integer(3)}), "(3 + 5)")
test(b:substitute({x=Integer(3)}), "((13 + 12) * -4)")
test(c:substitute({x=Integer(3)}), "(3 / y)")
test(d:substitute({x=Integer(3)}), "((4 + -3) / y)")
test(c:substitute({x=Integer(3),y=Integer(-2)}), "(3 / -2)")
test(c:substitute({x=Integer(3),y=Integer(-2)}):evaluate(), "-3/2")
print()

local f = PolynomialRing({Integer(6), Integer(5), Integer(1)}, "x")

print("Testing polynomial expressions...")
test(f, "1x^2+5x^1+6x^0")
test(f:toCompoundExpression(), "((6 * (x ^ 0)) + (5 * (x ^ 1)) + (1 * (x ^ 2)))")
test(f:evaluate(), "1x^2+5x^1+6x^0")
test(f:substitute({x=Integer(1)}), "((6 * (1 ^ 0)) + (5 * (1 ^ 1)) + (1 * (1 ^ 2)))")
test(f:substitute({x=Integer(1)}):evaluate(), 12)
print()

local g = BinaryOperation.POWEXP
            ({Integer(0),
            SymbolExpression("x")})

local h = BinaryOperation.POWEXP
            ({Integer(1),
            SymbolExpression("x")})

local i = BinaryOperation.POWEXP
            ({SymbolExpression("x"),
            Integer(0)})

local j = BinaryOperation.POWEXP
            ({SymbolExpression("x"),
            Integer(1)})

local k = BinaryOperation.POWEXP
            ({SymbolExpression("x"),
            SymbolExpression("y")})

local l = BinaryOperation.POWEXP
            ({BinaryOperation.POWEXP
                ({BinaryOperation.POWEXP
                    ({SymbolExpression("x"),
                    Integer(3)}),
                Integer(4)}),
            Integer(5)})

local m = BinaryOperation.POWEXP
            ({BinaryOperation.MULEXP
                ({SymbolExpression("x"),
                SymbolExpression("y")}),
            SymbolExpression("a")})


print("Testing exponent autosimplification...")
test(g:autosimplify(), "0", g)
test(h:autosimplify(), "1", h)
test(i:autosimplify(), "1", i)
test(j:autosimplify(), "x", j)
test(k:autosimplify(), "(x ^ y)", k)
test(l:autosimplify(), "(x ^ 60)", l)
test(m:autosimplify(), "((x ^ a) * (y ^ a))", m)
print()

local n = BinaryOperation.MULEXP
            ({SymbolExpression("x"),
            SymbolExpression("y"),
            Integer(0),
            Integer(-2)
            })

local o = BinaryOperation.MULEXP
            ({SymbolExpression("x"),
            BinaryOperation.MULEXP
                ({SymbolExpression("y"),
                SymbolExpression("z")})})

local p = BinaryOperation.MULEXP
            ({SymbolExpression("x")})

local q = BinaryOperation.MULEXP
            ({SymbolExpression("x"), SymbolExpression("x"), SymbolExpression("x"), SymbolExpression("x")})

local r = BinaryOperation.MULEXP
            ({SymbolExpression("x"), Integer(3), SymbolExpression("a")})

print("Testing product autosimplification...")
test(n:autosimplify(), 0, n)
test(o:autosimplify(), "(x * y * z)", o)
test(p:autosimplify(), "x", p)
test(q:autosimplify(), "(x ^ 4)", q)
test(r:autosimplify(), "(3 * a * x)", r)
print()

local s = BinaryOperation.ADDEXP
            ({SymbolExpression("x")})

local t = BinaryOperation.ADDEXP
            ({SymbolExpression("x"),
                BinaryOperation.ADDEXP
                    ({Integer(3),
                    SymbolExpression("y")})})

local u = BinaryOperation.ADDEXP
        ({BinaryOperation.MULEXP
            ({SymbolExpression("x"),
            SymbolExpression("y")}),
        BinaryOperation.MULEXP
            ({SymbolExpression("y"),
                SymbolExpression("x")})})

local v = BinaryOperation.ADDEXP
            ({Integer(3),
            BinaryOperation.ADDEXP
                ({BinaryOperation.MULEXP
                    ({Integer(2),
                    BinaryOperation.POWEXP
                        ({SymbolExpression("x"),
                        Integer(2)})}),
                BinaryOperation.ADDEXP
                    ({BinaryOperation.MULEXP
                        ({Integer(1),
                        SymbolExpression("y")}),
                    BinaryOperation.MULEXP
                        ({Integer(0),
                        SymbolExpression("x")})})}),
            Integer(6)})

print("Testing sum autosimplification...")
test(s:autosimplify(), "x", s)
test(t:autosimplify(), "(3 + x + y)", t)
test(u:autosimplify(), "(2 * x * y)", u)
test(v:autosimplify(), "(9 + (2 * (x ^ 2)) + y)", v)
print()

local w = BinaryOperation.MULEXP
            ({BinaryOperation.DIVEXP
                ({Integer(1),
                SymbolExpression("x")}),
            SymbolExpression("x")})

local x = BinaryOperation.MULEXP
            ({BinaryOperation.DIVEXP
                ({SymbolExpression("y"),
                SymbolExpression("x")}),
            BinaryOperation.DIVEXP
                ({SymbolExpression("x"),
                SymbolExpression("y")})})

local y = BinaryOperation.MULEXP
    ({BinaryOperation.DIVEXP
        ({Integer(1),
        Integer(3)}),
    SymbolExpression("x")})

print("Testing quotient autosimplification...")
test(w:autosimplify(), "1", w)
test(x:autosimplify(), "1", x)
test(y:autosimplify(), "(1/3 * x)", y)
print()

local z = BinaryOperation.ADDEXP
            ({SymbolExpression("x"),
            SymbolExpression("y"),
            BinaryOperation.SUBEXP
                ({SymbolExpression("x"),
                SymbolExpression("y")})})

print("Testing difference autosimplification...")
test(z:autosimplify(), "(2 * x)", z)
print()

-- I am kind of impressed this works this fast
print("--- MEGA TEST ---")
local AAAAAAAAAAAAA = BinaryOperation.ADDEXP
          ({a, b, c, d, e, f, g, h, i, j, k, l, n, m, o, p, q, r, s, t, u, v, w, x, y, z})

print(AAAAAAAAAAAAA:autosimplify())
print("")

print("Testing metamethod expressions...")

local aa = SymbolExpression("x") + SymbolExpression("y") + SymbolExpression("z")

local ab = -(SymbolExpression("x") / SymbolExpression("y"))

test(aa, "((x + y) + z)")
test(aa:autosimplify(), "(x + y + z)", aa)

test(ab, "(- (x / y))")
test(ab:autosimplify(), "(-1 * x * (y ^ -1))", ab)