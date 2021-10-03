-- Represents an element of the ring of integers
-- Integers have the following instance variables:
--      internal - the internal representation of the integer
-- Integers have the following relationship to other classes:
--      Integers implement Euclidean Domains
Integer = {}
__Integer = {}

--------------------------
-- Static functionality --
--------------------------

-- Returns the immediate subrings of this ring
function Integer.subrings()
    return {}
end

-- Method for computing the gcd of two integers using Euclid's algorithm
function Integer.gcd(a, b)
    while b ~= Integer(0) do
        a, b = b, a%b
    end
    return a
end

-- Method for computing the greater of two integers
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

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new integer given a string or number representation of the integer
function Integer:new(n)
    local o = {}
    local __o = Copy(__EuclideanOperations)
    __o.__index = Integer
    __o.__tostring = function(a)
        return tostring(a.internal)
    end
    __o.__div = function(a, b)   -- Constructor for a rational number disguised as division
        if(b.getRing() == Integer) then
            return Rational(a, b)
        end
        return __FieldOperations.__div(a, b)
    end
    o = setmetatable(o, __o)

    n = n or 0
    o.internal = bn(n)

    return o
end

-- Returns the type of this object
function Integer:getRing()
    return Integer
end

-- Explicitly converts this element to an element of another ring
function Integer:inRing(ring)
    if ring == Integer then
        return self
    end

    if Rational.subringof(Rational, ring) then
        return Rational(self, Integer(1), true):inRing(ring)
    end

    local intring = PolynomialRing({}, ring["symbol"])
    intring.ring = Integer

    if intring.subringof(intring:getRing(), ring) then
        return PolynomialRing({self}, ring["symbol"]):inRing(ring)
    end

    error("Unable to convert element to proper ring.")
end

function Integer:add(b)
    return Integer(self.internal + b.internal)
end

function Integer:neg()
    return Integer(-self.internal)
end

function Integer:mul(b)
    return Integer(self.internal * b.internal)
end

-- Overrides the generic power method with the bignum library's more efficient method
function Integer:pow(b)
    if b < Integer(0) then
        return Integer(1) / Integer(self.internal ^ (-b.internal))
    end
    return Integer(self.internal ^ b.internal)
end

-- Division with remainder in integers
function Integer:divremainder(b)
    return Integer(self.internal // b.internal), Integer(self.internal % b.internal)
end

function Integer:eq(b)
    -- The bignum library treated signed zeros as not being equal???
    if self:asNumber() == 0 and b:asNumber() == 0 then
        return true
    end
    return self.internal == b.internal
end

function Integer:lt(b)
    return self.internal < b.internal
end

function Integer:le(b)
    return self.internal <= b.internal
end

function Integer:zero()
    return Integer(0)
end

function Integer:one()
    return Integer(1)
end

-- returns this integer as a number
function Integer:asNumber()
    -- The bignum library is broken for some reason and doesn't give the right answer when zero is negative
    if self.internal._digits[1] == 0 and not self.internal._digits[2] then
        return 0
    end
    return self.internal:asnumber()
end

-----------------
-- Inheritance --
-----------------

__Integer.__index = EuclideanDomain
__Integer.__call = Integer.new
Integer = setmetatable(Integer, __Integer)