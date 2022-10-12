--- @class Ring
--- Interface for an element of a ring with unity.
Ring = {}
__Ring = {}

--------------------------
-- Static functionality --
--------------------------

--- Determines which ring the output of a binary operation with inputs in ring1 and ring2 should be, if such a ring exists.
--- If one of the rings is a subring of another ring, the result should be one of the two rings.
--- @param ring1 RingIdentifier
--- @param ring2 RingIdentifier
--- @return RingIdentifier
function Ring.resultantring(ring1, ring2)
    if ring1 == ring2 then
        return ring1
    end

    if ((ring1 == PolynomialRing.getring() and ring2 == Rational.getring()) or
       (ring2 == PolynomialRing.getring() and ring1 == Rational.getring()))
       and ring1.symbol == ring2.symbol then
        return Rational.makering(ring1.symbol, Ring.resultantring(ring1.child, ring2.child))
    end

    if ring1 == PolynomialRing.getring() or ring2 == PolynomialRing.getring() then
        if ring1 == ring2.child then
            return ring2
        end
        if ring2 == ring1.child then
            return ring1
        end

        if ring1 == PolynomialRing.getring() and ring2 == PolynomialRing.getring() and ring1.symbol == ring2.symbol then
            return PolynomialRing.makering(ring1.symbol, Ring.resultantring(ring1.child, ring2.child))
        end

        -- If none of the above conditions are satisfied, recusion is a pain, so we just strip all of the variables off of both rings.
        -- TODO: Make this properly recursive, or just use a multivariable polynomial ring class
        local symbols = {}
        while ring1 == PolynomialRing.getring() do
            symbols[#symbols+1] = ring1.symbol
            ring1 = ring1.child
        end
        while ring2 == PolynomialRing.getring() do
            if not Contains(symbols, ring2.symbol) then
                symbols[#symbols+1] = ring2.symbol
            end
            ring2 = ring2.child
        end
        local ring = Ring.resultantring(ring1, ring2)

        if ring == Rational.getring() and Contains(symbols, ring.symbol) then
            symbols = Remove(symbols, ring.symbol)
        end
        for i = #symbols, 1, -1 do
            ring = PolynomialRing.makering(symbols[i], ring)
        end
        return ring
    end

    if ring1 == Integer.getring() then
        if ring2 == Integer.getring() then
            return ring2
        end

        if ring2 == Rational.getring() then
            return ring2
        end

        if ring2 == IntegerModN.getring() then
            return ring2
        end
    end

    if ring1 == Rational.getring() then
        if ring2 == Integer.getring() then
            return ring1
        end

        if ring2 == Rational.getring() then
            if not ring1.symbol then
                return Rational.makering(ring2.symbol, Ring.resultantring(ring1, ring2.child))
            end
            if not ring2.symbol then
                return Rational.makering(ring1.symbol, Ring.resultantring(ring1.child, ring2))
            end
            if ring1.symbol and ring2.symbol and ring1.symbol == ring2.symbol then
                return Rational.makering(ring1.symbol, Ring.resultantring(ring1.child, ring2.child))
            end
            return ring2
        end

        if ring2 == IntegerModN.getring() then
            return nil
        end
    end

    if ring1 == IntegerModN.getring() then
        if ring2 == Integer.getring() then
            return ring1
        end

        if ring2 == Rational.getring() then
            return nil
        end

        if ring2 == IntegerModN.getring() then
            return IntegerModN.makering(Integer.gcd(ring1.modulus, ring2.modulus))
        end
    end

    return nil
end

--- Returns a particular instantiation of a ring.
--- Does the same thing as getring() if there is only one possible ring for a class, i.e., the integers and rationals.
--- @return RingIdentifier
function Ring.makering()
    error("Called unimplemented method : makering()")
end

----------------------
-- Required methods --
----------------------

--- Returns the ring this element is part of.
--- @return RingIdentifier
function Ring:getring()
    error("Called unimplemented method : getring()")
end

--- Explicitly converts this element to an element of another ring.
--- @param ring RingIdentifier
--- @return Ring
function Ring:inring(ring)
    error("Called unimplemented method : in()")
end

--- Returns whether the ring is commutative.
--- @return boolean
function Ring:iscommutative()
    error("Called unimplemented method : iscommutative()")
end

--- @return Ring
function Ring:add(b)
    error("Called unimplemented method : add()")
end

--- @return Ring
function Ring:sub(b)
    return(self:add(b:neg()))
end

--- @return Ring
function Ring:neg()
    error("Called unimplemented method : neg()")
end

--- @return Ring
function Ring:mul(b)
    error("Called unimplemented method : mul()")
end

--- Ring exponentiation by definition. Specific rings may implement more efficient methods.
--- @return Ring
function Ring:pow(n)
    if(n < Integer.zero()) then
        error("Execution error: Negative exponentiation is undefined over general rings")
    end
    local k = Integer.zero()
    local b = self:one()
    while k < n do
        b = b * self
        k = k + Integer.one()
    end
    return b
end

--- @return boolean
function Ring:eq(b)
    error("Execution error: Ring does not have a total order")
end

--- @return boolean
function Ring:lt(b)
    error("Execution error: Ring does not have a total order")
end

--- @return boolean
function Ring:le(b)
    error("Execution error: Ring does not have a total order")
end

--- The additive identitity of the ring.
--- @return Ring
function Ring:zero()
    error("Called unimplemented method : zero()")
end

--- The multiplicative identitity of the ring.
--- @return Ring
function Ring:one()
    error("Called unimplemented method : one()")
end

--------------------------
-- Instance metamethods --
--------------------------
__RingOperations = {}

-- Each of these methods just handles coverting each element in the ring to an instance of the proper ring, if possible,
-- then passing the arguments to the function in a specific ring.

__RingOperations.__unm = function(a)
    return a:neg()
end

__RingOperations.__add = function(a, b)
    if not b.getring then
        return BinaryOperation.ADDEXP({a, b})
    end

    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to add two elements of incompatable rings")
    end
    return a:inring(oring):add(b:inring(oring))
end

__RingOperations.__sub = function(a, b)
    if not b.getring then
        return BinaryOperation.SUBEXP({a, b})
    end

    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to subtract two elements of incompatable rings")
    end
    return a:inring(oring):sub(b:inring(oring))
end

-- Allows for multiplication by writing two expressions next to each other.
__RingOperations.__call = function (a, b)
    return a * b
end

__RingOperations.__mul = function(a, b)
    if not b.getring then
        return BinaryOperation.MULEXP({a, b})
    end

    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to muliply two elements of incompatable rings")
    end
    return a:inring(oring):mul(b:inring(oring))
end

__RingOperations.__pow = function(a, n)
    if (not n.getring) or (n.getring and n:getring().ring ~= Integer) then
        return BinaryOperation.POWEXP({a, n})
    end

    -- if a == a:zero() and n == Integer.zero() then
    --     error("Cannot raise 0 to the power of 0")
    -- end

    return a:pow(n)
end

-- Comparison operations assume, of course, that the ring operation is equipped with a total order
-- All elements of all rings need these metamethods, since in Lua comparisons on tables only fire if both objects have the table
__RingOperations.__eq = function(a, b)
    -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
    if not a.getring or not b.getring then
        return false
    end
    local aring, bring = a:getring(), b:getring()
    if aring == bring then
        return a:eq(b)
    end
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to compare two elements of incompatable rings")
    end
    return a:inring(oring):eq(b:inring(oring))
end

__RingOperations.__lt = function(a, b)
    local aring, bring = a:getring(), b:getring()
    if aring == bring then
        return a:lt(b)
    end
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to compare two elements of incompatable rings")
    end
    return a:inring(oring):lt(b:inring(oring))
end

__RingOperations.__le = function(a, b)
    local aring, bring = a:getring(), b:getring()
    if aring == bring then
        return a:le(b)
    end
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to compare two elements of incompatable rings")
    end
    return a:inring(oring):le(b:inring(oring))
end

-----------------
-- Inheritance --
-----------------

__Ring.__index = ConstantExpression
Ring = setmetatable(Ring, __Ring)

--- Used for comparing and converting between rings.
--- @class RingIdentifier
