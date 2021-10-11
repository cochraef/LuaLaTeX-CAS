-- Interface for an element of a field
-- Fields have the following relation to other classes:
--      Fields extend Euclidean Domains
Field = {}
__Field = {}

----------------------------
-- Instance functionality --
----------------------------

function Field:div(b)
    return self.mul(b.inv())
end

function Field:inv()
    error("Called unimplemented method: inv()")
end

-- Field exponentiation based on the definition. Specific rings may implement more efficient methods.
function Field:pow(n)
    local base = self
    if(n < Integer(0)) then
        n = -n
        base = base:inv()
    end
    local k = Integer(0)
    local b = self.getRing().one()
    while k < n do
        b = b.mul(base)
        k = k + Integer(1)
    end
    return b
end

--------------------------
-- Instance metamethods --
--------------------------

__FieldOperations = Copy(__EuclideanOperations)

__FieldOperations.__div = function(a, b)
    if not b.getRing and b.isEvaluatable then
        return BinaryOperation.DIVEXP({a, b})
    end

    if(b == b:getRing():zero()) then
        error("Cannot divide by zero.")
    end

    local aring, bring = a:getRing(), b:getRing()
    if aring == bring then
        return a:div(b)
    end
    if aring.subringof(aring, bring) then
        return a:inRing(bring):div(b)
    end
    if bring.subringof(bring, aring) then
        return a:div(b:inRing(aring))
    end

end

-----------------
-- Inheritance --
-----------------

__Field.__index = EuclideanDomain
Field = setmetatable(Field, __Field)