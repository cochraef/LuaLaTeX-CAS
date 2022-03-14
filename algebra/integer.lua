-- Represents an element of the ring of integers.
-- Integers have the following instance variables:
--      1, 2, 3, etc. - the unsigned digits that represent the number in 'little endian' - least significant digit first
--      sign - 1 for positive integers, -1 for negative, 0 for 0
-- Integers have the following relationship to other classes:
--      Integers implement Euclidean Domains
Integer = {}
__Integer = {}

--------------------------
-- Static functionality --
--------------------------

-- The length of each digit in base 10. 10^15 < 2^53 < 10^16, so 15 is the highest value that will work with double-percision numbers.
-- For multiplication to work properly, however, this also must be even so we can take the square root of the digit size exaxtly.
-- 10^14 is still larger than 2^26, so it is still efficient to do multiplication this way.
Integer.DIGITLENGTH = 14;
-- The maximum size for a digit. While this doesn't need to be a power of 10, it makes implementing converting to and from strings much easier.
Integer.DIGITSIZE = 10 ^ Integer.DIGITLENGTH;
-- Partition size for multiplying integers so we can get both the upper and lower bits of each digits
Integer.PARTITIONSIZE = math.floor(math.sqrt(Integer.DIGITSIZE))

-- Method for computing the gcd of two integers using Euclid's algorithm
function Integer.gcd(a, b)
    while b ~= Integer.zero() do
        a, b = b, a%b
    end
    return a
end

-- Method for computing the gcd of two integers using Euclid's algorithm
-- Also returns Bezout's coefficients via extended gcd
function Integer.extendedgcd(a, b)
    local oldr, r  = a, b
    local olds, s  = Integer.one(), Integer.zero()
    local oldt, t  = Integer.zero(), Integer.one()
    while r ~= Integer.zero() do
        local q = oldr // r
        oldr, r  = r, oldr - q*r
        olds, s = s, olds - q*s
        oldt, t = t, oldt - q*t
    end
    return oldr, olds, oldt
end

-- Method for computing the larger of two integers.
-- Also returns the other integer for sorting purposes.
function Integer.max(a, b)
    if a > b then
        return a, b
    end
    return b, a
end

-- Methods for computing the larger magnitude of two integers.
-- Also returns the other integer for sorting purposes, and the number -1 if the two values were swapped, 1 if not.
function Integer.absmax(a, b)
    if b:ltabs(a) then
        return a, b, 1
    end
    return b, a, -1
end

-- Returns the ceiling of the log base (defaults to 10) of a
-- In other words, returns the least n such that base^n > a
function Integer.ceillog(a, base)
    base = base or Integer(10)
    local k = Integer.zero()

    while (base ^ k) < a do
        k = k + Integer.one()
    end

    return k
end

-- Returns a ^ b (mod n). This should be used when a ^ b is potentially large.
function Integer.powmod(a, b, n)
    if n == Integer.one() then
        return Integer.zero()
    else
        local r = Integer.one()
        a = a % n
        while b > Integer.zero() do
          if b % Integer(2) == Integer.one() then
            r = (r * a) % n
          end
          a = (a ^ Integer(2)) % n
          b = b // Integer(2)
        end
        return r
    end
end

----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the Euclidean operations each time we create an integer.
local __o = Copy(__EuclideanOperations)
__o.__index = Integer
__o.__tostring = function(a) -- Only works if the digit size is a power of 10
    local out = ""
    for i, digit in ipairs(a) do
        local pre = tostring(math.floor(digit))
        if i ~= #a then
            while #pre ~= Integer.DIGITLENGTH do
                pre = "0" .. pre
            end
        end
        out = pre .. out
    end
    if a.sign == -1 then
        out = "-" .. out
    end
    return out
end
__o.__div = function(a, b)   -- Constructor for a rational number disguised as division
    if not b.getring then
        return BinaryOperation.DIVEXP({a, b});
    end
    if(a:getring() == Integer:getring() and b:getring() == Integer:getring()) then
        return Rational(a, b)
    end
    return __FieldOperations.__div(a, b)
end

-- Creates a new integer given a string or number representation of the integer
function Integer:new(n)
    local o = {}
    o = setmetatable(o, __o)

    if not n then
        o[1] = 0
        o.sign = 0
        return o
    end

    -- Can convert any floating-point number into an integer, though we generally only want to pass whole numbers into this.
    -- This will only approximate very large floating point numbers to a small proportion of the total significant digits
    -- After that the result will just be nonsense - strings should probably be used for big numbers
    if type(n) == "number" then
        n = math.floor(n)
        if n == 0 then
            o[1] = 0
            o.sign = 0
        else
            if n < 0 then
                n = -n
                o.sign = -1
            else
                o.sign = 1
            end
            local i = 1
            while n >= Integer.DIGITSIZE do
                o[i] = n % Integer.DIGITSIZE
                n = n // Integer.DIGITSIZE
                i = i + 1
            end
            o[i] = n
        end
    -- Only works on strings that are exact (signed) integers
    elseif type(n) == "string" then
        if not tonumber(n) then
            error("Sent parameter of wrong type: " .. n .. " is not an integer.")
        end
        if n == "0" then
            o[1] = 0
            o.sign = 0
        else
            local s = 1
            if string.sub(n, 1, 1) == "-" then
                s = s + 1
                o.sign = -1
            else
                o.sign = 1
            end

            while string.sub(n, s, s) == "0" do
                s = s + 1
            end

            local e = #n
            local i = 1
            while e > s + Integer.DIGITLENGTH - 1 do
                o[i] = tonumber(string.sub(n, e - Integer.DIGITLENGTH + 1, e))
                e = e - Integer.DIGITLENGTH
                i = i + 1
            end
            o[i] = tonumber(string.sub(n, s, e)) or 0
        end
    -- Copying is expensive in Lua, so this constructor probably should only sparsely be called with an Integer argument.
    elseif type(n) == "table" then
        o = Copy(n)
    else
        error("Sent parameter of wrong type: Integer does not accept " .. type(n) .. ".")
    end

    return o
end

-- Returns the ring this object is an element of
local t = {ring=Integer}
t = setmetatable(t, {__index = Integer, __eq = function(a, b)
    return a["ring"] == b["ring"]
end, __tostring = function(a)
    return "ZZ"
end})
function Integer:getring()
    return t;
end

-- Explicitly converts this element to an element of another ring.
function Integer:inring(ring)
    if ring == self:getring() then
        return self
    end

    if ring == PolynomialRing:getring() then
        return PolynomialRing({self:inring(ring.child)}, ring.symbol)
    end

    if ring == Rational:getring() then
        return Rational(self, Integer.one(), true):inring(ring)
    end

    if ring == IntegerModN:getring() then
        return IntegerModN(self, ring.modulus)
    end

    error("Unable to convert element to proper ring.")
end

function Integer:add(b)
    if self.sign == 1 and b.sign == -1 then
        return self:usub(b, 1)
    end
    if self.sign == -1 and b.sign == 1 then
        return self:usub(b, -1)
    end

    local sign = self.sign
    if sign == 0 then
        sign = b.sign
    end
    return self:uadd(b, sign)
end

-- Addition without sign so we don't have to create an entire new integer when switching signs.
function Integer:uadd(b, sign)
    local o = Integer()
    o.sign = sign

    local c = 0
    local n = math.max(#self, #b)
    for i = 1, n do
        local s = (self[i] or 0) + (b[i] or 0) + c
        if s >= Integer.DIGITSIZE then
            o[i] = s - Integer.DIGITSIZE
            c = 1
        else
            o[i] = s
            c = 0
        end
    end
    if c == 1 then
        o[n + 1] = c
    end
    return o
end

function Integer:sub(b)
    if self.sign == 1 and b.sign == -1 then
        return self:uadd(b, 1)
    end
    if self.sign == -1 and b.sign == 1 then
        return self:uadd(b, -1)
    end
    
    local sign = self.sign
    if sign == 0 then
        sign = b.sign
    end
    return self:usub(b, sign)
end

-- Subtraction without sign so we don't have to create an entire new integer when switching signs.
-- Uses subtraction by compliments.
function Integer:usub(b, sign)
    local a, b, swap = Integer.absmax(self, b)
    local o = Integer()
    o.sign = sign * swap

    local c = 0
    local n = #a
    for i = 1, n do
        local s = (a[i] or 0) + Integer.DIGITSIZE - 1 - (b[i] or 0) + c
        if i == 1 then
            s = s + 1
        end
        if s >= Integer.DIGITSIZE then
            o[i] = s - Integer.DIGITSIZE
            c = 1
        else
            o[i] = s
            c = 0
        end
    end

    -- Remove leading zero digits, since we want integer representations to be unique.
    while o[n] == 0 do
        o[n] = nil
        n = n - 1
    end

    if not o[1] then
        o[1] = 0
        o.sign = 0
    end

    return o
end

function Integer:neg()
    local o = Integer()
    o.sign = -self.sign
    for i, digit in ipairs(self) do
        o[i] = digit
    end
    return o
end

function Integer:mul(b)
    local o = Integer()
    o.sign = self.sign * b.sign
    if o.sign == 0 then
        o[1] = 0
        return o
    end

    -- Fast single-digit multiplication in the most common case
    if #self == 1 and #b == 1 then
        o[2], o[1] = self:mulone(self[1], b[1])

        if o[2] == 0 then
            o[2] = nil
        end

        return o
    end

    -- "Grade school" multiplication algorithm for numbers with small numbers of digits works faster than Karatsuba
    local n = #self
    local m = #b
    o[1] = 0
    o[2] = 0
    for i = 2, n+m do
        o[i + 1] = 0
        for j = math.max(1, i-m), math.min(n, i-1) do
            local u, l = self:mulone(self[j], b[i - j])
            o[i - 1] = o[i - 1] + l
            o[i] = o[i] + u
            if o[i - 1] >= Integer.DIGITSIZE then
                o[i - 1] = o[i - 1] - Integer.DIGITSIZE
                o[i] = o[i] + 1
            end
            if o[i] >= Integer.DIGITSIZE then
                o[i] = o[i] - Integer.DIGITSIZE
                o[i + 1] = o[i + 1] + 1
            end
        end
    end

    -- Remove leading zero digits, since we want integer representations to be unique.
    if o[n+m+1] == 0 then
        o[n+m+1] = nil
    end

    if o[n+m] == 0 then
        o[n+m] = nil
    end

    return o
end

-- Multiplies two single-digit numbers and returns two digits
function Integer:mulone(a, b)
    local P = Integer.PARTITIONSIZE

    local a1 = a // P
    local a2 = a % P
    local b1 = b // P
    local b2 = b % P

    local u = a1 * b1
    local l = a2 * b2

    local m = ((a1 * b2) + (b1 * a2))
    local mu = m // P
    local ml = m % P

    u = u + mu
    l = l + ml * P

    if l >= Integer.DIGITSIZE then
        l = l - Integer.DIGITSIZE
        u = u + 1
    end

    return u, l
end

-- Naive exponentiation is slow even for small exponents, so this uses binary exponentiation.
function Integer:pow(b)
    if b < Integer.zero() then
        return Integer.one() / (self ^ -b)
    end

    if b == Integer.zero() then
        return Integer.one()
    end

    -- Fast single-digit exponentiation
    if #self == 1 and #b == 1 then
        local test = (self.sign * self[1]) ^ b[1]
        if test < Integer.DIGITSIZE and test > -Integer.DIGITSIZE then
            return Integer(test)
        end
    end

    local x = self
    local y = Integer.one()
    while b > Integer.one() do
        if b[1] % 2 == 0 then
            x = x * x
            b = b:divbytwo()
        else
            y = x * y
            x = x * x
            b = b:divbytwo()
        end
    end

    return x * y
end

-- Fast integer division by two for binary exponentiation.
function Integer:divbytwo()
    local o = Integer()
    o.sign = self.sign
    for i = #self, 1, -1 do
        if self[i] % 2 == 0 then
            o[i] = self[i] // 2
        else
            o[i] = self[i] // 2
            if i ~= 1 then
                o[i - 1] = self[i - 1] * 2
            end
        end
    end
    return o
end

-- Division with remainder over the integers. Uses the standard base 10 long division algorithm.
function Integer:divremainder(b)
    if self >= Integer.zero() and b > self or self <= Integer.zero() and b < self then
        return Integer.zero(), Integer(self)
    end

    if #self == 1 and #b == 1 then
        return Integer((self[1]*self.sign) // (b[1]*b.sign)), Integer((self[1]*self.sign) % (b[1]*b.sign))
    end

    local Q = Integer()
    local R = Integer()

    Q.sign = self.sign * b.sign
    R.sign = 1
    local negativemod = false
    if b.sign == -1 then
        b.sign = -b.sign
        negativemod = true
    end

    for i = #self, 1, -1 do
        local s = tostring(math.floor(self[i]))
        while i ~= #self and #s ~= Integer.DIGITLENGTH do
            s = "0" .. s
        end
        Q[i] = 0
        for j = 1, #s do
            R = R:mulbyten()
            R[1] = R[1] + tonumber(string.sub(s, j, j))
            if R[1] > 0 then
                R.sign = 1
            end
            while R >= b do
                R = R - b
                Q[i] = Q[i] + 10^(#s - j)
            end
        end
    end

    -- Remove leading zero digits, since we want integer representations to be unique.
    while Q[#Q] == 0 do
        Q[#Q] = nil
    end

    if negativemod then
        R = -R
        b.sign = -b.sign
    elseif self.sign == -1 then
        R = b - R
    end

    return Q, R
end

-- Fast in-place multiplication by ten for the division algorithm. This means the number IS MODIFIED by this method unlike the rest of the library.
function Integer:mulbyten()
    local DIGITSIZE = Integer.DIGITSIZE
    for i, _ in ipairs(self) do
        self[i] = self[i] * 10
    end
    for i, _ in ipairs(self) do
        if self[i] > DIGITSIZE then
            local msd = self[i] // DIGITSIZE
            if self[i+1] then
                self[i+1] = self[i+1] + msd
            else
                self[i+1] = msd
            end
            self[i] = self[i] - DIGITSIZE*msd
        end
    end
    return self
end

function Integer:eq(b)
    for i, digit in ipairs(self) do
        if not b[i] or not (b[i] == digit) then
            return false
        end
    end
    return #self == #b and self.sign == b.sign
end

function Integer:lt(b)
    local selfsize = #self
    local bsize = #b
    if selfsize < bsize then
        return b.sign == 1
    end
    if selfsize > bsize then
        return self.sign == -1
    end
    local n = selfsize
    while n > 0 do
        if self[n]*self.sign < b[n]*b.sign then
            return true
        end
        if self[n]*self.sign > b[n]*b.sign then
            return false
        end
        n = n - 1
    end
    return false
end

-- Same as less than, but ignores signs.
function Integer:ltabs(b)
    if #self < #b then
        return true
    end
    if #self > #b then
        return false
    end
    local n = #self
    while n > 0 do
        if self[n] < b[n] then
            return true
        end
        if self[n] > b[n] then
            return false
        end
        n = n - 1
    end
    return false
end

function Integer:le(b)
    local selfsize = #self
    local bsize = #b
    if selfsize < bsize then
        return b.sign == 1
    end
    if selfsize > bsize then
        return self.sign == -1
    end
    local n = selfsize
    while n > 0 do
        if self[n]*self.sign < b[n]*b.sign then
            return true
        end
        if self[n]*self.sign > b[n]*b.sign then
            return false
        end
        n = n - 1
    end
    return true
end

local zero = Integer:new(0)
function Integer:zero()
    return zero
end

local one = Integer:new(1)
function Integer:one()
    return one
end

-- Returns this integer as a floating point number. Can only approximate the value of large integers.
function Integer:asnumber()
    local n = 0
    for i, digit in ipairs(self) do
        n = n + digit * Integer.DIGITSIZE ^ (i - 1)
    end
    return self.sign*math.floor(n)
end

-- Returns all positive divisors of the integer. Not guarenteed to be in any order.
function Integer:divisors()
    local primefactors = self:primefactorizationrec()
    local divisors = {}

    local terms = {}
    for prime in pairs(primefactors) do
        if prime == Integer(-1) then
            primefactors[prime] = nil
        end
        terms[prime] = Integer.zero()
    end

    local divisor = Integer.one()

    while true do
        divisors[#divisors+1] = divisor
        for prime, power in pairs(primefactors) do
            if terms[prime] < power then
                terms[prime] = terms[prime] + Integer.one()
                divisor = divisor * prime
                break
            else
                terms[prime] = Integer.zero()
                divisor = divisor / (prime ^ power)
            end
        end
        if divisor == Integer.one() then
            break
        end
    end

    return divisors
end

-- Returns the prime factorization of this integer as a expression.
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

-- Recursive part of prime factorization using Pollard Rho.
function Integer:primefactorizationrec()
    if self < Integer.zero() then
        return Integer.mergefactors({[Integer(-1)]=Integer.one()}, (-self):primefactorizationrec())
    end
    if self == Integer.one() then
        return {[Integer.one()]=Integer.one()}
    end
    local result = self:findafactor()
    if result == self then
        return {[result]=Integer.one()}
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
        return self
    end

    if self % Integer(2) == Integer.zero() then
        return Integer(2)
    end

    if self % Integer(3) == Integer.zero() then
        return Integer(3)
    end

    if self % Integer(5) == Integer.zero() then
        return Integer(5)
    end

    local g = function(x)
        local temp = Integer.powmod(x, Integer(2), self)
        return temp
    end

    local xstart = Integer(2)
    while xstart < self do
        local x = xstart
        local y = xstart
        local d = Integer.one()
        while d == Integer.one() do
            x = g(x)
            y = g(g(y))
            d = Integer.gcd((x - y):abs(), self)
        end

        if d < self then
            return d
        end

        xstart = xstart + Integer.one()
    end
end

-- uses Miller-Rabin to determine whether a number is prime up to a very large number.
local smallprimes = {Integer:new(2), Integer:new(3), Integer:new(5), Integer:new(7), Integer:new(11), Integer:new(13), Integer:new(17),
Integer:new(19), Integer:new(23), Integer:new(29), Integer:new(31), Integer:new(37), Integer:new(41), Integer:new(43), Integer:new(47)}

function Integer:isprime()
    if self % Integer(2) == Integer.zero() then
        return false
    end

    if self == Integer.one() then
        return false
    end

    for _, value in pairs(smallprimes) do
        if value == self then
            return true
        end
    end

    local r = Integer.zero()
    local d = self - Integer.one()
    while d % Integer(2) == Integer.zero() do
        r = r + Integer.one()
        d = d / Integer(2)
    end

    for _, a in ipairs(smallprimes) do
        local x = Integer.powmod(a, d, self)
        if x == Integer.one() or x == self - Integer.one() then
            goto continue
        end

        while r > Integer.zero() do
            x = Integer.powmod(x, Integer(2), self)
            if x == self - Integer.one() then
                goto continue
            end
            r = r - Integer.one()
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
    if self.sign >= 0 then
        return Integer(self)
    end
    return -self
end

-----------------
-- Inheritance --
-----------------

__Integer.__index = EuclideanDomain
__Integer.__call = Integer.new
Integer = setmetatable(Integer, __Integer)