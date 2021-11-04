require("algebra._init")


local function test(actual, expected, initial)
    if initial then
        if tostring(expected) == tostring(actual) then
            print(tostring(initial) .. " -> " .. tostring(actual))
        else
            print(tostring(initial) .. " -> " .. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
        end
    else
        if tostring(expected) == tostring(actual) then
            print("Result: " .. tostring(actual))
        else
            print("Result: ".. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
        end
    end
end

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

test(q*q, "3z^4+9z^3+0z^2+11z^1+4z^0");
test(p:squarefreefactorization(), "(1 * (1x^2+6x^1+2x^0 ^ 2))")
test(r:squarefreefactorization(), "(1 * (1x^3+0x^2+0x^1+1x^0 ^ 2))")
test(q:squarefreefactorization(), "(4 * (1z^2+8z^1+7z^0 ^ 1))")