--- @class Field
--- Interface for an element of a field.
Field = {}
local __Field = {}

----------------------
-- Required methods --
----------------------

--- @return Field
function Field:div(b)
    return self:mul(b:inv())
end

--- @return Field
function Field:inv()
    error("Called unimplemented method: inv()")
end

----------------------------
-- Instance functionality --
----------------------------

--- Field exponentiation based on the definition. Specific rings may implement more efficient methods.
--- @return Field
function Field:pow(n)
    local base = self
    if(n < Integer.zero()) then
        n = -n
        base = base:inv()
    end
    local k = Integer.zero()
    local b = self.getring().one()
    while k < n do
        b = b.mul(base)
        k = k + Integer.one()
    end
    return b
end

--------------------------
-- Instance metamethods --
--------------------------

__FieldOperations = Copy(__EuclideanOperations)

__FieldOperations.__div = function(a, b)
    if not b.getring and not b:isconstant() then
        return BinaryOperation.DIVEXP({a, b})
    end

    if(b == b:zero()) then
        error("Arithmetic Error: Cannot divide by zero.")
    end

    local aring, bring = a:getring(), b:getring()
    local oring = Ring.resultantring(aring, bring)
    if not oring then
        error("Attempted to divide two elements of incompatable rings")
    end
    return a:inring(oring):div(b:inring(oring))
end

-----------------
-- Inheritance --
-----------------

__Field.__index = EuclideanDomain
Field = setmetatable(Field, __Field)