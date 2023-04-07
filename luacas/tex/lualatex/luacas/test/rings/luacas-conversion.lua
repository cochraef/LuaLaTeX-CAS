local a = Integer(12)
local b = Integer(3) / Integer(2)
local c = IntegerModN(Integer(4), Integer(7))
local d = IntegerModN(Integer(8), Integer(14))
local e = PolynomialRing({Integer(6), Integer(0), Integer(3)}, SymbolExpression("x"))
local f = PolynomialRing({Integer(4)/Integer(5), Integer(12)}, SymbolExpression("x"))
local g = PolynomialRing({
                PolynomialRing({
                    PolynomialRing({Integer(-4), Integer(12), Integer(1)}, SymbolExpression("x")),
                    PolynomialRing({Integer(0)}, SymbolExpression("x")),
                    PolynomialRing({Integer(8)}, SymbolExpression("x"))
                },
                SymbolExpression("y")),
                PolynomialRing({
                    PolynomialRing({Integer(8), Integer(7), Integer(6), Integer(5)}, SymbolExpression("x")),
                    PolynomialRing({Integer(-1)}, SymbolExpression("x")),
                },
                SymbolExpression("y")),
                PolynomialRing({
                    PolynomialRing({Integer(0)}, SymbolExpression("x")),
                    PolynomialRing({Integer(2), Integer(8), Integer(1)}, SymbolExpression("x")),
                    PolynomialRing({Integer(-16), Integer(4)}, SymbolExpression("x")),
                    PolynomialRing({Integer(1)}, SymbolExpression("x"))
                },
                SymbolExpression("y")),
                PolynomialRing({
                    PolynomialRing({Integer(1)}, SymbolExpression("x"))
                },
                SymbolExpression("y"))
            }, SymbolExpression("z"))
local h = PolynomialRing({
                PolynomialRing({
                    PolynomialRing({Integer(-4), Integer(4)/Integer(5), Integer(1)}, SymbolExpression("z")),
                    PolynomialRing({Integer(0)}, SymbolExpression("z")),
                    PolynomialRing({Integer(8)}, SymbolExpression("z"))
                },
                SymbolExpression("y")),
                PolynomialRing({
                    PolynomialRing({Integer(8), Integer(7), Integer(6), Integer(5)}, SymbolExpression("z")),
                    PolynomialRing({Integer(-1)}, SymbolExpression("z")),
                },
                SymbolExpression("y")),
                PolynomialRing({
                    PolynomialRing({Integer(0)}, SymbolExpression("z")),
                    PolynomialRing({Integer(2), Integer(8), Integer(1)}, SymbolExpression("z")),
                    PolynomialRing({Integer(-16), Integer(1)/Integer(9)}, SymbolExpression("z")),
                    PolynomialRing({Integer(1)}, SymbolExpression("z"))
                },
                SymbolExpression("y")),
                PolynomialRing({
                    PolynomialRing({Integer(1)}, SymbolExpression("z"))
                },
                SymbolExpression("y"))
            }, SymbolExpression("x"))
local i = Rational(PolynomialRing({-Integer(2), Integer(1)}, SymbolExpression("x")),
                   PolynomialRing({Integer(3), Integer(3), Integer(1)}, SymbolExpression("x")))
local j = Rational(PolynomialRing({-Integer(2), Integer(1)}, SymbolExpression("x")),
                   PolynomialRing({Integer(3)/Integer(4), Integer(3)/Integer(8), Integer(1)}, SymbolExpression("x")))
local k = PolynomialRing({IntegerModN(Integer(0), Integer(5)),
                          IntegerModN(Integer(1), Integer(5)),
                          IntegerModN(Integer(3), Integer(5)),
                          IntegerModN(Integer(1), Integer(5))}, SymbolExpression("x"))

local l = PolynomialRing({Rational(
                            PolynomialRing({Integer(4), Integer(1)}, SymbolExpression("x")),
                            PolynomialRing({Integer(0), Integer(4)}, SymbolExpression("x"))
                        ),
                        Rational(
                            PolynomialRing({Integer(3)/Integer(2)}, SymbolExpression("x")),
                            PolynomialRing({Integer(6), Integer(1)/Integer(2), Integer(8), Integer(1)}, SymbolExpression("x"))
                        ),
                        Rational(
                            PolynomialRing({Integer(6), Integer(6), Integer(4)}, SymbolExpression("x")),
                            PolynomialRing({Integer(3), Integer(1)}, SymbolExpression("x"))
                        ),
                        Rational(
                            PolynomialRing({Integer(7)/Integer(6)}, SymbolExpression("x")),
                            PolynomialRing({Integer(2), Integer(1)}, SymbolExpression("x"))
                        )
                    }, SymbolExpression("y"))

local aring = a:getring() -- ZZ
local bring = b:getring() -- QQ
local cring = c:getring() -- ZZ_7
local dring = d:getring() -- ZZ_14
local ering = e:getring() -- ZZ[x]
local fring = f:getring() -- QQ[x]
local gring = g:getring() -- ZZ[x][y][z]
local hring = h:getring() -- QQ[z][y][x]
local iring = i:getring() -- ZZ(x)
local jring = j:getring() -- QQ(x)
local kring = k:getring() -- ZZ_5[x]
local lring = l:getring() -- QQ(x)[y]

starttest("ring construction")
testeq(aring, "ZZ")
testeq(bring, "QQ")
testeq(cring, "Z/Z7")
testeq(dring, "Z/Z14")
testeq(ering, "ZZ[x]")
testeq(fring, "QQ[x]")
testeq(gring, "ZZ[x][y][z]")
testeq(hring, "QQ[z][y][x]")
testeq(iring, "ZZ(x)")
testeq(jring, "QQ(x)")
testeq(kring, "Z/Z5[x]")
testeq(lring, "QQ(x)[y]")
endtest()

starttest("ring conversion")

-- Commented-out tests denote elements whos rings are not subrings of the ring that is being converted to

testringconvert(a, aring, "12", "ZZ")
testringconvert(a, bring, "12/1", "QQ")
testringconvert(a, cring, "5", "Z/Z7")
testringconvert(a, dring, "12", "Z/Z14")
testringconvert(a, ering, "12x^0", "ZZ[x]")
testringconvert(a, fring, "12/1x^0", "QQ[x]")
testringconvert(a, gring, "((12x^0)y^0)z^0", "ZZ[x][y][z]")
testringconvert(a, hring, "((12/1z^0)y^0)x^0", "QQ[z][y][x]")
testringconvert(a, iring, "(12x^0)/(1x^0)", "ZZ(x)")
testringconvert(a, jring, "(12/1x^0)/(1/1x^0)", "QQ(x)")
testringconvert(a, kring, "2x^0", "Z/Z5[x]")
testringconvert(a, lring, "((12/1x^0)/(1/1x^0))y^0", "QQ(x)[y]")

-- testringconvert(b, aring, "3/2", "ZZ")
testringconvert(b, bring, "3/2", "QQ")
-- testringconvert(b, cring, "3/2", "Z/Z7")
-- testringconvert(b, dring, "3/2", "Z/Z14")
-- testringconvert(b, ering, "3/2", "ZZ[x]")
testringconvert(b, fring, "3/2x^0", "QQ[x]")
-- testringconvert(b, gring, "3/2", "ZZ[x][y][z]")
testringconvert(b, hring, "((3/2z^0)y^0)x^0", "QQ[z][y][x]")
-- testringconvert(b, iring, "3/2", "ZZ(x)")
testringconvert(b, jring, "(3/2x^0)/(1/1x^0)", "QQ(x)")
-- testringconvert(b, kring, "3/2", "Z/Z5[x]")
testringconvert(b, lring, "((3/2x^0)/(1/1x^0))y^0", "QQ(x)[y]")

testringconvert(c, aring, "4", "ZZ")
-- testringconvert(c, bring, "4", "QQ")
testringconvert(c, cring, "4", "Z/Z7")
testringconvert(c, dring, "4", "Z/Z14")
testringconvert(c, ering, "4x^0", "ZZ[x]")
-- testringconvert(c, fring, "4x", "QQ[x]")
testringconvert(c, gring, "((4x^0)y^0)z^0", "ZZ[x][y][z]")
-- testringconvert(c, hring, "4", "QQ[z][y][x]")
testringconvert(c, iring, "(4x^0)/(1x^0)", "ZZ(x)")
-- testringconvert(c, jring, "12/1x^0/1/1x^0", "QQ(x)")
testringconvert(c, kring, "4x^0", "Z/Z5[x]")
-- testringconvert(c, lring, "4", "QQ(x)[y]")

testringconvert(d, aring, "8", "ZZ")
-- testringconvert(d, bring, "8", "QQ")
testringconvert(d, cring, "1", "Z/Z7")
testringconvert(d, dring, "8", "Z/Z14")
testringconvert(d, ering, "8x^0", "ZZ[x]")
-- testringconvert(d, fring, "8", "QQ[x]")
testringconvert(d, gring, "((8x^0)y^0)z^0", "ZZ[x][y][z]")
-- testringconvert(d, hring, "8", "QQ[z][y][x]")
testringconvert(d, iring, "(8x^0)/(1x^0)", "ZZ(x)")
-- testringconvert(d, jring, "8", "QQ(x)")
testringconvert(d, kring, "3x^0", "Z/Z5[x]")
-- testringconvert(d, lring, "8", "QQ(x)[y]")

-- testringconvert(e, aring, "3x^2+0x^1+6x^0", "ZZ")
-- testringconvert(e, bring, "3x^2+0x^1+6x^0", "QQ")
-- testringconvert(e, cring, "3x^2+0x^1+6x^0", "Z/Z7")
-- testringconvert(e, dring, "3x^2+0x^1+6x^0", "Z/Z14")
testringconvert(e, ering, "3x^2+0x^1+6x^0", "ZZ[x]")
testringconvert(e, fring, "3/1x^2+0/1x^1+6/1x^0", "QQ[x]")
testringconvert(e, gring, "((3x^2+0x^1+6x^0)y^0)z^0", "ZZ[x][y][z]")
testringconvert(e, hring, "((3/1z^0)y^0)x^2+((0/1z^0)y^0)x^1+((6/1z^0)y^0)x^0", "QQ[z][y][x]")
testringconvert(e, iring, "(3x^2+0x^1+6x^0)/(1x^0)", "ZZ(x)")
testringconvert(e, jring, "(3/1x^2+0/1x^1+6/1x^0)/(1/1x^0)", "QQ(x)")
testringconvert(e, kring, "3x^2+0x^1+1x^0", "Z/Z5[x]")
testringconvert(e, lring, "((3/1x^2+0/1x^1+6/1x^0)/(1/1x^0))y^0", "QQ(x)[y]")

-- testringconvert(f, aring, "12x^1+4/5x^0", "ZZ")
-- testringconvert(f, bring, "12x^1+4/5x^0", "QQ")
-- testringconvert(f, cring, "12x^1+4/5x^0", "Z/Z7")
-- testringconvert(f, dring, "12x^1+4/5x^0", "Z/Z14")
-- testringconvert(f, ering, "12x^1+4/5x^0", "ZZ[x]")
testringconvert(f, fring, "12x^1+4/5x^0", "QQ[x]")
-- testringconvert(f, gring, "12x^1+4/5x^0", "ZZ[x][y][z]")
testringconvert(f, hring, "((12/1z^0)y^0)x^1+((4/5z^0)y^0)x^0", "QQ[z][y][x]")
-- testringconvert(f, iring, "12x^1+4/5x^0", "ZZ(x)")
testringconvert(f, jring, "(12x^1+4/5x^0)/(1/1x^0)", "QQ(x)")
-- testringconvert(f, kring, "12x^1+4/5x^0", "Z/Z5[x]")
testringconvert(f, lring, "((12x^1+4/5x^0)/(1/1x^0))y^0", "QQ(x)[y]")

-- testringconvert(g, aring, "", "ZZ")
-- testringconvert(g, bring, "", "QQ")
-- testringconvert(g, cring, "", "Z/Z7")
-- testringconvert(g, dring, "", "Z/Z14")
-- testringconvert(g, ering, "", "ZZ[x]")
-- testringconvert(g, fring, "", "QQ[x]")
testringconvert(g, gring, "((1x^0)y^0)z^3+((1x^0)y^3+(4x^1+-16x^0)y^2+(1x^2+8x^1+2x^0)y^1+(0x^0)y^0)z^2+((-1x^0)y^1+(5x^3+6x^2+7x^1+8x^0)y^0)z^1+((8x^0)y^2+(0x^0)y^1+(1x^2+12x^1+-4x^0)y^0)z^0", "ZZ[x][y][z]")
-- testringconvert(g, hring, "", "QQ[z][y][x]")
-- testringconvert(g, iring, "", "ZZ(x)")
-- testringconvert(g, jring, "", "QQ(x)")
-- testringconvert(g, kring, "", "Z/Z5[x]")
-- testringconvert(g, lring, "", "QQ(x)[y]")

-- testringconvert(h, aring, "", "ZZ")
-- testringconvert(h, bring, "", "QQ")
-- testringconvert(h, cring, "", "Z/Z7")
-- testringconvert(h, dring, "", "Z/Z14")
-- testringconvert(h, ering, "", "ZZ[x]")
-- testringconvert(h, fring, "", "QQ[x]")
-- testringconvert(h, gring, "", "ZZ[x][y][z]")
testringconvert(h, hring, "((1z^0)y^0)x^3+((1z^0)y^3+(1/9z^1+-16z^0)y^2+(1z^2+8z^1+2z^0)y^1+(0z^0)y^0)x^2+((-1z^0)y^1+(5z^3+6z^2+7z^1+8z^0)y^0)x^1+((8z^0)y^2+(0z^0)y^1+(1z^2+4/5z^1+-4z^0)y^0)x^0", "QQ[z][y][x]")
-- testringconvert(h, iring, "", "ZZ(x)")
-- testringconvert(h, jring, "", "QQ(x)")
-- testringconvert(h, kring, "", "Z/Z5[x]")
-- testringconvert(h, lring, "", "QQ(x)[y]")

-- testringconvert(i, aring, "", "ZZ")
-- testringconvert(i, bring, "", "QQ")
-- testringconvert(i, cring, "", "Z/Z7")
-- testringconvert(i, dring, "", "Z/Z14")
-- testringconvert(i, ering, "", "ZZ[x]")
-- testringconvert(i, fring, "", "QQ[x]")
-- testringconvert(i, gring, "", "ZZ[x][y][z]")
-- testringconvert(i, hring, "", "QQ[z][y][x]")
testringconvert(i, iring, "(1x^1+-2x^0)/(1x^2+3x^1+3x^0)", "ZZ(x)")
testringconvert(i, jring, "(1/1x^1+-2/1x^0)/(1/1x^2+3/1x^1+3/1x^0)", "QQ(x)")
-- testringconvert(i, kring, "", "Z/Z5[x]")
testringconvert(i, lring, "((1/1x^1+-2/1x^0)/(1/1x^2+3/1x^1+3/1x^0))y^0", "QQ(x)[y]")

-- testringconvert(j, aring, "", "ZZ")
-- testringconvert(j, bring, "", "QQ")
-- testringconvert(j, cring, "", "Z/Z7")
-- testringconvert(j, dring, "", "Z/Z14")
-- testringconvert(j, ering, "", "ZZ[x]")
-- testringconvert(j, fring, "", "QQ[x]")
-- testringconvert(j, gring, "", "ZZ[x][y][z]")
-- testringconvert(j, hring, "", "QQ[z][y][x]")
-- testringconvert(j, iring, "", "ZZ(x)")
testringconvert(j, jring, "(1x^1+-2x^0)/(1x^2+3/8x^1+3/4x^0)", "QQ(x)")
-- testringconvert(j, kring, "", "Z/Z5[x]")
testringconvert(j, lring, "((1x^1+-2x^0)/(1x^2+3/8x^1+3/4x^0))y^0", "QQ(x)[y]")

-- testringconvert(k, aring, "", "ZZ")
-- testringconvert(k, bring, "", "QQ")
-- testringconvert(k, cring, "", "Z/Z7")
-- testringconvert(k, dring, "", "Z/Z14")
testringconvert(k, ering, "1x^3+3x^2+1x^1+0x^0", "ZZ[x]")
-- testringconvert(k, fring, "", "QQ[x]")
testringconvert(k, gring, "((1x^3+3x^2+1x^1+0x^0)y^0)z^0", "ZZ[x][y][z]")
-- testringconvert(k, hring, "", "QQ[z][y][x]")
testringconvert(k, iring, "(1x^3+3x^2+1x^1+0x^0)/(1x^0)", "ZZ(x)")
-- testringconvert(k, jring, "", "QQ(x)")
testringconvert(k, kring, "1x^3+3x^2+1x^1+0x^0", "Z/Z5[x]")
-- testringconvert(k, lring, "", "QQ(x)[y]")

-- testringconvert(l, aring, "", "ZZ")
-- testringconvert(l, bring, "", "QQ")
-- testringconvert(l, cring, "", "Z/Z7")
-- testringconvert(l, dring, "", "Z/Z14")
-- testringconvert(l, ering, "", "ZZ[x]")
-- testringconvert(l, fring, "", "QQ[x]")
-- testringconvert(l, gring, "", "ZZ[x][y][z]")
-- testringconvert(l, hring, "", "QQ[z][y][x]")
-- testringconvert(l, iring, "", "ZZ(x)")
-- testringconvert(l, jring, "", "QQ(x)")
-- testringconvert(j, kring, "", "Z/Z5[x]")
testringconvert(l, lring, "((7/6x^0)/(1x^1+2x^0))y^3+((4x^2+6x^1+6x^0)/(1x^1+3x^0))y^2+((3/2x^0)/(1x^3+8x^2+1/2x^1+6x^0))y^1+((1/4x^1+1x^0)/(1x^1+0x^0))y^0", "QQ(x)[y]")




endtest()