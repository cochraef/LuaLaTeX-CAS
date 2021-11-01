-- Represents an element of the ring of integers mod n (this is also a field iff n is prime)
-- Integers Mod n have the following instance variables:
--      int - the integer itself
--      n - the value in Z/nZ
-- Integers Mod n have the following relationship to other classes:
--      Integers implement rings
--      Integers mod p implement fields

IntegerModN = {}
__IntegerModN = {}

--------------------------
-- Static functionality --
--------------------------

-- Returns the immediate subrings of this ring
-- Integers are considered subrings of their quotient rings for conversion purposes
function IntegerModN.subrings()
    return {Integer:getRing()}
end

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new integer i in Z/nZ
function IntegerModN:new(i, n)
    local o = {}
    local __o

    if not n or n:getRing() ~= Integer:getRing() or n < Integer(1) then
        error("Argument error: modulus must be an integer greater than 0.")
    end


    if n:isprime() then
        __o = Copy(__FieldOperations)
    else
        __o = Copy(__RingOperations)
    end

    __o.__index = IntegerModN
    __o.__tostring = function(a)
        return tostring(a.element)
    end
    o = setmetatable(o, __o)

    if i < Integer(0) or i >= n then
        i = i % n
    end

    o.element = i
    o.modulus = n

    return o
end

-- Returns the ring this object is an element of
function IntegerModN:getRing()
    local t = {ring = IntegerModN}
    if self then
        t.modulus = self.modulus
    end
    t = setmetatable(t, {__index = IntegerModN, __eq = function(a, b)
        return a["ring"] == b["ring"] and (a["modulus"] == b["modulus"] or a["modulus"] == nil or b["modulus"] == nil)
    end})
    return t;
end

-- Explicitly converts this element to an element of another ring
function IntegerModN:inRing(ring)
    if ring.ring == IntegerModN then
        if ring.modulus then
            return IntegerModN(self.element, Integer.gcd(self.modulus, ring.modulus))
        end
        return self
    end

    if Ring.subringof(PolynomialRing:getRing(), ring) then
        return PolynomialRing({self}, ring["symbol"]):inRing(ring)
    end

    if Ring.subringof(Integer:getRing(), ring) then
        return self
    end

    error("Unable to convert element to proper ring.")
end

function IntegerModN:add(b)
    return IntegerModN(self.element + b.element, self.modulus)
end

function IntegerModN:neg()
    return IntegerModN(-self.element, self.modulus)
end

function IntegerModN:mul(b)
    return IntegerModN(self.element * b.element, self.modulus)
end

-- Overrides the generic power method with powmod
function IntegerModN:pow(b)
    return IntegerModN(Integer.powmod(self.element, b, self.modulus), self.modulus)
end

-- Only works if the modulus is prime
function IntegerModN:div(b)
    return IntegerModN(self.element * b:inv().element, self.modulus)
end

-- Returns the multiplicative inverse of this number if it exists
function IntegerModN:inv()
    local t = Integer(0)
    local r = self.modulus
    local newt = Integer(1)
    local newr = self.element

    while newr ~= Integer(0) do
        local q = r // newr
        t, newt = newt, t - q * newt
        r, newr = newr, r - q * newr
    end

    if r > Integer(1) then
        error("Element does not have an inverse in this ring")
    end

    return IntegerModN(t, self.modulus)
end

function IntegerModN:eq(b)
    return self.element == b.element
end

function IntegerModN:lt(b)
    return self.element < b.element
end

function IntegerModN:le(b)
    return self.element <= b.element
end

function IntegerModN:zero()
    if not self or not self.modulus then
        return Integer(0)
    end
    return IntegerModN(Integer(0), self.modulus)
end

function IntegerModN:one()
    if not self or not self.modulus then
        return Integer(1)
    end
    return IntegerModN(Integer(1), self.modulus)
end

-----------------
-- Inheritance --
-----------------

__IntegerModN.__index = Ring
__IntegerModN.__call = IntegerModN.new
IntegerModN = setmetatable(IntegerModN, __IntegerModN)