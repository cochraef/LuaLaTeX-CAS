--- @class BinaryOperation
--- Represents a binary operation with two inputs and one output.
--- Represents a generic function that takes zero or more expressions as inputs.
--- @field name string
--- @field operation function
--- @field expressions table<number, Expression>
BinaryOperation = {}
__BinaryOperation = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new binary operation with the given operation.
--- @param operation function
--- @param expressions table<number, Expression>
--- @return BinaryOperation
function BinaryOperation:new(operation, expressions)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    if type(operation) ~= "function" then
        error("Sent parameter of wrong type: operation must be a function")
    end

    if type(expressions) ~= "table" then
        error("Sent parameter of wrong type: expressions must be an array")
    end

    o.name = BinaryOperation.DEFAULT_NAMES[operation]
    o.operation = operation
    o.expressions = Copy(expressions)

    if BinaryOperation.COMMUTATIVITY[operation] then
        function o:iscommutative()
            return true
        end
    else
        function o:iscommutative()
            return false
        end
    end

    if not o:iscommutative() and o.operation ~= BinaryOperation.SUB and #o.expressions ~= 2 then
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
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not a.operation or not b.operation then
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

--- @return Expression
function BinaryOperation:evaluate()
    local results = {}
    local reducible = true
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:evaluate()
        if not results[index]:isconstant() then
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

--- @return Expression
function BinaryOperation:autosimplify()
    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
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

--- @return table<number, Expression>
function BinaryOperation:subexpressions()
    return self.expressions
end

--- @param subexpressions table<number, Expression>
--- @return BinaryOperation
function BinaryOperation:setsubexpressions(subexpressions)
    return BinaryOperation(self.operation, subexpressions)
end

--- @return Expression
function BinaryOperation:expand()
    local results = {}
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:expand()
    end
    local expanded = BinaryOperation(self.operation, results)
    if expanded.operation == BinaryOperation.MUL then
        local allsums = BinaryOperation(BinaryOperation.ADD, {Integer.one()});
        for _, expression in ipairs(expanded.expressions) do
            allsums = allsums:expand2(expression)
        end
        return allsums:autosimplify()
    end
    if expanded.operation == BinaryOperation.POW and expanded.expressions[2]:type() == Integer then
        local exp = BinaryOperation.MULEXP({Integer(1)});
        local pow = expanded.expressions[2]:asnumber()
        for _ = 1, pow do
            exp = exp * expanded.expressions[1]
        end
        return exp:expand()
    end
    return expanded:autosimplify()
end

--- Helper for expand - multiplies two addition expressions.
--- @return Expression
function BinaryOperation:expand2(other)
    local result = {}
    for _, expression in ipairs(self.expressions) do
        if other:type() == BinaryOperation and other.operation == BinaryOperation.ADD then
            for _, expression2 in ipairs(other.expressions) do
                result[#result+1] = expression * expression2
            end
        else
            result[#result+1] = expression * other
        end
    end
    return BinaryOperation(BinaryOperation.ADD, result)
end

--- TODO: General expression factoring.
--- @return Expression
function BinaryOperation:factor()
    return self
end

--- @param other Expression
--- @return boolean
function BinaryOperation:order(other)
    if other:isconstant() then
        return false
    end

    if other:isatomic() then
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

    if other:type() == FunctionExpression or other:type() == TrigExpression then
        if self.operation == BinaryOperation.ADD or self.operation == BinaryOperation.MUL then
            return self:order(BinaryOperation(self.operation, {other}))
        end

        if self.operation == BinaryOperation.POW then
            return self:order(other^Integer.one())
        end
    end

    return true
end

--- Returns whether the binary operation is commutative.
--- @return boolean
function BinaryOperation:iscommutative()
    error("Called unimplemented method: iscommutative()")
end

--- Returns an autosimplified expression as a single-variable polynomial in a ring, if it can be converted. Returns itself otherwise.
--- @return PolynomialRing, boolean
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
        if expression:isconstant() then
            coefficient = expression
            power = 0
        -- Expressions of the form x
        elseif expression:type() == SymbolExpression then
            coefficient = Integer.one()
            sym = expression.symbol
            power = 1
        -- Expressions of the form c*x
        elseif expression.operation and expression.operation == BinaryOperation.MUL and #expression.expressions == 2
                    and expression.expressions[1]:isconstant() and expression.expressions[2]:type() == SymbolExpression then

            coefficient = expression.expressions[1]
            sym = expression.expressions[2].symbol
            power = 1
        -- Expressions of the form c*x^n (totally not confusing)
        elseif expression.operation and expression.operation == BinaryOperation.MUL and #expression.expressions == 2
                    and expression.expressions[1]:isconstant() and expression.expressions[2].operation and
                    expression.expressions[2].operation == BinaryOperation.POW and #expression.expressions[2].expressions == 2
                    and expression.expressions[2].expressions[1]:type() == SymbolExpression and expression.expressions[2].expressions[2].getring
                    and expression.expressions[2].expressions[2]:getring() == Integer.getring() and expression.expressions[2].expressions[2] > Integer.zero() then

            coefficient = expression.expressions[1]
            sym = expression.expressions[2].expressions[1].symbol
            power = expression.expressions[2].expressions[2]:asnumber()
        -- Expressions of the form x^n
        elseif expression.operation and expression.operation == BinaryOperation.POW and #expression.expressions == 2
                    and expression.expressions[1]:type() == SymbolExpression and expression.expressions[2].getring
                    and expression.expressions[2]:getring() == Integer.getring() and expression.expressions[2] > Integer.zero() then

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
        if self.expressions[1]:isatomic() then
            if self.expressions[2]:isconstant() and self.expressions[2]:getring() == Rational:getring() and self.expressions[2].numerator == Integer.one() then
                if self.expressions[2].denominator == Integer(2) then
                    return "\\sqrt{" .. self.expressions[1]:tolatex() .. '}'
                end
                return "\\sqrt[" .. self.expressions[2].denominator:tolatex() .. ']{' .. self.expressions[1]:tolatex() .. '}'
            end
            return self.expressions[1]:tolatex() .. '^{' .. self.expressions[2]:tolatex() .. '}'
        else
            if self.expressions[2]:isconstant() and self.expressions[2]:getring() == Rational:getring() and self.expressions[2].numerator == Integer.one() then
                if self.expressions[2].denominator == Integer(2) then
                    return "\\sqrt{\\left(" .. self.expressions[1]:tolatex() .. '\\right)}'
                end
                return "\\sqrt[" .. self.expressions[2].denominator:tolatex() .. ']{\\left(' .. self.expressions[1]:tolatex() .. '\\right)}'
            end
            return "\\left(" .. self.expressions[1]:tolatex() .. "\\right)" .. '^{' .. self.expressions[2]:tolatex() .. '}'
        end
    end
    if self.operation == BinaryOperation.MUL then
        local out = ''
        local denom = ''
        for _, expression in ipairs(self.expressions) do
            if expression:type() == BinaryOperation then
                if expression.operation == BinaryOperation.POW and expression.expressions[2]:isconstant() and expression.expressions[2] < Integer.zero() then
                    local reversed = (Integer.one() / expression):autosimplify()
                    denom = denom .. '\\left('.. reversed:tolatex() .. '\\right)'
                elseif expression.operation == BinaryOperation.ADD or expression.operation == BinaryOperation.SUB then
                    out = out .. '\\left(' .. expression:tolatex() .. '\\right)'
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
        if denom ~= '' and out == '' then 
            return '\\frac{' .. '1' .. '}{' .. denom .. '}'
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
            if self.expressions[index + 1] and string.sub(self.expressions[index + 1]:tolatex(), 1, 1) ~= "-" then
                out = out .. '+'
            end
        end
        return out
    end
    if self.operation == BinaryOperation.DIV then
        return '\\frac{' .. self.expressions[1]:tolatex() .. '}{' .. self.expressions[2]:tolatex() .. '}'
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
    [BinaryOperation.POW] = "^"
}

BinaryOperation.COMMUTATIVITY = {
    [BinaryOperation.ADD] = true,
    [BinaryOperation.SUB] = false,
    [BinaryOperation.MUL] = true,
    [BinaryOperation.DIV] = false,
    [BinaryOperation.IDIV] = false,
    [BinaryOperation.MOD] = false,
    [BinaryOperation.POW] = false
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