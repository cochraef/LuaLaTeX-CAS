-- Represents a group
-- Groups have the following static variables:
--      identity - the identity element of the Group
-- Groups have the following relations to other classes:
--      Groups are subinterfaces to BinaryOperations
Group = {}
__Group = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new group operation with the given operation
function Group:new(bo)
    local o = BinaryOperation(bo)
    local mt = {__index = Group, __call = Group.eval}
    o = setmetatable(o, mt)

    return o
end

-- Returns the type of this object
function Group:getType()
    return "Group"
end

-- Returns whether the group is associative
function Group:isAssociative()
    return true
end

-- Returns whether the group is abelian
function Group:isAbelian()
    return nil
end

-- Returns the inverse of an element in a group
function Group:inv()
    return nil
end

-----------------
-- Inheritance --
-----------------

__Group.__index = BinaryOperation
__Group.__call = Group.new
Group = setmetatable(Group, __Group)

