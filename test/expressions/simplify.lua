local a = SymbolExpression("x")*(SymbolExpression("y") + SymbolExpression("z"))
local b = SymbolExpression("x")*(Integer(1)+ SymbolExpression("z"))
local c = parse("((2*x+1)*(3*x-1)+6)*(6*y-z)")
local d = parse("(x+1)*(x+2)*(x+3)")

local e = parse("x*y*z+x^2")
local f = parse("x + 1/x^2")
local g = parse("e^x - e^x*x^2")

starttest("expression expansion")
test(a:expand(), "((x * y) + (x * z))", a)
test(b:expand(), "(x + (x * z))", b)
test(c:expand(), "((30 * y) + (6 * x * y) + (36 * (x ^ 2) * y) + (-5 * z) + (-1 * x * z) + (-6 * (x ^ 2) * z))", c)
test(d:expand(), "(6 + (11 * x) + (6 * (x ^ 2)) + (x ^ 3))")
endtest()

starttest("expression factoring beyond monovariate polynomials")
test(e:factor(), "(x * (x + (y * z)))")
test(f:factor(), "((x ^ -2) * (1 + x) * (1 + (-1 * x) + (x ^ 2)))")
test(g:factor(), "((e ^ x) * (1 + x) * (1 + (-1 * x)))")

endtest()