local a = LN(SymbolExpression("x"))
local b = LN(BinaryOperation.POWEXP({E, SymbolExpression("x")}))
local c = BinaryOperation.POWEXP({Integer(2), LOG(Integer(2), SymbolExpression("y"))})


starttest("logarithms")
test(a, "log(e, x)")
test(a:autosimplify(), "log(e, x)", a)
test(b:autosimplify(), "x", b)
test(c:autosimplify(), "y", c)
endtest()