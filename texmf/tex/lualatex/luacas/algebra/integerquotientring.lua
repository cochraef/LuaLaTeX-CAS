--- @class IntegerModN
--- Represents an element of the ring of integers mod n (this is also a field iff n is prime).
--- @field element Integer
--- @field modulus Integer

IntegerModN = {}
__IntegerModN = {}

-- Metatable for ring objects.
local __obj = {__index = IntegerModN, __eq = function(a, b)
    return a["ring"] == b["ring"] and (a["modulus"] == b["modulus"] or a["modulus"] == nil or b["modulus"] == nil)
end, __tostring = function(a)
    if a.modulus then return "Z/Z" .. tostring(a.modulus) else return "(Generic Integer Mod Ring)" end
end}

--------------------------
-- Static functionality --
--------------------------

--- Creates a new ring with the given modulus.
--- @param modulus Integer
--- @return RingIdentifier
function IntegerModN.makering(modulus)
    local t = {ring = IntegerModN}
    t.modulus = modulus
    t = setmetatable(t, __obj)
    return t
end

-- Shorthand constructor for a ring with a particular modulus.
function IntegerModN.R(modulus)
    return IntegerModN.makering(modulus)
end

----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the field operations each time
local __o
__o = Copy(__FieldOperations)

__o.__index = IntegerModN
__o.__tostring = function(a)
    return tostring(a.element)
end

--- Creates a new integer i in Z/nZ.
--- @param i Integer
--- @param n Integer
--- @return IntegerModN
function IntegerModN:new(i, n)
    local o = {}

    if n:getring() ~= Integer:getring() or n < Integer.one() then
        error("Argument error: modulus must be an integer greater than 0.")
    end

    o = setmetatable(o, __o)

    if i < Integer.zero() or i >= n then
        i = i % n
    end

    o.element = i
    o.modulus = n

    return o
end

--- @return RingIdentifier
function IntegerModN:getring()
    local t = {ring = IntegerModN}
    if self then
        t.modulus = self.modulus
    end
    t = setmetatable(t, __obj)
    return t
end

--- @param ring RingIdentifier
--- @return Ring
function IntegerModN:inring(ring)
    if ring == IntegerModN:getring() then
        if ring.modulus then
            return IntegerModN(self.element, ring.modulus)
        end
        return self
    end

    if ring == PolynomialRing:getring() then
        return PolynomialRing({self:inring(ring.child)}, ring.symbol)
    end

    if ring == Rational:getring() and ring.symbol then
        return Rational(self:inring(ring.child), self:inring(ring.child):one(), true)
    end

    if ring == Integer:getring() then
        return self.element:inring(ring)
    end

    error("Unable to convert element to proper ring.")
end

--- @param b IntegerModN
--- @return IntegerModN
function IntegerModN:add(b)
    return IntegerModN(self.element + b.element, self.modulus)
end

--- @return IntegerModN
function IntegerModN:neg()
    return IntegerModN(-self.element, self.modulus)
end

--- @param b IntegerModN
--- @return IntegerModN
function IntegerModN:mul(b)
    return IntegerModN(self.element * b.element, self.modulus)
end

-- Overrides the generic power method with powmod.
--- @param b IntegerModN
--- @return IntegerModN
function IntegerModN:pow(b)
    return IntegerModN(Integer.powmod(self.element, b.element, self.modulus), self.modulus)
end

-- Returns the multiplicative inverse of this number if it exists.
--- @return IntegerModN
function IntegerModN:inv()
    local r, t, _ = Integer.extendedgcd(self.element, self.modulus)

    if r > Integer.one() then
        error("Element does not have an inverse in this ring")
    end

    return IntegerModN(t, self.modulus)
end

--- @param b IntegerModN
--- @return IntegerModN
function IntegerModN:div(b)
    return self:mul(b:inv())
end

--- @param b IntegerModN
--- @return boolean
function IntegerModN:eq(b)
    return self.element == b.element
end

--- @param b IntegerModN
--- @return boolean
function IntegerModN:lt(b)
    return self.element < b.element
end

--- @param b IntegerModN
--- @return boolean
function IntegerModN:le(b)
    return self.element <= b.element
end

--- @return IntegerModN
function IntegerModN:zero()
    if not self or not self.modulus then
        return Integer.zero()
    end
    return IntegerModN(Integer.zero(), self.modulus)
end

--- @return IntegerModN
function IntegerModN:one()
    if not self or not self.modulus then
        return Integer.one()
    end
    return IntegerModN(Integer.one(), self.modulus)
end

--- @return string
function IntegerModN:tolatex(mod)
    mod = mod or false
    if mod then
        return self.element:tolatex() .. "\\bmod{" .. self.modulus:tolatex() .. "}"
    else
        return self.element:tolatex()
    end
end
-----------------
-- Inheritance --
-----------------

__IntegerModN.__index = Field
__IntegerModN.__call = IntegerModN.new
IntegerModN = setmetatable(IntegerModN, __IntegerModN)