-- Represents a field, which is also a ring
Field = {}

----------------------------
-- Instance functionality --
----------------------------

-- Returns the type of this object
function Field:getType()
    return Field
end

-- Returns whether the field is commutative
function Field:isCommutative()
    return true
end

--------------------------
-- Instance metamethods --
--------------------------

__FieldOperations = Copy(__RingOperations)

__FieldOperations.__div = function(a, b)
    if(b == b.getType().zero) then
        error("Cannot divide by zero.")
    end

    local aring, bring = a:getType(), b:getType()
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