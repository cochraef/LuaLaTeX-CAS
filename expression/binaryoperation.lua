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
    local __o = Copy(__ExpressionOperations)

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

    if not o:isCommutative() and o.operation ~= BinaryOperation.SUB and (not o.expressions[1] or not o.expressions[2] or o.expressions[3]) then
        error("Sent parameter of wrong type: noncommutative operations cannot have an arbitrary number of paramaters")
    end

    __o.__index = BinaryOperation
    __o.__tostring = function(a)
        local expressionnames = '';
        for index, expression in ipairs(a.expressions) do
            if index == 1 and not a.expressions[index + 1] then
                expressionnames = expressionnames .. a.name .. ' '
            end
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
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b.operation then
            return false
        end
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
        if not results[index]:isevaluatable() then
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

-- Substitutes each variable for a new one.
function BinaryOperation:substitute(variables)
    local results = {}
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:substitute(variables)
    end
    return BinaryOperation(self.operation, results)
end

-- Performs automatic simplification of an binary operation
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
    if simplified.operation == BinaryOperation.DIV then
        return simplified:simplifyquotient()
    end
    if simplified.operation == BinaryOperation.SUB then
        return simplified:simplifydifference()
    end
    return simplified
end


function BinaryOperation:order(other)
    if other.isevaluatable() then
        return false
    end

    if other.isatomic() then
        if self.operation == BinaryOperation.POW then
            return self:order(BinaryOperation(BinaryOperation.POW, {other, Integer.one()}))
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
        return self:order(BinaryOperation(BinaryOperation.POW, {other, Integer.one()}))
    end

    if (self.operation == BinaryOperation.ADD) and (other.operation == BinaryOperation.MUL) then
        return BinaryOperation(BinaryOperation.MUL, {self}):order(other)
    end

    if (self.operation == BinaryOperation.ADD) and (other.operation == BinaryOperation.POW) then
        return BinaryOperation(BinaryOperation.POW, {self, Integer.one()}):order(other)
    end

    return true
end

-- Returns whether the binary operation is associative.
function BinaryOperation:isAssociative()
    error("Called unimplemented method: isAssociative()")
end

-- Returns whether the binary operation is commutative.
function BinaryOperation:isCommutative()
    error("Called unimplemented method: isCommutative()")
end

-- Returns an autosimplified expression as a single-variable polynomial in a ring, if it can be converted. Returns itself otherwise.
function BinaryOperation:topolynomial()
    local addexp = self
    if not self.operation or self.operation ~= BinaryOperation.ADD then
        addexp = BinaryOperation(BinaryOperation.ADD, {self})
    end

    local poly = {}
    local degree = 0
    local symbol
    for _, expression in ipairs(addexp.expressions) do
        local coefficient
        local sym
        local power
        -- Expressions of the form c
        if expression:isevaluatable() then
            coefficient = expression
            power = 0
        -- Expressions of the form x
        elseif expression:type() == SymbolExpression then
            coefficient = Integer.one()
            sym = expression.symbol
            power = 1
        -- Expressions of the form c*x
        elseif expression.operation and expression.operation == BinaryOperation.MUL and #expression.expressions == 2
                    and expression.expressions[1]:isevaluatable() and expression.expressions[2]:type() == SymbolExpression then

            coefficient = expression.expressions[1]
            sym = expression.expressions[2].symbol
            power = 1
        -- Expressions of the form c*x^n (totally not confusing)
        elseif expression.operation and expression.operation == BinaryOperation.MUL and #expression.expressions == 2
                    and expression.expressions[1]:isevaluatable() and expression.expressions[2].operation and
                    expression.expressions[2].operation == BinaryOperation.POW and #expression.expressions[2].expressions == 2
                    and expression.expressions[2].expressions[1]:type() == SymbolExpression and expression.expressions[2].expressions[2].getring
                    and expression.expressions[2].expressions[2]:getring() == Integer.getring() then

            coefficient = expression.expressions[1]
            sym = expression.expressions[2].expressions[1].symbol
            power = expression.expressions[2].expressions[2]:asnumber()
        -- Expressions of the form x^n
        elseif expression.operation and expression.operation == BinaryOperation.POW and #expression.expressions == 2
                    and expression.expressions[1]:type() == SymbolExpression and expression.expressions[2].getring
                    and expression.expressions[2]:getring() == Integer.getring() then

            coefficient = Integer.one()
            sym = expression.expressions[1].symbol
            power = expression.expressions[2]:asnumber()
        else
            return self, false
        end

        if symbol and sym and symbol ~= sym then
            return self, false
        end
        if not symbol then
            symbol = sym
        end
        poly[power + 1] = coefficient
        if power > degree then
            degree = power
        end
    end

    for i = 1,degree+1 do
        poly[i] = poly[i] or Integer.zero()
    end

    return PolynomialRing(poly, symbol), true
end

function BinaryOperation:tolatex()
    if self.operation == BinaryOperation.POW then
        if self.expressions[2]:isevaluatable() and self.expressions[2]:getring() == Rational:getring() and self.expressions[2].numerator == Integer.one() then
            if self.expressions[2].denominator == Integer(2) then
                return "\\sqrt{" .. self.expressions[1]:tolatex() .. '}'
            end
            return "\\sqrt[" .. self.expressions[2].denominator:tolatex() .. ']{' .. self.expressions[1]:tolatex() .. '}'
        end
        return self.expressions[1]:tolatex() .. '^{' .. self.expressions[2]:tolatex() .. '}'
    end
    if self.operation == BinaryOperation.MUL then
        local out = ''
        local denom = ''
        for _, expression in ipairs(self.expressions) do
            if expression:type() == BinaryOperation then
                if expression.operation == BinaryOperation.POW and expression.expressions[2]:isevaluatable() and expression.expressions[2] < Integer.zero() then
                    local reversed = (Integer.one() / expression):autosimplify()
                    denom = denom .. reversed:tolatex()
                elseif expression.operation == BinaryOperation.ADD or expression.operation == BinaryOperation.SUB then
                    out = out .. '(' .. expression:tolatex() .. ')'
                else
                    out = out .. expression:tolatex()
                end
            else
                if expression == Integer(-1) then
                    out = out .. '-'
                else
                    out = out .. expression:tolatex()
                end
            end
        end
        if out == '-' then
            out = '-1'
        end
        if denom ~= '' then
            return '\\frac{' .. out .. '}{' .. denom .. '}'
        end
        return out
    end
    if self.operation == BinaryOperation.ADD then
        local out = ''
        for index, expression in ipairs(self.expressions) do
            out = out .. expression:tolatex()
            if self.expressions[index + 1] then
                out = out .. '+'
            end
        end
        return out
    end
    if self.operation == BinaryOperation.DIV then
        return '\\frac{' .. self.expressions[1] .. '}{' .. self.expressions[2] .. '}'
    end
    if self.operation == BinaryOperation.SUB then
        local out = ''
        for index, expression in ipairs(self.expressions) do
            out = out .. expression:tolatex()
            if self.expressions[index + 1] then
                out = out .. '-'
            end
        end
        return out
    end
    return self
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

BinaryOperation.ADDEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.ADD, expressions, name)
end

BinaryOperation.SUBEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.SUB, expressions, name)
end

BinaryOperation.MULEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.MUL, expressions, name)
end

BinaryOperation.DIVEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.DIV, expressions, name)
end

BinaryOperation.IDIVEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.IDIV, expressions, name)
end

BinaryOperation.MODEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.MOD, expressions, name)
end

BinaryOperation.POWEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.POW, expressions, name)
end