require("algebra._init")

local function test(expected, actual)
    if(tostring(expected) == tostring(actual)) then
        print("Result: " .. tostring(expected))
    else
        print("Result: ".. tostring(expected) .. " (Expected: " .. tostring(actual) .. ")")
    end
end

local a = BinaryOperation(BinaryOperation.ADD,
                                    {Integer(3),
                                    Integer(5)})

local b = BinaryOperation(BinaryOperation.MUL,
                                    {BinaryOperation(BinaryOperation.ADD,
                                        {Integer(13),
                                        Integer(12)}),
                                    Integer(-4)})

local c = BinaryOperation(BinaryOperation.DIV,
                                    {SymbolExpression("x"), SymbolExpression("y")})

local d = BinaryOperation(BinaryOperation.DIV,
                                    {BinaryOperation(BinaryOperation.ADD,
                                        {Integer(4),
                                        Integer(-3)}),
                                    SymbolExpression("y")})

local e = BinaryOperation(BinaryOperation.ADD,
                            {Integer(3),
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

local g = BinaryOperation(BinaryOperation.POW,
                                            {Integer(0),
                                            SymbolExpression("x")})

local h = BinaryOperation(BinaryOperation.POW,
                                            {Integer(1),
                                            SymbolExpression("x")})

local i = BinaryOperation(BinaryOperation.POW,
                                            {SymbolExpression("x"),
                                            Integer(0)})

local j = BinaryOperation(BinaryOperation.POW,
                                            {SymbolExpression("x"),
                                            Integer(1)})

local k = BinaryOperation(BinaryOperation.POW,
                                            {SymbolExpression("x"),
                                            SymbolExpression("y")})

local l = BinaryOperation(BinaryOperation.POW,
                                            {BinaryOperation(BinaryOperation.POW,
                                                {BinaryOperation(BinaryOperation.POW,
                                                    {SymbolExpression("x"),
                                                    Integer(3)}),
                                                Integer(4)}),
                                            Integer(5)})

local m = BinaryOperation(BinaryOperation.POW,
                                            {BinaryOperation(BinaryOperation.MUL,
                                                {SymbolExpression("x"),
                                                SymbolExpression("y")}),
                                            SymbolExpression("a")})


print("Testing exponent autosimplification...")
test(g:autosimplify(), "0")
test(h:autosimplify(), "1")
test(i:autosimplify(), "1")
test(j:autosimplify(), "x")
test(k:autosimplify(), "(x ^ y)")
test(l:autosimplify(), "(x ^ 60)")
test(m:autosimplify(), "((x ^ a) * (y ^ a))")
print()

local n = BinaryOperation(BinaryOperation.MUL,
                            {SymbolExpression("x"),
                             SymbolExpression("y"),
                             Integer(0),
                             Integer(-2)
                            })

local o = BinaryOperation(BinaryOperation.MUL,
                            {SymbolExpression("x"),
                            BinaryOperation(BinaryOperation.MUL,
                                {SymbolExpression("y"),
                                SymbolExpression("z")})})

local p = BinaryOperation(BinaryOperation.MUL,
                            {SymbolExpression("x")})

local q = BinaryOperation(BinaryOperation.MUL,
                            {SymbolExpression("x"), SymbolExpression("x"), SymbolExpression("x"), SymbolExpression("x")})

local r = BinaryOperation(BinaryOperation.MUL,
                            {SymbolExpression("x"), Integer(3), SymbolExpression("a")})

print("Testing product autosimplification...")
test(n:autosimplify(), 0)
test(o:autosimplify(), "(x * y * z)")
test(p:autosimplify(), "x")
test(q:autosimplify(), "(x ^ 4)")
test(r:autosimplify(), "(3 * a * x)")
print()

local s = BinaryOperation(BinaryOperation.ADD,
                            {SymbolExpression("x")})

local t = BinaryOperation(BinaryOperation.ADD,
                            {SymbolExpression("x"),
                                BinaryOperation(BinaryOperation.ADD,
                                    {Integer(3),
                                    SymbolExpression("y")})})

local u = BinaryOperation(BinaryOperation.ADD,
                            {BinaryOperation(BinaryOperation.MUL,
                                {SymbolExpression("x"),
                                SymbolExpression("y")}),
                            BinaryOperation(BinaryOperation.MUL,
                                {SymbolExpression("y"),
                                 SymbolExpression("x")})})

print("Testing sum autosimplification...")
test(s:autosimplify(), "x")
test(t:autosimplify(), "3 + x + y")
test(u:autosimplify(), "(2 * x * y)")