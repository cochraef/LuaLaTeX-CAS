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

-- Commented out tests denote elements whos rings are not subrings of the ring that is being converted to

testringconvert(a, aring, "12", "ZZ")
testringconvert(a, bring, "12/1", "QQ")
testringconvert(a, cring, "5", "Z/Z7")
testringconvert(a, dring, "12", "Z/Z14")
testringconvert(a, ering, "12x^0", "ZZ[x]")
testringconvert(a, fring, "12/1x^0", "QQ[x]")
testringconvert(a, gring, "((12x^0)y^0)z^0", "ZZ[x][y][z]")
testringconvert(a, hring, "((12/1z^0)y^0)x^0", "QQ[z][y][x]")
testringconvert(a, iring, "12x^0/1x^0", "ZZ(x)")
testringconvert(a, jring, "12/1x^0/1/1x^0", "QQ(x)")
testringconvert(a, kring, "2x^0", "Z/Z5[x]")
testringconvert(a, lring, "(12/1x^0/1/1x^0)y^0", "QQ(x)[y]")

-- testringconvert(b, aring, "3/2", "ZZ")
testringconvert(b, bring, "3/2", "QQ")
-- testringconvert(b, cring, "3/2", "Z/Z7")
-- testringconvert(b, dring, "3/2", "Z/Z14")
-- testringconvert(b, ering, "3/2", "ZZ[x]")
testringconvert(b, fring, "3/2x^0", "QQ[x]")
-- testringconvert(b, gring, "3/2", "ZZ[x][y][z]")
testringconvert(b, hring, "((3/2z^0)y^0)x^0", "QQ[z][y][x]")
-- testringconvert(b, iring, "3/2", "ZZ(x)")
testringconvert(b, jring, "3/2x^0/1/1x^0", "QQ(x)")
-- testringconvert(b, kring, "3/2", "Z/Z5[x]")
testringconvert(b, lring, "(3/2x^0/1/1x^0)y^0", "QQ(x)[y]")

endtest()