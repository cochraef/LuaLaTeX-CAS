
local a = PolynomialRing({
    Integer(1),
    Integer(2),
    Integer(3),
    Integer(4),
    Integer(5)
}, "x")

local b = PolynomialRing({
    Integer(1) / Integer(3),
    Integer(1) / Integer(12),
    Integer(6) / Integer(3),
}, "x")

local c = PolynomialRing({
    Integer(12),
    Integer(4)
}, "x")

local h = PolynomialRing({Integer(2), Integer(3), Integer(1)}, "x")
local i = PolynomialRing({Integer(8), Integer(20), Integer(18), Integer(7), Integer(1)}, "x")
local j = PolynomialRing({Integer(108), Integer(324), Integer(387), Integer(238), Integer(80), Integer(14), Integer(1)}, "x")
local k = PolynomialRing({Integer(30), Integer(11), Integer(1)}, "x")
local l = PolynomialRing({Integer(6), Integer(11), Integer(6), Integer(1)}, "z")
local m = PolynomialRing({Integer(1), Integer(10), Integer(45), Integer(120), Integer(210), Integer(252), Integer(210), Integer(120), Integer(45), Integer(10), Integer(1)}, "x")
local n = PolynomialRing({Integer(24), Integer(50), Integer(35), Integer(10), Integer(1), Integer(0), Integer(24), Integer(50), Integer(35), Integer(10), Integer(1)}, "x")
local o = PolynomialRing({Integer(24), Integer(50), Integer(59), Integer(60), Integer(36), Integer(10), Integer(1)}, "x")
local p = PolynomialRing({Integer(-110592), Integer(59904), Integer(-5760), Integer(720), Integer(-48), Integer(1)}, "x")

local d = PolynomialRing({Integer(21), Integer(10), Integer(1)}, "x")
local e = PolynomialRing({Integer(-6), Integer(1), Integer(1)}, "x")

local f = PolynomialRing({Integer(-1), Integer(-2), Integer(15), Integer(36)}, "x")
local g = PolynomialRing({Integer(1), Integer(7), Integer(15), Integer(9)}, "x")

local q = PolynomialRing({Integer(3), Integer(-9), Integer(27), Integer(-36), Integer(36)}, "z")
local r = PolynomialRing({Integer(0), Integer(0), Integer(0), Integer(0), Integer(0), Integer(0), Integer(4)}, "x");
local s = PolynomialRing({Integer(1), Integer(0), Integer(-4), Integer(0), Integer(1)}, "x")

local x = Integer(3)
local y = Integer(-1) / Integer(6)

local multia = PolynomialRing({Integer(4),
                    Integer(0),
                    PolynomialRing({Integer(0), Integer(0), Integer(-6)}, "y"),
                    PolynomialRing({Integer(1), Integer(3)}, "y")}, "x")
local multib = PolynomialRing({PolynomialRing({Integer(0), Integer(6)}, "y"),
                            Integer(0),
                            PolynomialRing({Integer(-4), Integer(12)}, "y")}, "x")

starttest("polynomial construction")
testeq(a, "5x^4+4x^3+3x^2+2x^1+1x^0")
testeq(a.degree, 4)
testeq(b, "2x^2+1/12x^1+1/3x^0")
testeq(b.degree, 2)
testeq(multia, "(3y^1+1y^0)x^3+(-6y^2+0y^1+0y^0)x^2+(0)x^1+(4)x^0")
testeq(multia.degree, 3)
endtest()

starttest("polynomial-expression conversion")
testeq(a:tocompoundexpression():autosimplify():topolynomial(), a)
testeq(b:tocompoundexpression():autosimplify():topolynomial(), b)
testeq(c:tocompoundexpression():autosimplify():topolynomial(), c)
endtest()

starttest("polynomial arithmetic")
testeq(a + a, "10x^4+8x^3+6x^2+4x^1+2x^0")
testeq(a + b, "5x^4+4x^3+5x^2+25/12x^1+4/3x^0")
testeq(b + a, "5x^4+4x^3+5x^2+25/12x^1+4/3x^0")
testeq(a - a, "0x^0")
testeq(a - b, "5x^4+4x^3+1x^2+23/12x^1+2/3x^0")
testeq(b:multiplyDegree(4), "2x^6+1/12x^5+1/3x^4+0x^3+0x^2+0x^1+0x^0")
testeq(a:multiplyDegree(12), "5x^16+4x^15+3x^14+2x^13+1x^12+0x^11+0x^10+0x^9+0x^8+0x^7+0x^6+0x^5+0x^4+0x^3+0x^2+0x^1+0x^0")
testeq(c * c, "16x^2+96x^1+144x^0")
testeq(a * c, "20x^5+76x^4+60x^3+44x^2+28x^1+12x^0")
testeq(c * a, "20x^5+76x^4+60x^3+44x^2+28x^1+12x^0")
testeq(b * c, "8x^3+73/3x^2+7/3x^1+4x^0")
local qq, rr = a:divremainder(c)
testeq(qq, "5/4x^3+-11/4x^2+9x^1+-53/2x^0")
testeq(rr, "319x^0")
qq, rr = a:divremainder(b)
testeq(qq, "5/2x^2+91/48x^1+1157/1152x^0")
testeq(rr, "17755/13824x^1+2299/3456x^0")
endtest()

starttest("polynomial pseudodivision")
local pq, pr = a:pseudodivide(c)
testeq(pq, "320x^3+-704x^2+2304x^1+-6784x^0")
testeq(pr, "81664x^0")

pq, pr = multia:pseudodivide(multib)
testeq(pq, "(36y^2+0y^1+-4y^0)x^1+(-72y^3+24y^2+0y^1+0y^0)x^0")
testeq(pr, "(-216y^3+0y^2+24y^1+0y^0)x^1+(432y^4+-144y^3+576y^2+-384y^1+64y^0)x^0")
endtest()


starttest("combined polynomial/coefficient operations")
testeq(a + x, "5x^4+4x^3+3x^2+2x^1+4x^0")
testeq(x + a, "5x^4+4x^3+3x^2+2x^1+4x^0")
testeq(b - y, "2x^2+1/12x^1+1/2x^0")
testeq(a * x, "15x^4+12x^3+9x^2+6x^1+3x^0")
testeq(x * a, "15x^4+12x^3+9x^2+6x^1+3x^0")
endtest()

starttest("polynomial formal derivatives")
testeq(a:derivative(), "20x^3+12x^2+6x^1+2x^0")
testeq(b:derivative(), "4x^1+1/12x^0")
testeq(c:derivative():derivative(), "0x^0")
endtest()


starttest("polynomial gcd...")
testeq(PolynomialRing.gcd(d, e), "1x^1+3x^0")
testeq(PolynomialRing.gcd(b, c), "1x^0")
testeq(PolynomialRing.gcd(f, g), "1x^2+2/3x^1+1/9x^0")
endtest()

starttest("square-free factorization")
testeq(h:squarefreefactorization():autosimplify(),  parse("(2 + (3 * x) + (x ^ 2))"), h)
testeq(i:squarefreefactorization():autosimplify(), parse("((1 + x) * ((2 + x) ^ 3))"), i)
testeq((Integer(2)*i):squarefreefactorization():autosimplify(), parse("(((2 + x) ^ 3) * (2 + (2 * x)))"), (Integer(2)*i), true)
testeq(j:squarefreefactorization():autosimplify(), parse("((1 + x) * ((2 + x) ^ 2) * ((3 + x) ^ 3))"), j)
testeq(o:squarefreefactorization():autosimplify(), parse("(24 + (50 * x) + (59 * (x ^ 2)) + (60 * (x ^ 3)) + (36 * (x ^ 4)) + (10 * (x ^ 5)) + (x ^ 6))"), o)
endtest()

starttest("polynomial factorization")
testeq(c:factor(), BinaryOperation.MULEXP({Integer(4), BinaryOperation.POWEXP({PolynomialRing({Integer(3), Integer(1)}, "x"), Integer(1)})}), c)
testeq(h:factor():autosimplify(), parse("((1 + x) * (2 + x))"), h)
testeq(k:factor():autosimplify(), parse("((5 + x) * (6 + x))"), k)
testeq(j:factor():autosimplify(), parse("((1 + x) * ((2 + x) ^ 2) * ((3 + x) ^ 3))"), j)
testeq(p:factor():autosimplify(), parse("((-24 + x) * (96 + (x ^ 2)) * (48 + (-24 * x) + (x ^ 2)))"), p)
testeq(l:factor():autosimplify(), parse("((1 + z) * (2 + z) * (3 + z))"), l)
testeq(m:factor():autosimplify(), parse("((1 + x) ^ 10)"), m)
testeq(b:factor(), BinaryOperation.MULEXP({Integer(1)/Integer(12), BinaryOperation.POWEXP({PolynomialRing({Integer(4), Integer(1), Integer(24)}, "x"), Integer(1)})}), b)
testeq(o:factor():autosimplify(), parse("((1 + x) * (2 + x) * (3 + x) * (4 + x) * (1 + (x ^ 2)))"), o)
testeq(n:factor():autosimplify(), parse("((1 + x) * (2 + x) * (3 + x) * (4 + x) * (1 + (x ^ 2)) * (1 + (-1 * (x ^ 2)) + (x ^ 4)))"), n)
endtest()

starttest("polynomial decomposition")
testeq(c:decompose(), "{4x^1+12x^0}", c, true)
testeq(h:decompose(), "{1x^2+3x^1+2x^0}", h, true)
testeq(k:decompose(), "{1x^2+11x^1+30x^0}", k, true)
testeq(j:decompose(), "{1x^6+14x^5+80x^4+238x^3+387x^2+324x^1+108x^0}", j, true)
testeq(l:decompose(), "{1z^3+6z^2+11z^1+6z^0}", l, true)
testeq(m:decompose(), "{1x^5+5x^4+10x^3+10x^2+5x^1+1x^0, 1x^2+2x^1+0x^0}", m, true)
testeq(b:decompose(), "{2x^2+1/12x^1+1/3x^0}", b, true)
testeq(o:decompose(), "{1x^6+10x^5+36x^4+60x^3+59x^2+50x^1+24x^0}", o, true)
testeq(n:decompose(), "{1x^10+10x^9+35x^8+50x^7+24x^6+0x^5+1x^4+10x^3+35x^2+50x^1+24x^0}", n, true)
testeq(q:decompose(), "{36z^2+18z^1+3z^0, 1z^2+-1/2z^1+0z^0}", q, true)
testeq(r:decompose(),"{4x^3+0x^2+0x^1+0x^0, 1x^2+0x^1+0x^0}", r, true)
testeq(s:decompose(), "{1x^2+4x^1+1x^0, 1x^2+0x^1+-4x^0}", s, true)
endtest()