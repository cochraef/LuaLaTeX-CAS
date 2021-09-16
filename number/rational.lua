-- Represents a rational number uniquely in lua.
-- This is ensured by making sure the denominator > 0 and gcd(numerator, denominator) = 1.
Rational = {}
local __Rational = {}

function __Rational.__unm(a)
    return Rational(-a.numerator, a.denominator)
end

function __Rational.__add(a, b)
    if not Rational.is(b) then
        b = convert_type(b, a)
    end
    return Rational(a.numerator * b.denominator + a.denominator * b.numerator, a.denominator * b.denominator)
end

function __Rational.__sub(a, b)
    return a + (-b);
end

function __Rational.__mul(a, b)
    if not Rational.is(b) then
        b = convert_type(b, a)
    end
    return Rational(a.numerator * b.numerator, a.denominator * b.denominator)
end

function __Rational.__div(a, b)
    if not Rational.is(b) then
        b = convert_type(b, a)
    end
    if b.numerator == Integer(0) then
        error("Divide by Zero error")
    end
    return Rational(a.numerator * b.denominator, a.denominator * b.numerator)
end

-- TODO: Real number division
function __Rational.__idiv(a, b)
    return nil
end

-- TODO: Real number exponentiation
function __Rational.__pow(a, b)
    return nil
end

function __Rational.__eq(a, b)
    return (a.numerator == b.numerator) and (a.denominator == b.denominator)
end

-- TODO: Real number comparisons
function __Rational.__lt(a, b)
    return a.internal < b.internal
end

-- TODO: Real number comparisons
function __Rational.__le(a, b)
    return a.internal <= b.internal
end

function __Rational.__tostring(a)
    return tostring(a.numerator).."/"..tostring(a.denominator)
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

-- Constructor for a new rational.
-- Parameter - numerator as an integer (optional - defaults to 0)
-- Parameter - denominator as an integer (optional - defaults to 1)
-- Parameter - whether or not the rational should stay a rational even if it can be converted to an integer (optional - defaults to false)
function Rational:new(n, d, keep)
    local o = {}
    __Rational.__index = Rational
    o = setmetatable(o, __Rational)

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

Rational.ZERO = Rational:new()

-- Static method for determining whether or not an object is an integer
function Rational.is(o)
    return type(o) == "table" and getmetatable(o) == __Rational
end

-- Gets the type of this object
function Rational:type()
    return Rational
end

-- Creates construction method and inhertiance from Reals.
Rational = setmetatable(Rational, { __call = Rational.new, __index = Real})
