local a = SymbolExpression("x")*(SymbolExpression("y") + SymbolExpression("z"))
local b = SymbolExpression("x")*(Integer(1)+ SymbolExpression("z"))
local c = parse("((2*x+1)*(3*x-1)+6)*(6*y-z)")

starttest("expression expansion")
test(a:expand(), "((x * y) + (x * z))", a)
test(b:expand(), "(x + (x * z))", b)
test(c:expand(), "((30 * y) + (6 * x * y) + (36 * (x ^ 2) * y) + (-5 * z) + (-1 * x * z) + (-6 * (x ^ 2) * z))", c)
endtest()