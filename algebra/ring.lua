-- Represents a ring with unity
-- Rings have the following static variables:
--      zero - the identity element of the additive group of this ring
--      ring - the identity element of the multiplicative group of this ring
-- Rings have the following instance variables:
--      addgroup - the additive group of this ring
--      mulgroup - the multiplicative operation of this ring
Ring = {}

--------------------------
-- Static functionality --
--------------------------

-- Returns true if this ring is a subring of another ring; false otherwise
function Ring.subringof(this, other)
    if this == other then
        return true
    end
    for _, subring in ipairs(other.subrings()) do
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
function Ring:getType()
    return Ring
end

-- Returns whether the ring is commutative
function Ring:isCommutative()
    return nil
end

--------------------------
-- Instance metamethods --
--------------------------
__RingOperations = {}

-- Each of these methods just handles coverting each element in the ring to an instance of the proper ring, if possible,
-- then passing the arguments to the function in a specific ring

__RingOperations.__unm = function(a)
    return a:inv()
end

__RingOperations.__add = function(a, b)
    local aring, bring = a:getType(), b:getType()
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
    local aring, bring = a:getType(), b:getType()
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
    local aring, bring = a:getType(), b:getType()
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
    if n.getType() ~= Integer then
        error("Unsupported domain for exponentiation")
    end
    return a:pow(n)
end

-- Division with remainder, assuming the ring is a Euclidean domain
-- Unfortunately, this can only return 1 result, so it returns the quotient - for the remainder use a % b, or a:divremainder(b)
__RingOperations.__idiv = function(a, b)
    local aring, bring = a:getType(), b:getType()
    if aring ~= bring then
        error("Attempted to divide two different rings with remainder")
    end
    return a:divremainder(b)
end

__RingOperations.__mod = function(a, b)
    local aring, bring = a:getType(), b:getType()
    if aring ~= bring then
        error("Attempted to divide two different rings with remainder")
    end
    local _,q = a:divremainder(b)
    return q
end

-- Comparison operations assume, of course, that the ring operation is equipped with a total order
-- All elements of all rings need these metamethods, since in Lua comparisons on tables only fire if both objects have the table
__RingOperations.__eq = function(a, b)
    local aring, bring = a:getType(), b:getType()
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
    local aring, bring = a:getType(), b:getType()
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
    local aring, bring = a:getType(), b:getType()
    if aring == bring then
        return a:eq(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):le(b)
    end
    if bring.subringof(bring, aring) then
        return a:le(b:inRing(aring))
    end

    error("Attempted to compare two elements of different rings")
end

function Ring:inv()
    return self.addgroup:inv()
end

function Ring:add(b)
    return self.addgroup:eval(self,b)
end

function Ring:sub(b)
    return self.addgroup:eval(self,b:inv())
end

function Ring:mul(b)
    return self.mulgroup:eval(self,b)
end

function Ring:pow(n)
    return self.mulgroup.pow(self, n)
end

function Ring:divremainder(b)
    error("Ring is not a euclidian domain, or no division with remainder algorithm exists")
end

function Ring:eq(b)
    error("Ring does not have a total order")
end

function Ring:lt(b)
    error("Ring does not have a total order")
end

function Ring:le(b)
    error("Ring does not have a total order")
end
