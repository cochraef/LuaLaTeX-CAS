local a = LN(SymbolExpression("x"))
local b = LN(BinaryOperation.POWEXP({E, SymbolExpression("x")}))
local c = BinaryOperation.POWEXP({Integer(2), LOG(Integer(2), SymbolExpression("y"))})


starttest("logarithms")
testeq(a, "log(e, x)")
testeq(a:autosimplify(), "log(e, x)", a)
testeq(b:autosimplify(), "x", b)
testeq(c:autosimplify(), "y", c)
endtest()