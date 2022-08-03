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

starttest("expression construction")
testeq(a, "(3 + 5)")
testeq(b, "((13 + 12) * -4)")
testeq(c, "(x / y)")
testeq(d, "((4 + -3) / y)")
testeq(e, "(3 + 4 + 5 + 6)")
endtest()

starttest("expression evaluation...")
testeq(a:evaluate(), 8)
testeq(b:evaluate(), -100)
testeq(c:evaluate(), "(x / y)")
testeq(d:evaluate(), "(1 / y)")
testeq(e:evaluate(), "18")
endtest()

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

local z = BinaryOperation.ADDEXP
    ({SymbolExpression("x"),
    SymbolExpression("y"),
    BinaryOperation.SUBEXP
        ({SymbolExpression("x"),
        SymbolExpression("y")})})

local A = dparse("(-aa-x)+(x+aa)");

starttest("expression autosimplification")
testeq(g:autosimplify(), "0", g)
testeq(h:autosimplify(), "1", h)
testeq(i:autosimplify(), "1", i)
testeq(j:autosimplify(), "x", j)
testeq(k:autosimplify(), "(x ^ y)", k)
testeq(l:autosimplify(), "(x ^ 60)", l)
testeq(m:autosimplify(), "((x * y) ^ a)", m)
testeq(n:autosimplify(), 0, n)
testeq(o:autosimplify(), "(x * y * z)", o)
testeq(p:autosimplify(), "x", p)
testeq(q:autosimplify(), "(x ^ 4)", q)
testeq(r:autosimplify(), "(3 * a * x)", r)
testeq(s:autosimplify(), "x", s)
testeq(t:autosimplify(), "(3 + x + y)", t)
testeq(u:autosimplify(), "(2 * x * y)", u)
testeq(v:autosimplify(), "(9 + (2 * (x ^ 2)) + y)", v)
testeq(w:autosimplify(), "1", w)
testeq(x:autosimplify(), "1", x)
testeq(y:autosimplify(), "(1/3 * x)", y)
testeq(z:autosimplify(), "(2 * x)", z)
testeq(A:autosimplify(), "0", A)
endtest()


local aa = SymbolExpression("x") + SymbolExpression("y") + SymbolExpression("z")
local ab = -(SymbolExpression("x") / SymbolExpression("y"))
local ac = Integer(2)*SymbolExpression("x")*SymbolExpression("y") - Integer(3)*SymbolExpression("x")*SymbolExpression("z")

starttest("metamethod expressions")

testeq(aa, "((x + y) + z)")
testeq(aa:autosimplify(), "(x + y + z)", aa)
testeq(ab, "(- (x / y))")
testeq(ab:autosimplify(), "(-1 * x * (y ^ -1))", ab)
testeq(ac:autosimplify(), "((2 * x * y) + (-3 * x * z))", ac)

endtest()