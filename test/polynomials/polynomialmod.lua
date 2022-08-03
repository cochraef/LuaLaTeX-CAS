local a = PolynomialRing({IntegerModN(Integer(1), Integer(11)),
                        IntegerModN(Integer(6), Integer(11)),
                        IntegerModN(Integer(1), Integer(11)),
                        IntegerModN(Integer(9), Integer(11)),
                        IntegerModN(Integer(1), Integer(11))}, "y")

local b = PolynomialRing({IntegerModN(Integer(7), Integer(11)),
                        IntegerModN(Integer(7), Integer(11)),
                        IntegerModN(Integer(6), Integer(11)),
                        IntegerModN(Integer(2), Integer(11)),
                        IntegerModN(Integer(1), Integer(11))}, "y")

local q = PolynomialRing({IntegerModN(Integer(2), Integer(13)),
                            IntegerModN(Integer(6), Integer(13)),
                            IntegerModN(Integer(4), Integer(13))}, "z")

local p = PolynomialRing({IntegerModN(Integer(4), Integer(13)),
                    IntegerModN(Integer(11), Integer(13)),
                    IntegerModN(Integer(1), Integer(13)),
                    IntegerModN(Integer(12), Integer(13)),
                    IntegerModN(Integer(1), Integer(13))}, "x")

local r = PolynomialRing({IntegerModN(Integer(1), Integer(3)),
                    IntegerModN(Integer(0), Integer(3)),
                    IntegerModN(Integer(0), Integer(3)),
                    IntegerModN(Integer(2), Integer(3)),
                    IntegerModN(Integer(0), Integer(3)),
                    IntegerModN(Integer(0), Integer(3)),
                    IntegerModN(Integer(1), Integer(3))}, "x")

local s = PolynomialRing({IntegerModN(Integer(1), Integer(5)),
                    IntegerModN(Integer(1), Integer(5)),
                    IntegerModN(Integer(1), Integer(5)),
                    IntegerModN(Integer(1), Integer(5)),
                    IntegerModN(Integer(1), Integer(5))}, "x")

local t = PolynomialRing({IntegerModN(Integer(1), Integer(7))}, "x"):multiplyDegree(7) - PolynomialRing({IntegerModN(Integer(1), Integer(7))}, "x"):multiplyDegree(1)

local u = PolynomialRing({IntegerModN(Integer(1), Integer(13)),
                        IntegerModN(Integer(5), Integer(13)),
                        IntegerModN(Integer(6), Integer(13)),
                        IntegerModN(Integer(5), Integer(13)),
                        IntegerModN(Integer(1), Integer(13))}, "x")

local v = PolynomialRing({IntegerModN(Integer(24), Integer(7)),
                            IntegerModN(Integer(50), Integer(7)),
                            IntegerModN(Integer(59), Integer(7)),
                            IntegerModN(Integer(60), Integer(7)),
                            IntegerModN(Integer(36), Integer(7)),
                            IntegerModN(Integer(10), Integer(7)),
                            IntegerModN(Integer(1), Integer(7))}, "z")

starttest("modular polynomial operations")
testeq(q*q, "3z^4+9z^3+0z^2+11z^1+4z^0")
testeq(PolynomialRing.gcd(a, b), "1y^0")
local Q, R, S = PolynomialRing.extendedgcd(a, b)
testeq(Q, "1y^0")
testeq(R, "4y^3+5y^2+1y^1+3y^0")
testeq(S, "7y^3+0y^2+7y^1+6y^0")
endtest()

starttest("modular square free factoring")
testeq(p:squarefreefactorization(), "(1 * (1x^2+6x^1+2x^0 ^ 2))")
testeq(r:squarefreefactorization(), "(1 * (1x^3+0x^2+0x^1+1x^0 ^ 2))")
testeq(q:squarefreefactorization(), "(4 * (1z^2+8z^1+7z^0 ^ 1))")
testeq(s:squarefreefactorization(), "(1 * (1x^1+4x^0 ^ 4))")
endtest()

starttest("modular polynomial factoring")
testeq(q:factor(), "(4 * (1z^1+7z^0 ^ 1) * (1z^1+1z^0 ^ 1))", q)
testeq(p:factor(), "(1 * (1x^2+6x^1+2x^0 ^ 2))", p)
testeq(r:factor(), "(1 * (1x^3+0x^2+0x^1+1x^0 ^ 2))", r)
testeq(t:factor(), "(1 * (1x^1+0x^0 ^ 1) * (1x^1+6x^0 ^ 1) * (1x^1+5x^0 ^ 1) * (1x^1+4x^0 ^ 1) * (1x^1+3x^0 ^ 1) * (1x^1+2x^0 ^ 1) * (1x^1+1x^0 ^ 1))", t)
testeq(u:factor(), "(1 * (1x^1+11x^0 ^ 1) * (1x^1+10x^0 ^ 1) * (1x^1+6x^0 ^ 1) * (1x^1+4x^0 ^ 1))", u)
testeq(v:factor(), "(1 * (1z^1+1z^0 ^ 1) * (1z^1+2z^0 ^ 1) * (1z^2+0z^1+1z^0 ^ 1) * (1z^1+4z^0 ^ 1) * (1z^1+3z^0 ^ 1))", v)
endtest()