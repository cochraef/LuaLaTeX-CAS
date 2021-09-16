local bn = require("lib.nums.bn")

-- Represents an arbitrary integer in lua. Essentially a wrapper class for bignum.
Integer = {}
local __Integer = {}

function __Integer.__unm(a)
    return Integer(-a.internal)
end

function __Integer.__add(a, b)
    if not Integer.is(b) then
       return convert_type(a, b) + b
    end
    return Integer(a.internal + b.internal)
end

function __Integer.__sub(a, b)
    if not Integer.is(b) then
        return convert_type(a, b) - b
     end
    return Integer(a.internal - b.internal)
end

function __Integer.__mul(a, b)
    if not Integer.is(b) then
        return convert_type(a, b) * b
    end
    return Integer(a.internal * b.internal)
end

function __Integer.__div(a, b)
    if not Integer.is(b) then
        return convert_type(a, b) / b
    end
    return Rational(a, b)
end

-- TODO: Real number division
function __Integer.__idiv(a, b)
    return Integer(a.internal / b.internal)
end

function __Integer.__mod(a, b)
    return Integer(a.internal % b.internal)
end

function __Integer.__pow(a, b)
    return Integer(a.internal ^ b.internal)
end

-- Comparison metamethods require some fudging to work with different types, but for now autoconverting types should work out okay
function __Integer.__eq(a, b)
    return a.internal == b.internal
end

function __Integer.__lt(a, b)
    return a.internal < b.internal
end

function __Integer.__le(a, b)
    return a.internal <= b.internal
end

function __Integer.__tostring(a)
    return tostring(a.internal)
end

--  Constructor for a new integer.
--  Parameter - the integer as a string or number (optional - defaults to 0)
function Integer:new(n)
    local o = {}
    __Integer.__index = Integer
    o = setmetatable(o, __Integer)

    n = n or "0"
    o.internal = bn(n)

    return o
end

-- Returns the zero element of this ring
Integer.ZERO = Integer:new()

-- Static method for computing the gcd of two integers using Euclid's algorithm
function Integer.gcd(a, b)
    while b ~= Integer(0) do
        a, b = b, a%b
    end
    return a
end

-- Static method for computing the greater of two integers
function Integer.max(a, b)
    if a > b then
        return a
    end
    return b
end

-- Returns the ceiling of the log base (defaults to 10) of a
-- In other words, returns the least n such that base^n > a
function Integer.ceillog(a, base)
    base = base or Integer(10)
    local k = Integer(0)

    while (base ^ k) < a do
        k = k + Integer(1)
    end

    return k
end

-- Static method for determining whether or not an object is an integer
function Integer.is(o)
    return type(o) == "table" and getmetatable(o) ==__Integer
end

-- Gets the type of this object
function Integer:type()
    return Integer
end

-- Explicitly converts an integer into a rational.
function Integer:torational()
    return Rational(self, Integer(1), true)
end

-- Creates construction method and inhertiance from Rationals
Integer = setmetatable(Integer, { __call = Integer.new, __index = Rational})