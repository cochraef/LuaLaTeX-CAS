-- Represents an element of the field of rational numbers or rational functions.
-- Rationals have the following instance variables:
--      numerator - an Integer numerator for the fractional representation of this rataionl
--      denominator - an Integer denominator for the fractional representation of this rational
-- Integers have the following relationship to other classes:
--      Rationals implement Fields
Rational = {}
__Rational = {}

----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the field operations each time
local __o = Copy(__FieldOperations)
__o.__index = Rational
__o.__tostring = function(a)
    return tostring(a.numerator).."/"..tostring(a.denominator)
end

-- Creates a new rational given an integer numerator and denominator.
-- Rational numbers are represented uniquely.
function Rational:new(n, d, keep)
    local o = {}
    o = setmetatable(o, __o)

    if n:getring() == PolynomialRing.getring() then
        o.symbol = n.symbol
        o.ring = n:getring()
    end

    if d:getring() == PolynomialRing.getring() then
        o.symbol = d.symbol
        o.ring = d:getring()
    end

    n = n or Integer.zero()
    d = d or Integer.one()
    o.numerator = n
    o.denominator = d
    if not o.ring then
        o:reduce()
    end

    if (not keep) and o.denominator == Integer.one() or (not keep) and o.numerator == Integer.zero() then
        return o.numerator
    end

    return o
end

-- Reduces a rational expression to standard form.
function Rational:reduce()
    if self.denominator < Integer.zero() then
        self.denominator = -self.denominator
        self.numerator = -self.numerator
    end
    local gcd = Integer.gcd(self.numerator, self.denominator)
    self.numerator = self.numerator//gcd
    self.denominator = self.denominator//gcd

end


-- Metatable for ring objects.
local __obj = {__index = Rational, __eq = function(a, b)
    return a["ring"] == b["ring"] and
            (a["child"] == b["child"] or a["child"] == nil or b["child"] == nil) and
            (a["symbol"] == b["symbol"] or a["child"] == nil or b["child"] == nil)
end, __tostring = function(a)
        if a.child and a.symbol then
            return tostring(a.child.child) .. "(" .. a.symbol .. ")"
        end
        return "QQ"
    end}

-- Returns the ring this object is an element of
function Rational:getring()
    local t = {ring=Rational}
    if self then
        t.child = self.ring
        t.symbol = self.symbol
    end
    t = setmetatable(t, __obj)
    return t
end

-- Explicitly converts this element to an element of another ring
function Rational:inring(ring)
    if ring == self:getring() then
        return self
    end

    if ring == PolynomialRing:getring() then
        return PolynomialRing({self:inring(ring.child)}, ring.symbol)
    end

    error("Unable to convert element to proper ring.")
end

function Rational:tocompoundexpression()
    return BinaryOperation(BinaryOperation.DIV, {self.numerator:tocompoundexpression(), self.denominator:tocompoundexpression()})
end

function Rational:add(b)
    return Rational(self.numerator * b.denominator + self.denominator * b.numerator, self.denominator * b.denominator)
end

function Rational:neg()
    return Rational(-self.numerator, self.denominator, true)
end

function Rational:mul(b)
    return Rational(self.numerator * b.numerator, self.denominator * b.denominator)
end

-- function Rational:inv(b)
--     return Rational(self.numerator * b.numerator, self.denominator * b.denominator)
-- end

function Rational:pow(b)
    return (self.numerator ^ b) / (self.denominator ^ b)
end

-- Divides a rational number by another
function Rational:div(b)
    return Rational(self.numerator * b.denominator, self.denominator * b.numerator)
end

function Rational:eq(b)
    return self.numerator == b.numerator and self.denominator == b.denominator
end

function Rational:lt(b)
    if self.numerator < Integer.zero() and b.numerator > Integer.zero() then
        return true
    end
    if self.numerator > Integer.zero() and b.numerator < Integer.zero() then
        return false
    end

    if self.numerator >= Integer.zero() and b.numerator >= Integer.zero() then
        return self.numerator * b.denominator < self.denominator * b.numerator
    end
    return self.numerator * b.denominator > self.denominator * b.numerator
end

function Rational:le(b)
    return self:eq(b) or self:lt(b)
end

function Rational:zero()
    return Integer.zero()
end

function Rational:one()
    return Integer.one()
end

function Rational:tolatex()
    return "\\frac{" .. self.numerator:tolatex() .."}{".. self.denominator:tolatex().. "}"
end

-----------------
-- Inheritance --
-----------------

__Rational.__index = Field
__Rational.__call = Rational.new
Rational = setmetatable(Rational, __Rational)