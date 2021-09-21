-- Represents a polynomial ring
-- PolynomialRings have the following instance variables:
--      ring - the Ring used to generate the PolynomialRing
--      coefficients - A map from Integers to the Ring representing the coefficients in the polynomial
--      degree - the Integer degree of the PolynomialRing
--      symbol - the symbol adjoined to the ring to create the PolynomialRing
-- PolynomialRings have the following relationships with other classes:
--      PolynomialRings are a superset of Rings
PolynomialRing = {}
__PolynomialRing = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new polynomial ring given an array of coefficients and a symbol
function PolynomialRing:new(coefficients, symbol)
    local o = {}
    o = setmetatable(o, {__index = PolynomialRing})

    if type(coefficients) ~= "table"then
        error("Coefficients must be in an array")
    end
    o.coefficients = {}
    o.degree = Integer(-1)
    for index, coefficient in ipairs(coefficients) do
        if type(index) ~= "number" then
            error("Coefficients must be in an array")
        end
        if not coefficient.is(Ring) then
            error("Coefficients must be part of a ring")
        end
        if not o.ring then
            o.ring = coefficient.getType()
        end

        o.coefficients[Integer(index - 1)] = coefficient
        o.degree = o.degree + Integer(1)
    end

    if type(symbol) ~= "string" then
        error("Symbol must be a string")
    end
    o.symbol = symbol

end

-- Returns the type of this object
-- has a field for the type of ring used to construct this ring, like type parameterization in Java only worse
function PolynomialRing:getType()
    local t = {PolynomialRing, self.ring}
    return setmetatable(t, {__index = PolynomialRing, __eq = function(a, b)
        return a[2] == b[2]
    end})
end

-- Returns whether the ring is commutative
function PolynomialRing:isCommutative()
    return true
end

-----------------
-- Inheritance --
-----------------

__PolynomialRing.__index = Ring
__PolynomialRing.__call = PolynomialRing.new
PolynomialRing = setmetatable(PolynomialRing, __PolynomialRing)