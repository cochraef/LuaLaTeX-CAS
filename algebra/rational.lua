-- Represents an element of the field of rational numbers

-- Represents an element of the ring of integers
-- Rationals have the following instance variables:
--      numerator - an Integer numerator for the fractional representation of this rataionl
-- Integers have the following relationship to other classes:
--      Rationals implement Rings
--      Rationals are a superset of Rings
Rational = {}
__Rational = {}

--------------------------
-- Static functionality --
--------------------------

-- Returns the subrings of this ring
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
    local mt = Copy(__FieldOperations)
    mt.__index = Rational
    mt.__tostring = function(a)
        return tostring(a.numerator).."/"..tostring(a.denominator)
    end
    o = setmetatable(o, mt)

    if(n.getType() ~= Integer or d.getType() ~= Integer) then
        error("Improper arguments for constructing a rational. Should be integers.")
    end

    n = n or Integer(0)
    d = d or Integer(1)
    o.numerator = n
    o.denominator = d
    o:reduce()

    o.addgroup = Group(function(a, b)
        return Rational(a.numerator * b.denominator + a.denominator * b.numerator, a.denominator * b.denominator)
    end)
    function o.addgroup:isAbelian()
        return true
    end
    function o.addgroup:inv()
        return Rational(-o.numerator, o.denominator, true)
    end

    o.mulgroup = Group(function (a, b)
        return Rational(a.numerator * b.numerator, a.denominator * b.denominator)
    end)
    function o.mulgroup:isAbelian()
        return true
    end
    function o.mulgroup:inv()
        return Rational(o.denominator, o.numerator)
    end
    o.mulgroup.pow = function(a, b)
        return Rational(a.numerator ^ b.internal, b.numerator ^ b.internal)
    end

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

-- Divides a rational number by another
function Rational:div(b)
    return Rational(self.numerator * b.denominator, self.denominator * b.numerator)
end

-- Returns the type of this object
function Rational:getType()
    return Rational
end

function Rational:eq(b)
    return self.numerator == b.numerator and self.denominator == self.denominator
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
    return self.eq(b) or self.lt(b)
end

-----------------
-- Inheritance --
-----------------

__Rational.__index = Ring
__Rational.__call = Rational.new
Rational = setmetatable(Rational, __Rational)

----------------------
-- Static constants --
----------------------

Rational.zero = Integer(0)