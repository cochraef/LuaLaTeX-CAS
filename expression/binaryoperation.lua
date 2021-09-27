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

    if o.operation == BinaryOperation.ADD or o.operation == BinaryOperation.MUL then
        function o:isCommutative()
            return true
        end
    else
        function o:isCommutative()
            return false
        end
    end

    if not o:isCommutative() and (not o.expressions[1] or not o.expressions[2] or o.expressions[3]) then
        error("Sent parameter of wrong type: noncommutative operations cannot have an arbitrary number of paramaters")
    end

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
    __o.__eq = function(a, b)
        local loc = 1
        while a.expressions[loc] or b.expressions[loc] do
            if not a.expressions[loc] or not b.expressions[loc] or
                (a.expressions[loc] ~= b.expressions[loc]) then
                return false
            end
            loc = loc + 1
        end
        return a.operation == b.operation
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

-- Performs automatic simplification of an expression, including evaluation
function BinaryOperation:autosimplify()
    local results = {}
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:autosimplify()
    end
    local simplified = BinaryOperation(self.operation, results)
    if simplified.operation == BinaryOperation.POW then
        return simplified:simplifypower()
    end
    if simplified.operation == BinaryOperation.MUL then
        return simplified:simplifyproduct()
    end

    return simplified
end

-- Automatic simplification of power expressions
function BinaryOperation:simplifypower()
    local base = self.expressions[1]
    local exponent = self.expressions[2]

    if base:isEvaluatable() and exponent:isEvaluatable() then
        return self:evaluate()
    end

    -- Uses the property that 0^x = 0 if x does not equal 0
    -- This is not being simplified right now, since we need to figure out what to do if there is a variable in the exponent
    -- if base:isEvaluatable() and base == base:zero() then
    --     return Integer(0)
    -- end

    -- Uses the property that 1^x = 1
    if base:isEvaluatable() and base == base:one() then
        return base:one()
    end

    -- Uses the property that x^0 = 1
    if exponent:isEvaluatable() and exponent == exponent:zero() then
        return exponent:one()
    end

    -- Uses the property that x^1 = x
    if exponent:isEvaluatable() and exponent == exponent:one() then
        return base
    end

    -- Uses the property that (x^a)^b = x^(a*b)
    if not base:isAtomic() and base.operation == BinaryOperation.POW then
        base, exponent = base.expressions[1], BinaryOperation(BinaryOperation.MUL, {exponent, base.expressions[2]}):autosimplify()
        return BinaryOperation(BinaryOperation.POW, {base, exponent})
    end

    -- Uses the property that (x_1*x_2*...*x_n)^a = x_1^a*x_2^a*..x_n^a
    if base.operation == BinaryOperation.MUL then
        local results = {}
        for index, expression in ipairs(base.expressions) do
            results[index] = BinaryOperation(BinaryOperation.POW, {expression, exponent}):autosimplify()
        end
        return BinaryOperation(BinaryOperation.MUL, results):autosimplify()
    end

    -- Our expression cannot be simplified
    return self
end

-- Automatic simplification of multiplication expressions
function BinaryOperation:simplifyproduct()
    local results = {}
    local reducible = true
    for index, expression in ipairs(self.expressions) do
        if not expression:isEvaluatable() then
            reducible = false
        end
        results[index] = expression:evaluate()
    end

    if reducible then
        local result = results[1]
        for index, expression in ipairs(results) do
            if not (index == 1) then
                result = self.operation(result, expression)
            end
        end
        return result
    end

    local evaluated = BinaryOperation(self.operation, results)

    -- Uses the property that x*0=0
    for index, expression in ipairs(evaluated.expressions) do
        if expression:isEvaluatable() and expression == expression:zero() then
            return expression:zero()
        end
    end

    -- We don't really know what ring we are working in here, so just assume the integer ring
    if not evaluated.expressions[1] then
        return Integer(1)
    end

    -- Simplifies single products to their operands
    if evaluated.expressions[1] and not evaluated.expressions[2] then
        return evaluated.expressions[1]
    end

    local term1 = evaluated.expressions[1]
    local term2 = evaluated.expressions[2]

    if evaluated.expressions[1] and evaluated.expressions[2] and not evaluated.expressions[3] then

        if (term1:isEvaluatable() or not (term1.operation == BinaryOperation.MUL)) and
            (term2:isEvaluatable() or not (term2.operation == BinaryOperation.MUL)) then
            -- Uses the property that x*1 = x
            if term1:isEvaluatable() and term1 == term1:one() then
                return term2
            end

            if term2:isEvaluatable() and term2 == term2:one() then
                return term1
            end

            -- Uses the property that x^a*x^b=x^(a+b)
            if (term1.operation == BinaryOperation.POW) and (term2.operation == BinaryOperation.POW) and term1.expressions[1] == term2.expressions[2] then
                return BinaryOperation(BinaryOperation.POW,
                                    {term1.expressions[1],
                                    BinaryOperation(BinaryOperation.ADD,
                                        {term1.expressions[2], term2.expressions[2]})}):autosimplify()
            end

            return evaluated
        end

        if term1.operation == BinaryOperation.MUL and not (term2.operation == BinaryOperation.MUL) then
            return term1:mergeproducts(BinaryOperation(BinaryOperation.MUL, {term2}))
        end

        if not (term1.operation == BinaryOperation.MUL) and term2.operation == BinaryOperation.MUL then
            return BinaryOperation(BinaryOperation.MUL, {term1}):mergeproducts(term2)
        end

        return term1:mergeproducts(term2)
    end

    local rest = {}
    for index, expression in ipairs(evaluated.expressions) do
        if index > 1 then
            rest[index - 1] = expression
        end
    end

    local result = BinaryOperation(BinaryOperation.MUL, rest):autosimplify()

    if term1.operation == BinaryOperation.MUL then
        return term1:mergeproducts(result)
    else
        return BinaryOperation(BinaryOperation.MUL, {term1}):mergeproducts()
    end
end

-- Merges two lists of products
function BinaryOperation:mergeproducts(other)
    local first = BinaryOperation(BinaryOperation.MUL, {self.expressions[1], self.expressions[2]}):autosimplify()

    if not self.expressions[1] then
        return other
    end

    if not other.expressions[1] then
        return self
    end

    local selfrest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            selfrest[index - 1] = expression
        end
    end

    local otherrest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            otherrest[index - 1] = expression
        end
    end

    if first.isEvaluatable() and first == first.one() then
        return BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
    end

    if first.isEvaluatable() or not first.expressions[2] then
        local result = BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
        if first.isEvaluatable() then
            table.insert(result.expressions, first)
        else
            table.insert(result.expressions, first.expressions[1])
        end
        return result
    end

    local result = BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
    table.insert(result.expressions, first.expressions[1])
    table.insert(result.expressions, first.expressions[2])
    return result

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

-- Ring Operations

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