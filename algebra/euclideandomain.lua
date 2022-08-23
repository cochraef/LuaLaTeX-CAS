--- @class EuclideanDomain
--- Interface for an element of a euclidean domain.
EuclideanDomain = {}
__EuclideanDomain = {}

----------------------
-- Required methods --
----------------------

--- @param b EuclideanDomain
--- @return EuclideanDomain, EuclideanDomain
function EuclideanDomain:divremainder(b)
    error("Called unimplemented method : divremainder()")
end

----------------------------
-- Instance functionality --
----------------------------

--- @return boolean
function EuclideanDomain:iscommutative()
    return true
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