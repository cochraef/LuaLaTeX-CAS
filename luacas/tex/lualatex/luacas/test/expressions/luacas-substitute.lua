local a = parse("3*(x+1)^1/2-6*y+3*z^2")
local b = parse("sin(e^x - 1) + e^x")

starttest("substitution")
testeq(a:substitute({[parse("x")] = Integer(3),
                   [parse("y")] = Integer(-1),
                   [parse("z")] = Integer(4)/Integer(3)}):autosimplify(), parse("52/3"))

testeq(b:substitute({[parse("e^x")] = parse("x^e")}), parse("((x ^ e) + sin((-1 + (x ^ e))))"))
endtest()