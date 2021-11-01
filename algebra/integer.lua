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

-- Returns a ^ b (mod n). This should be used when a ^ b is potentially large.
function Integer.powmod(a, b, n)
    if n == Integer(1) then
        return Integer(0)
    else
        local r = Integer(1)
        a = a % n
        while b > Integer(0) do
          if b % Integer(2) == Integer(1) then
            r = (r * a) % n
          end
          a = (a ^ Integer(2)) % n
          b = b // Integer(2)
        --   print("a: " .. tostring(a))
        --   print("b: " .. tostring(b))
        --   print("r: " .. tostring(r))
        end
        return r
    end
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
        if not a.isbignum then
            return tostring(math.floor(a.internal))
        end
        return tostring(a.internal)
    end
    __o.__div = function(a, b)   -- Constructor for a rational number disguised as division
        if not b.getRing then
            return BinaryOperation.DIVEXP({a, b});
        end
        if(b:getRing().ring == Integer) then
            return Rational(a, b)
        end
        return __FieldOperations.__div(a, b)
    end
    o = setmetatable(o, __o)

    n = n or 0

    if (type(n) == "string" and (tonumber(n) > (2^50) or tonumber(n) < -(2^50))) or
       (type(n) == "number" and (n > (2^50) or n < -(2^50))) or
       (type(n) == "table" and (n > bn(2^50) or n < bn(-(2^50)))) then
        o.internal = bn(n)
        o.isbignum = true
        return o
    end

    if type(n) == "string" then
        n = tonumber(n)
    end

    if type(n) == "table" then
        if n._digits[1] == 0 and not n._digits[2] then
            n = 0
        else
            n = n:asnumber()
        end
    end

    n = n or 0
    o.internal = n
    o.isbignum = false

    return o
end

-- Returns the ring this object is an element of
function Integer:getRing()
    local t = {ring=Integer}
    t = setmetatable(t, {__index = Integer, __eq = function(a, b)
        return a["ring"] == b["ring"]
    end})
    return t;
end

-- Explicitly converts this element to an element of another ring
function Integer:inRing(ring)
    if ring == self:getRing() then
        return self
    end

    if ring.ring == IntegerModN then
        return IntegerModN(self, ring.modulus)
    end

    if Ring.subringof(Rational.getRing(), ring) then
        return Rational(self, Integer(1), true):inRing(ring)
    end

    if Ring.subringof(PolynomialRing.getRing(), ring) then
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
    if not self.isbignum and not b.isbignum and ((self.internal * b.internal) > (2 ^ 50)) or
            ((self.internal * b.internal) < (- 2 ^ 50)) or
            self.internal > 0 and b.internal > 0 and (self.internal * b.internal) < 0 then
        return Integer(bn(self.internal) * bn(b.internal))
    end
    return Integer(self.internal * b.internal)
end

-- Overrides the generic power method with the bignum library's more efficient method
function Integer:pow(b)
    if b < Integer(0) then
        return Integer(1) / Integer(self.internal ^ (-b.internal))
    end
    if not self.isbignum and not b.isbignum and (self.internal ^ b.internal) > (2 ^ 50) then
        return Integer(bn(self.internal) ^ bn(b.internal))
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
    if not self.isbignum then
        return self.internal
    end

    -- The bignum library is broken for some reason and doesn't give the right answer when zero is negative
    if self.internal._digits[1] == 0 and not self.internal._digits[2] then
        return 0
    end
    return self.internal:asnumber()
end

-- returns the prime factorization of this integer as a expression
function Integer:primefactorization()
    local result = self:primefactorizationrec()
    local mul = {}
    local i = 1
    for factor, degree in pairs(result) do
        mul[i] = BinaryOperation.POWEXP({factor, degree})
        i = i + 1
    end
    return BinaryOperation.MULEXP(mul)
end

-- Recursive part of prime factorization using Pollard Rho
function Integer:primefactorizationrec()
    local result = self:findafactor()
    if result == self then
        return {[result]=Integer(1)}
    end
    local remaining = self / result
    return Integer.mergefactors(result:primefactorizationrec(), remaining:primefactorizationrec())
end


function Integer.mergefactors(a, b)
    local result = Copy(a)

    for factor, degree in pairs(b) do
        for ofactor, odegree in pairs(result) do
            if factor == ofactor then
                result[ofactor] = degree + odegree
                goto continue
            end
        end
        result[factor] = degree
        ::continue::
    end
    return result
end

-- return a non-trivial factor of n via Pollard Rho, or returns n if n is prime
function Integer:findafactor()

    if self:isprime() then
        return self + Integer(0)
    end

    if self % Integer(2) == Integer(0) then
        return Integer(2)
    end

    local g = function(x)
        local temp = Integer.powmod(x, Integer(2), self)
        if temp == self then
            temp = Integer(0)
        end
        return temp
    end

    local x = Integer(2)
    while x < self do
        local y = Integer(2)
        local d = Integer(1)
        while d == Integer(1) do
            x = g(x)
            y = g(g(y))
            d = Integer.gcd((x - y):abs(), self)
        end

        if d < self then
            return d
        end

        x = x + Integer(1)
    end
end

-- uses Miller-Rabin to determine whether a number is prime up to a very large number
function Integer:isprime()
    if self % Integer(2) == Integer(0) then
        return false
    end

    if self == Integer(1) then
        return false
    end

    local smallprimes = {Integer(2), Integer(3), Integer(5), Integer(7), Integer(11), Integer(13), Integer(17), Integer(19), Integer(23),
                            Integer(29), Integer(31), Integer(37), Integer(41), Integer(43), Integer(47), Integer(53), Integer(59)}

    for _, value in pairs(smallprimes) do
        if value == self then
            return true
        end
    end

    local r = Integer(0)
    local d = self - Integer(1)
    while d % Integer(2) == Integer(0) do
        r = r + Integer(1)
        d = d / Integer(2)
    end

    for _, a in ipairs(smallprimes) do
        local x = Integer.powmod(a, d, self)
        if x == Integer(1) or x == self - Integer(1) then
            goto continue
        end

        while r > Integer(0) do
            x = Integer.powmod(x, Integer(2), self)
            if x == self - Integer(1) then
                goto continue
            end
            r = r - Integer(1)
        end
        do
            return false
        end
        ::continue::
    end

    return true
end

-- returns the absolute value of an integer
function Integer:abs()
    if not self.isbignum then
        return Integer(math.abs(self.internal))
    end
    return Integer(self.internal:abs())
end

-----------------
-- Inheritance --
-----------------

__Integer.__index = EuclideanDomain
__Integer.__call = Integer.new
Integer = setmetatable(Integer, __Integer)