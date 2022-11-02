local g1 = parse("x^3+4*x^2-x-2"):topolynomial()
local f1 = parse("x^4-x^2"):topolynomial()

local g2 = parse("2*x^6-4*x^5+5*x^4-3*x^3+x^2+3*x"):topolynomial()
local f2 = parse("x^7-3*x^6+5*x^5-7*x^4+7*x^3-5*x^2+3*x-1"):topolynomial()

starttest("partial fraction decomposition")

testeq(PolynomialRing.partialfractions(g1, f1):autosimplify(), parse("((2 * (x ^ -2)) + (x ^ -1) + ((-1 + x) ^ -1) + (-1 * ((1 + x) ^ -1)))"))
testeq(PolynomialRing.partialfractions(g2, f2):autosimplify(), parse("(((-1 + x) ^ -3) + ((-1 + x) ^ -1) + ((1 + (x ^ 2)) ^ -2) + ((1 + x) * ((1 + (x ^ 2)) ^ -1)))"))

endtest()