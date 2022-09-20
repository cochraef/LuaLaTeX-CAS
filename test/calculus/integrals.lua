local a = dparse("int(x^2, x)")
local b = dparse("int(x^-1, x, 1, e)")
local c = dparse("int(3*x^2+2*x+6, x)")
local d = dparse("int(sin(x)*cos(x), x)")
local e = dparse("int(2*x*cos(x^2), x)")
local f = dparse("int(sin(2*x), x)")
local g = dparse("int(e^sin(x), x)")
local h = dparse("int((1 / (1 + (1 / x))), x)")
local i = dparse("int(e^(x^(1/2)), x)")
local j = dparse("int((x^3+1)/(x-2), x)")
local k = dparse("int((x^2-x+1)/(x^3+3*x^2+3*x+1), x)")
local l = dparse("int(1 / (x^3+6*x), x)")
local m = dparse("int(1/(x^2+x+1), x)")
local n = dparse("int(1/(x^3+2*x+2), x, 0, 1)")

local o = dparse("int(x^2*e^x, x)")
local p = dparse("int((x^2+6*x+3)*sin(x), x)")
local q = dparse("int(x*e^x*sin(x),x)")
local r = dparse("int(cos(x)^3, x)")

starttest("integration")
testeq(a, dparse("int(x ^ 2, x)"))
testeq(a:autosimplify(), parse("x^3/3"), a)
testeq(b:autosimplify(), parse("1"), b)
testeq(c:autosimplify(), parse("x^3+x^2+6*x"), c)
testeq(d:autosimplify(), parse("(-1/2 * (cos(x) ^ 2))"), d)
testeq(e:autosimplify(), parse("sin((x ^ 2))"), e)
testeq(f:autosimplify(), parse("(-1/2 * cos((2 * x)))"), f)
testeq(g:autosimplify(), dparse("int(e ^ (sin(x)), x)"), g)
testeq(h:autosimplify(), dparse("int(1 / (1 + (1 / x)), x)"), h)
testeq(i:autosimplify(), parse("-2 * (e ^ (x ^ (1/2))) + 2 * (e ^ (x ^ (1/2))) * (x ^ (1/2))"), i)
testeq(j:autosimplify(), parse("((4 * x) + (x ^ 2) + (1/3 * (x ^ 3)) + (9 * log(e, (-2 + x))))"), j)
testeq(k:autosimplify(), parse("((-3/2 * ((1 + x) ^ -2)) + (3 * ((1 + x) ^ -1)) + log(e, (1 + x)))"), k)
testeq(l:autosimplify(), parse("((1/6 * log(e, x)) + (-1/12 * log(e, (6 + (x ^ 2)))))"), l)
testeq(m:autosimplify(), parse("2/3 * (3 ^ (1/2)) * (arctan((3 ^ (1/2)) * (1/3 + (2/3 * x))))"), m)
-- test(n:autosimplify(), [[((((6 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (1/420 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)))
-- * log(e, (18 * (((-6 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2) * (((-18 * ((-264600 + (1/2
-- * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/140 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)) + (12 * (((-6 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2))) ^ -1)))) + (((6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((-1/840 + (1/840 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) * log(e, (18 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((1/840 + (-1/840 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2) * (((-18 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((1/280 + (-1/280 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)) + (12 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((1/840 + (-1/840 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2))) ^ -1)))) + (((6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (1/420 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) * log(e, (18 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2) * (((-18 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/140 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)) + (12 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2))) ^ -1)))) + (((-6 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) * log(e, (1 + (18 * (((-6 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2) * (((-18 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/140 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)) + (12 * (((-6 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2))) ^ -1))))) + (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((1/840 + (-1/840 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) * log(e, (1 + (18 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((1/840 + (-1/840 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2) * (((-18 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + ((1/280 + (-1/280 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)) + (12 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -1) * ((-264600 + (1/2 * (216040608000
-- ^ 1/2))) ^ -1/3)) + ((1/840 + (-1/840 * (-3 ^ 1/2))) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2))) ^ -1))))) + (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) *
-- ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) * log(e, (1 + (18 *
-- (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2) * (((-18 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/140 * ((-1/2 + (1/2 * (-3 ^ 1/2)))
-- ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3)) + (12 * (((-6 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ -2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ -1/3)) + (-1/420 * ((-1/2 + (1/2 * (-3 ^ 1/2))) ^ 2) * ((-264600 + (1/2 * (216040608000 ^ 1/2))) ^ 1/3))) ^ 2))) ^ -1))))))]], n)

testeq(o:autosimplify(), parse("((2 * (e ^ x)) + (-2 * (e ^ x) * x) + ((e ^ x) * (x ^ 2)))"), o)
testeq(p:autosimplify(), parse("((2 * cos(x)) + ((-3 + (-6 * x) + (-1 * (x ^ 2))) * cos(x)) + ((6 + (2 * x)) * sin(x)))"), p)
testeq(q:autosimplify(), parse("(1/2 * (e ^ x) * (cos(x))) + (-1/2 * (e ^ x) * x * (cos(x))) + (1/2 * (e ^ x) * x * (sin(x)))"), q)
testeq(r:autosimplify(), parse("((3/4 * sin(x)) + (1/12 * sin((3 * x))))"), r)
endtest()