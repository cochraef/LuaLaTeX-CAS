-- Represents a field, which is also a ring
Field = {}

----------------------------
-- Instance functionality --
----------------------------

-- Returns the type of this object
function Field:getType()
    return "Field"
end

-- Returns whether the field is commutative
function Field:isCommutative()
    return true
end

--------------------------
-- Instance metamethods --
--------------------------

