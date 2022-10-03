local x = SymbolExpression("x")
local ex = parse("e^x")
local lnx = parse("ln(x)")

local a = parse("y^2")
local b = parse("x + y + 1")
local c = parse("x*(y+1)+x+3*x*y^2")
local d = parse("x^2+2*x*y+y^2+x")
local e = parse("(x*y+x)^2+x^2")
local f = parse("-x^2/e^x-2*x/e^x-2/e^x+x^2*e^x-2*x*e^x+2*e^x")
local g = parse("x^(-2)+y*x^(-2)+z*x^2+2*x^2")
local h = parse("a*ln(x)-ln(x)*x-x")


starttest("collect method")

testeq(a:collect(x), parse("y^2"), a)
testeq(b:collect(x), parse("x + y + 1"), b)
testeq(c:collect(x), parse("(3*y^2+y+2)*x"), c)
testeq(d:collect(x), parse("x^2+(2*y+1)*x+y^2"), d)
testeq(e:collect(x), parse("((y+1)^2+1)*x^2"), e)
testeq(f:collect(ex), parse("(x^2-2*x+2)*e^x+(-x^2-2*x-2)/e^x"), f)
testeq(g:collect(x), parse("(y+1)*x^(-2)+(z+2)*x^2"), g)
testeq(h:collect(lnx), parse("(a-x)*ln(x)-x"), h)

endtest()