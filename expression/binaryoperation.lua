-- Represents a binary operation with two inputs and one output
-- BinaryOperations have the following instance variables:
--      name - the string name of the function
--      operation - the operation to apply to the list of operands
--      expressions - a list of subexpressions associated with this expression
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
    local o = {}
    local __o = {}

    if type(name) ~= "string" and type(name) ~= "nil" then
        error("Sent parameter of wrong type: name must be a string")
    end

    if type(operation) ~= "function" then
        error("Sent parameter of wrong type: operation must be a function")
    end

    if type(expressions) ~= "table" then
        error("Sent parameter of wrong type: expressions must be an array")
    end

    o.name = BinaryOperation.DEFAULT_NAMES[operation]
    o.operation = operation
    o.expressions = Copy(expressions)

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
    if simplified.operation == BinaryOperation.ADD then
        return simplified:simplifysum()
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
    if base:isEvaluatable() and base == base:zero() then
        return Integer(0)
    end

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
            if term1.operation ~= BinaryOperation.POW then
                term1 = BinaryOperation(BinaryOperation.POW, {term1, Integer(1)})
            end
            if term2.operation ~= BinaryOperation.POW then
                term2 = BinaryOperation(BinaryOperation.POW, {term2, Integer(1)})
            end
            if term1.expressions[1] == term2.expressions[1] then
                return BinaryOperation(BinaryOperation.POW,
                                    {term1.expressions[1],
                                    BinaryOperation(BinaryOperation.ADD,
                                        {term1.expressions[2], term2.expressions[2]}):autosimplify()}):autosimplify()
            end

            term1 = term1.expressions[1]
            term2 = term2.expressions[1]

            if term2:order(term1) then
                return BinaryOperation(BinaryOperation.MUL, {term2, term1})
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

    if term1.operation ~= BinaryOperation.MUL then
        term1 = BinaryOperation(BinaryOperation.MUL, {term1})
    end
    if result.operation ~= BinaryOperation.MUL then
        result = BinaryOperation(BinaryOperation.MUL, {result})
    end
    return term1:mergeproducts(result)
end

-- Merges two lists of products
function BinaryOperation:mergeproducts(other)
    if not self.expressions[1] then
        return other
    end

    if not other.expressions[1] then
        return self
    end

    local first = BinaryOperation(BinaryOperation.MUL, {self.expressions[1], other.expressions[1]}):autosimplify()

    local selfrest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            selfrest[index - 1] = expression
        end
    end

    local otherrest = {}
    for index, expression in ipairs(other.expressions) do
        if index > 1 then
            otherrest[index - 1] = expression
        end
    end

    if first.isEvaluatable() and first == first.one() then
        return BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
    end

    if first.operation ~= BinaryOperation.MUL or not first.expressions[2] then
        local result = BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
        if first.operation ~= BinaryOperation.MUL then
            table.insert(result.expressions, 1, first)
        else
            table.insert(result.expressions, 1, first.expressions[1])
        end
        if result.expressions[1] and not result.expressions[2] then
            return result.expressions[1]
        end
        return result
    end

    local result
    if first.expressions[1] == self.expressions[1] then
        result = BinaryOperation(self.operation, selfrest):mergeproducts(other)
    else
        result = self:mergeproducts(BinaryOperation(other.operation, otherrest))
    end

    table.insert(result.expressions, 1, first.expressions[1])

    if result.expressions[1] and not result.expressions[2] then
        return result.expressions[1]
    end
    return result
end

-- Automatic simplification of addition expressions
function BinaryOperation:simplifysum()
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

    -- We don't really know what ring we are working in here, so just assume the integer ring
    if not evaluated.expressions[1] then
        return Integer(0)
    end

    -- Simplifies single sums to their operands
    if evaluated.expressions[1] and not evaluated.expressions[2] then
        return evaluated.expressions[1]
    end

    local term1 = evaluated.expressions[1]
    local term2 = evaluated.expressions[2]

    if evaluated.expressions[1] and evaluated.expressions[2] and not evaluated.expressions[3] then

        if (term1:isEvaluatable() or not (term1.operation == BinaryOperation.ADD)) and
            (term2:isEvaluatable() or not (term2.operation == BinaryOperation.ADD)) then

            -- Uses the property that x + 0 = x
            if term1:isEvaluatable() and term1 == term1:zero() then
                return term2
            end

            if term2:isEvaluatable() and term2 == term2:zero() then
                return term1
            end

            -- Uses the property that a*x+b*x= (a+b)*x
            -- This is only done if a and b are constant, since otherwise this could be counterproductive
            -- We SHOULD be okay to only check left distributivity, since constants always come first when ordered
            if term1.operation ~= BinaryOperation.MUL or not term1.expressions[1].isEvaluatable() then
                term1 = BinaryOperation(BinaryOperation.MUL, {Integer(1), term1})
            end
            if term2.operation ~= BinaryOperation.MUL or not term2.expressions[1].isEvaluatable() then
                term2 = BinaryOperation(BinaryOperation.MUL, {Integer(1), term2})
            end
            if term1.expressions[2] == term2.expressions[2] and term1.expressions[1].isEvaluatable() and term2.expressions[1].isEvaluatable() then
                return BinaryOperation(BinaryOperation.MUL,
                                    {BinaryOperation(BinaryOperation.ADD,
                                        {term1.expressions[1],
                                        term2.expressions[1]}):autosimplify(),
                                    term1.expressions[2]}):autosimplify()
            end

            term1 = term1.expressions[1]
            term2 = term2.expressions[1]

            if term2:order(term1) then
                return BinaryOperation(BinaryOperation.ADD, {term2, term1})
            end

            return evaluated
        end

        if term1.operation == BinaryOperation.ADD and not (term2.operation == BinaryOperation.ADD) then
            return term1:mergesums(BinaryOperation(BinaryOperation.ADD, {term2}))
        end

        if not (term1.operation == BinaryOperation.ADD) and term2.operation == BinaryOperation.ADD then
            return BinaryOperation(BinaryOperation.ADD, {term1}):mergesums(term2)
        end

        return term1:mergesums(term2)
    end

    local rest = {}
    for index, expression in ipairs(evaluated.expressions) do
        if index > 1 then
            rest[index - 1] = expression
        end
    end

    local result = BinaryOperation(BinaryOperation.ADD, rest):autosimplify()

    if term1.operation ~= BinaryOperation.ADD then
        term1 = BinaryOperation(BinaryOperation.ADD, {term1})
    end
    if result.operation ~= BinaryOperation.ADD then
        result = BinaryOperation(BinaryOperation.ADD, {result})
    end
    return term1:mergesums(result)
end

-- Merges two lists of sums
function BinaryOperation:mergesums(other)
    if not self.expressions[1] then
        return other
    end

    if not other.expressions[1] then
        return self
    end

    local first = BinaryOperation(BinaryOperation.ADD, {self.expressions[1], other.expressions[1]}):autosimplify()

    local selfrest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            selfrest[index - 1] = expression
        end
    end

    local otherrest = {}
    for index, expression in ipairs(other.expressions) do
        if index > 1 then
            otherrest[index - 1] = expression
        end
    end

    if first.isEvaluatable() and first == first.one() then
        return BinaryOperation(self.operation, selfrest):mergesums(BinaryOperation(other.operation, otherrest))
    end

    if first.operation ~= BinaryOperation.ADD or not first.expressions[2] then
        local result = BinaryOperation(self.operation, selfrest):mergesums(BinaryOperation(other.operation, otherrest))
        if first.operation ~= BinaryOperation.ADD then
            table.insert(result.expressions, 1, first)
        else
            table.insert(result.expressions, 1, first.expressions[1])
        end
        if result.expressions[1] and not result.expressions[2] then
            return result.expressions[1]
        end
        return result
    end

    local result
    if first.expressions[1] == self.expressions[1] then
        result = BinaryOperation(self.operation, selfrest):mergesums(other)
    else
        result = self:mergesums(BinaryOperation(other.operation, otherrest))
    end

    table.insert(result.expressions, 1, first.expressions[1])

    if result.expressions[1] and not result.expressions[2] then
        return result.expressions[1]
    end
    return result
end


function BinaryOperation:order(other)
    if other.isEvaluatable() then
        return false
    end

    if other.isAtomic() then
        if self.operation == BinaryOperation.POW then
            return self:order(BinaryOperation(BinaryOperation.POW, {other, Integer(1)}))
        end

        if self.operation == BinaryOperation.MUL then
            return self:order(BinaryOperation(BinaryOperation.MUL, {other}))
        end

        if self.operation == BinaryOperation.ADD then
            return self:order(BinaryOperation(BinaryOperation.ADD, {other}))
        end
    end

    if self.operation == BinaryOperation.POW and other.operation == BinaryOperation.POW then
        if self.expressions[1] ~= other.expressions[1] then
            return self.expressions[1]:order(other.expressions[1])
        end
        return self.expressions[2]:order(other.expressions[2])
    end

    if (self.operation == BinaryOperation.MUL and other.operation == BinaryOperation.MUL) or
    (self.operation == BinaryOperation.ADD and other.operation == BinaryOperation.ADD) then
        local k = 0
        while #self.expressions - k > 0 and #other.expressions - k > 0 do
            if self.expressions[#self.expressions - k] ~= other.expressions[#other.expressions - k] then
                return self.expressions[#self.expressions - k]:order(other.expressions[#other.expressions - k])
            end
            k = k + 1
        end
        return #self.expressions < #other.expressions
    end

    if (self.operation == BinaryOperation.MUL) and (other.operation == BinaryOperation.POW or other.operation == BinaryOperation.ADD) then
        return self:order(BinaryOperation(BinaryOperation.MUL, {other}))
    end

    if (self.operation == BinaryOperation.POW) and (other.operation == BinaryOperation.MUL) then
        return BinaryOperation(BinaryOperation.MUL, {self}):order(other)
    end

    if (self.operation == BinaryOperation.POW) and (other.operation == BinaryOperation.ADD) then
        return self:order(BinaryOperation(BinaryOperation.POW, {other, Integer(1)}))
    end

    if (self.operation == BinaryOperation.ADD) and (other.operation == BinaryOperation.MUL) then
        return BinaryOperation(BinaryOperation.MUL, {self}):order(other)
    end

    if (self.operation == BinaryOperation.ADD) and (other.operation == BinaryOperation.POW) then
        return BinaryOperation(BinaryOperation.POW, {self, Integer(1)}):order(other)
    end

    return true
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