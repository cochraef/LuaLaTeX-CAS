-- Represents a binary operation
-- Typically, BinaryOperations have the same domain for each operand and the same codomain as both domains
-- If this is the case, BinaryOperations will have the following instance variables:
--      set - The singular set over which this BinaryOperation operates
--      pow - The exponentiation operation this binary operation uses
-- BinaryOperations have the following relations to other classes:
--      BinaryOperations implement Operations
BinaryOperation = {}
__BinaryOperation = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new binary operation with the given operation
function BinaryOperation:new(bo)
    local o = {}
    local mt = {__index = BinaryOperation, __call = BinaryOperation.eval}
    o = setmetatable(o, mt)

    o.operation = bo
    -- Default exponentiation operation by a positive integer - can be replaced with a more efficient operation
    o.pow = function(a, n)
        if(n > Integer(1)) then
            error("Unsupported domain for exponentiation")
        end
        local k = Integer(1)
        local b = a
        while k < n do
            b = o(b, a)
            k = k + Integer(1)
        end

    end

    return o
end

-- Returns the type of this object
function BinaryOperation:getType()
    return BinaryOperation
end

-- Returns whether the binary operation is associative
function BinaryOperation:isAssociative()
    return nil
end

-- Evaluates a binary operation with the given parameters
function BinaryOperation:eval(a, b)
    return self.operation(a, b)
end

-----------------
-- Inheritance --
-----------------

__BinaryOperation.__index = Operation
__BinaryOperation.__call = BinaryOperation.new
BinaryOperation = setmetatable(BinaryOperation, __BinaryOperation)