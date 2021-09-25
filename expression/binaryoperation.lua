-- Represents a binary operation with two inputs and one output
-- However, the expressions instance variable can store any number of operations greater than zero
-- BinaryOperations have the following relations to other classes:
--      BinaryOperations extend CompoundExpressions
BinaryOperation = {}
__BinaryOperation = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new binary operation with the given operation
function BinaryOperation:new(operation, expressions, name)
    local o = CompoundExpression:new(operation, expressions, name)
    local __o = {}

    o.name = BinaryOperation.DEFAULT_NAMES[operation]

    __o.__index = BinaryOperation
    __o.__tostring = function(a)
        local expressionnames = '';
        for index, expression in ipairs(a.expressions) do
            if index > 1 then
                expressionnames = expressionnames .. ' '
            end
            expressionnames = expressionnames .. tostring(expression)
            if a.expressions[index + 1] then
                expressionnames = expressionnames .. ' ' .. a.name
            end
        end
        return '(' .. expressionnames .. ')'
    end
    o = setmetatable(o, __o)

    return o
end

-- Evaluates each sub-expression and returns the evaluation of this expression
function BinaryOperation:evaluate()
    local results = {}
    local reducible = true
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:evaluate()
        if not results[index]:isEvaluatable() then
            reducible = false
        end
    end
    if not reducible then
        return BinaryOperation(self.operation, results)
    end

    if not self.expressions[1] then
        error("Execution error: cannot perform binary operation on zero expressions")
    end

    local result = results[1]
    for index, expression in ipairs(results) do
        if not (index == 1) then
            result = self.operation(result, expression)
        end
    end
    return result
end

-- Substitutes each variable for a new one
function BinaryOperation:substitute(variables)
    local results = {}
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:substitute(variables)
    end
    return BinaryOperation(self.operation, results)
end

-- Returns whether the binary operation is associative
function BinaryOperation:isAssociative()
    error("Called unimplemented method: isAssociative()")
end

-- Returns whether the binary operation is commutative
function BinaryOperation:isCommutative()
    error("Called unimplemented method: isCommutative()")
end

-----------------
-- Inheritance --
-----------------

__BinaryOperation.__index = CompoundExpression
__BinaryOperation.__call = BinaryOperation.new
BinaryOperation = setmetatable(BinaryOperation, __BinaryOperation)

----------------------
-- Static constants --
----------------------

BinaryOperation.ADD = function(a, b)
    return a + b
end

BinaryOperation.SUB = function(a, b)
    return a - b
end

BinaryOperation.MUL = function(a, b)
    return a * b
end

BinaryOperation.DIV = function(a, b)
    return a / b
end

BinaryOperation.IDIV = function(a, b)
    return a // b
end

BinaryOperation.MOD = function(a, b)
    return a % b
end

BinaryOperation.POW = function(a, b)
    return a ^ b
end

BinaryOperation.DEFAULT_NAMES = {
    [BinaryOperation.ADD] = "+",
    [BinaryOperation.SUB] = "-",
    [BinaryOperation.MUL] = "*",
    [BinaryOperation.DIV] = "/",
    [BinaryOperation.IDIV] = "//",
    [BinaryOperation.MOD] = "%",
    [BinaryOperation.POW] = "^",
}