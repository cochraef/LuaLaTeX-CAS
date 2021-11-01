-- Interface for an element of a euclidean domain
-- EuclideanDomains have the following relation to other classes:
--      EuclideanDomains extend Rings
EuclideanDomain = {}
__EuclideanDomain = {}

----------------------------
-- Instance functionality --
----------------------------

-- Euclidean domains are always commutative
function EuclideanDomain:isCommutative()
    return true
end

function EuclideanDomain:divremainder(b)
    error("Called unimplemented method : divremainder()")
end

--------------------------
-- Instance metamethods --
--------------------------

__EuclideanOperations = Copy(__RingOperations)

-- Division with remainder
-- Unfortunately, this can only return 1 result, so it returns the quotient - for the remainder use a % b, or a:divremainder(b)
__EuclideanOperations.__idiv = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:divremainder(b)
    end
    if Ring.subringof(aring, bring) then
        return a:inRing(bring):divremainder(b)
    end
    if Ring.subringof(bring, aring) then
        return a:divremainder(b:inRing(aring))
    end

    error("Attempted to divide two elements of different rings with remainder")
end

__EuclideanOperations.__mod = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        local _,q = a:divremainder(b)
        return q
    end
    if Ring.subringof(aring, bring) then
        local _,q = a:inRing(bring):divremainder(b)
        return q

    end
    if Ring.subringof(bring, aring) then
        local _,q = a:divremainder(b:inRing(aring))
        return q
    end

    error("Attempted to divide two elements of different rings with remainder")
end

-----------------
-- Inheritance --
-----------------

__EuclideanDomain.__index = Ring
EuclideanDomain = setmetatable(EuclideanDomain, __EuclideanDomain)