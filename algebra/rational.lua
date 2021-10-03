-- Represents an element of the field of rational numbers

-- Represents an element of the ring of integers
-- Rationals have the following instance variables:
--      numerator - an Integer numerator for the fractional representation of this rataionl
--      denominator - an Integer denominator for the fractional representation of this rational
-- Integers have the following relationship to other classes:
--      Rationals implement Fields
Rational = {}
__Rational = {}

--------------------------
-- Static functionality --
--------------------------

-- Returns the immediate subrings of this ring
function Rational.subrings()
    return {Integer}
end

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new rational given an integer numerator and denominator
-- Rational numbers should be represented uniquely
function Rational:new(n, d, keep)
    local o = {}
    local __o = Copy(__FieldOperations)
    __o.__index = Rational
    __o.__tostring = function(a)
        return tostring(a.numerator).."/"..tostring(a.denominator)
    end
    o = setmetatable(o, __o)

    if(n.getRing() ~= Integer or d.getRing() ~= Integer) then
        error("Improper arguments for constructing a rational. Should be integers.")
    end

    n = n or Integer(0)
    d = d or Integer(1)
    o.numerator = n
    o.denominator = d
    o:reduce()

    if (not keep) and o.denominator == Integer(1) then
        return o.numerator
    end

    return o
end

-- Reduces a rational number to standard form.
function Rational:reduce()
    if self.denominator < Integer(0) then
        self.denominator = -self.denominator
        self.numerator = -self.numerator
    end
    local gcd = Integer.gcd(self.numerator, self.denominator)
    self.numerator = self.numerator//gcd
    self.denominator = self.denominator//gcd

end

-- Returns the type of this object
function Rational:getRing()
    return Rational
end

-- Explicitly converts this element to an element of another ring
function Rational:inRing(ring)
    if ring == Rational then
        return self
    end

    local ratring = PolynomialRing({}, ring["symbol"])
    ratring.ring = Rational

    if ratring.subringof(ratring:getRing(), ring) then
        return PolynomialRing({self}, ring["symbol"]):inRing(ring)
    end

    error("Unable to convert element to proper ring.")
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

function Rational:inv(b)
    return Rational(self.numerator * b.numerator, self.denominator * b.denominator)
end

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
    if self.numerator < Integer(0) and b.numerator > Integer(0) then
        return true
    end
    if self.numerator > Integer(0) and b.numerator < Integer(0) then
        return false
    end

    if self.numerator > Integer(0) and b.numerator > Integer(0) then
        return self.numerator * b.denominator < self.denominator * b.numerator
    end
    return self.numerator * b.denominator > self.denominator * b.numerator
end

function Rational:le(b)
    return self:eq(b) or self:lt(b)
end

function Rational:zero()
    return Integer(0)
end

function Rational:one()
    return Integer(1)
end

-----------------
-- Inheritance --
-----------------

__Rational.__index = Field
__Rational.__call = Rational.new
Rational = setmetatable(Rational, __Rational)