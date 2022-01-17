-- Interface for an element of a ring with unity
-- Rings have the following relation to other classes:
--      Rings extend AtomicExpresssions
Ring = {}
__Ring = {}

--------------------------
-- Static functionality --
--------------------------

-- Determines which ring the output of a binary operation with inputs in ring1 and ring2 should be, if such a ring exists.
-- If one of the rings is a subring of another ring, the result should be one of the two rings.
function Ring.resultantring(ring1, ring2)
    if ring1 == ring2 then
        return ring1
    end

    if ring1 == PolynomialRing.getring() or ring2 == PolynomialRing.getring() then
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

-- Returns a particular instantiation of a ring.
-- Does the same thing as getring() if there is only one possible ring for a class, i.e., the integers and rationals\.
function Ring.makering()
    error("Called unimplemented method : makering()")
end

----------------------------
-- Instance functionality --
----------------------------

-- Returns the ring this element is part of.
function Ring:getring()
    error("Called unimplemented method : getring()")
end

-- Returns whether the ring is commutative.
function Ring:iscommutative()
    error("Called unimplemented method : isCommutative()")
end

function Ring:add(b)
    error("Called unimplemented method : add()")
end

function Ring:sub(b)
    return(self:add(b:neg()))
end

function Ring:neg()
    error("Called unimplemented method : neg()")
end

function Ring:mul(b)
    error("Called unimplemented method : mul()")
end

-- Ring exponentiation based on the definition. Specific rings may implement more efficient methods.
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

function Ring:eq(b)
    error("Execution error: Ring does not have a total order")
end

function Ring:lt(b)
    error("Execution error: Ring does not have a total order")
end

function Ring:le(b)
    error("Execution error: Ring does not have a total order")
end

-- The additive and multiplicative identities of the ring
function Ring:zero()
    error("Called unimplemented method : zero()")
end

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
    if not b.getring and b.isEvaluatable then
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
    if not b.getring and b.isEvaluatable then
        return BinaryOperation.SUBEXP({a, b})
    end

    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to subtract two elements of incompatable rings")
    end
    return a:inring(oring):sub(b:inring(oring))
end

__RingOperations.__mul = function(a, b)
    if not b.getring and b.isEvaluatable then
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
    if (not n.getring and n.isEvaluatable) or (n.getring and n:getring().ring ~= Integer) then
        return BinaryOperation.POWEXP({a, n})
    end

    if a == a:zero() and n == Integer.zero() then
        error("Cannot raise 0 to the power of 0")
    end

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

__Ring.__index = AtomicExpression
Ring = setmetatable(Ring, __Ring)
