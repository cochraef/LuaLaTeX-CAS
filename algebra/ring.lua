-- Interface for an element of a ring with unity
-- Rings have the following relation to other classes:
--      Rings extend AtomicExpresssions
Ring = {}
__Ring = {}

--------------------------
-- Static functionality --
--------------------------

-- Returns true if this ring is a subring of another ring; false otherwise
function Ring.subringof(this, other)
    if this == other then
        return true
    end
    for _, subring in ipairs(other.subrings(other)) do
        if this.subringof(this, subring) then
            return true
        end
    end
    return false
end

----------------------------
-- Instance functionality --
----------------------------

-- Returns the type of this object
function Ring:getRing()
    error("Called unimplemented method : getRing()")
end

-- Returns whether the ring is commutative
function Ring:isCommutative()
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
    if(n < Integer(0)) then
        error("Execution error: Negative exponentiation is undefined over general rings")
    end
    local k = Integer(0)
    local b = self.getRing().one(self)
    while k < n do
        b = b.mul(self)
        k = k + Integer(1)
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
-- then passing the arguments to the function in a specific ring

__RingOperations.__unm = function(a)
    return a:neg()
end

__RingOperations.__add = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:add(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):add(b)
    end
    if bring.subringof(bring, aring) then
        return a:add(b:inRing(aring))
    end

    error("Attempted to add two elements of different rings")
end

__RingOperations.__sub = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:sub(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):sub(b)
    end
    if bring.subringof(bring, aring) then
        return a:sub(b:inRing(aring))
    end

    error("Attempted to subtract two elements of different rings")
end

__RingOperations.__mul = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:mul(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):mul(b)
    end
    if bring.subringof(bring, aring) then
        return a:mul(b:inRing(aring))
    end

    error("Attempted to multiply two elements of different rings")
end

__RingOperations.__pow = function(a, n)
    if n:getRing() ~= Integer then
        error("Sent parameter of wrong type: exponent must be an integer")
    end

    if a == a.zero() and n == Integer(0) then
        error("Cannot raise 0 to the power of 0")
    end
    return a:pow(n)
end

-- Comparison operations assume, of course, that the ring operation is equipped with a total order
-- All elements of all rings need these metamethods, since in Lua comparisons on tables only fire if both objects have the table
__RingOperations.__eq = function(a, b)
    -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
    if not b.getRing then
        return false
    end
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:eq(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):eq(b)
    end
    if bring.subringof(bring, aring) then
        return a:eq(b:inRing(aring))
    end

    error("Attempted to compare two elements of different rings")
end

__RingOperations.__lt = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:lt(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):lt(b)
    end
    if bring.subringof(bring, aring) then
        return a:lt(b:inRing(aring))
    end

    error("Attempted to compare two elements of different rings")
end

__RingOperations.__le = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:le(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):le(b)
    end
    if bring.subringof(bring, aring) then
        return a:le(b:inRing(aring))
    end

    error("Attempted to compare two elements of different rings")
end

-----------------
-- Inheritance --
-----------------

__Ring.__index = AtomicExpression
Ring = setmetatable(Ring, __Ring)
