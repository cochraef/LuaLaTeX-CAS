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
    if aring ~= bring then
        error("Attempted to divide two different rings with remainder")
    end
    return a:divremainder(b)
end

__EuclideanOperations.__mod = function(a, b)
    local aring, bring = a:getRing(), b:getRing()
    if aring ~= bring then
        error("Attempted to divide two different rings with remainder")
    end
    local _,q = a:divremainder(b)
    return q
end

-----------------
-- Inheritance --
-----------------

__EuclideanDomain.__index = Ring
EuclideanDomain = setmetatable(EuclideanDomain, __EuclideanDomain)