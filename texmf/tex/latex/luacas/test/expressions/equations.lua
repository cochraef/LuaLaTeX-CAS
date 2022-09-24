local a = Equation(parse("2^x"), parse("1"))
local b = Equation(parse("x^2+2*x+1"), parse("0"))
local c = Equation(parse("2*x^x"), parse("3*y"))
local d = Equation(parse("e^x+1"), parse("y"))
local e = Equation(parse("z*sin(x/2)"), parse("4"))
local f = Equation(parse("4"), parse("0"))


starttest("equation solving")
testeq(a:solvefor(parse("x")), Equation(parse("x"), parse("0")), a)
testeq(b:solvefor(parse("x")), Equation(parse("x"), parse("-1")), b) -- This will need to be fixed once set expressions are woring
testeq(c:solvefor(parse("x")), Equation(parse("x^x"), parse("3/2*y")), c)
testeq(c:solvefor(parse("y")), Equation(parse("y"), parse("2/3*x^x")), c)
testeq(d:solvefor(parse("x")), Equation(parse("x"), parse("ln(y - 1)")), d)
testeq(e:solvefor(parse("x")), Equation(parse("x"), parse("2*arcsin(4/z)")), e)
testeq(f:autosimplify(), "false", f) -- Same, with boolean expressions
endtest()