-- Interface for an element of a euclidean domain
-- EuclideanDomains have the following relation to other classes:
--      EuclideanDomains extend Rings
EuclideanDomain = {}
__EuclideanDomain = {}

----------------------------
-- Instance functionality --
----------------------------

-- Euclidean domains are always commutative
function EuclideanDomain:iscommutative()
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
    if(b == b:zero()) then
        error("Cannot divide by zero.")
    end
    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to divide two elements of incompatable rings")
    end
    return a:inring(oring):divremainder(b:inring(oring))
end

__EuclideanOperations.__mod = function(a, b)
    if(b == b:zero()) then
        error("Cannot divide by zero.")
    end
    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to divide two elements of incompatable rings")
    end
    local _,q = a:inring(oring):divremainder(b:inring(oring))
    return q
end

-----------------
-- Inheritance --
-----------------

__EuclideanDomain.__index = Ring
EuclideanDomain = setmetatable(EuclideanDomain, __EuclideanDomain)