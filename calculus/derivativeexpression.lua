--- @class DerivativeExpression
--- An expression for a single-variable derivative of an expression.
--- @field symbol SymbolExpression
--- @field expression Expression
DerivativeExpression = {}
__DerivativeExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new derivative operation with the given symbol and expression.
--- @param expression Expression
--- @param symbol Symbol
--- @return DerivativeExpression
function DerivativeExpression:new(expression, symbol)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    symbol = symbol or SymbolExpression("x")

    o.symbol = symbol
    o.expression = Copy(expression)

    __o.__index = DerivativeExpression
    __o.__tostring = function(a)
        return '(d/d' .. tostring(a.symbol) .. " " .. tostring(a.expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == DerivativeExpression then
            return false
        end
        return a.symbol == b.symbol and a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

--- @return Expression
function DerivativeExpression:autosimplify()
    local simplified = self.expression:autosimplify()

    -- The derivative of a constant is 0
    if simplified:isconstant() then
        return Integer.zero()
    end

    -- The derivative of a symbol is either 1 or 0
    if simplified:type() == SymbolExpression then
        if self.symbol == simplified then
            return Integer.one()
        end
        return Integer.zero()
    end

    -- Chain rule for arbitrary functions
    if simplified:type() == FunctionExpression then
        if simplified.expressions[2] then
            return self
        end
        return (DerivativeExpression(simplified.expressions[1], self.symbol) * FunctionExpression(simplified.name .. "'", simplified.expressions)):autosimplify()
    end

    -- Chain rule for trig functions
    if simplified:type() == TrigExpression then
        local internal = DerivativeExpression(simplified.expression, self.symbol)

        if simplified.name == "sin" then
            return (internal * COS(simplified.expression)):autosimplify()
        end
        if simplified.name == "cos" then
            return (internal * -SIN(simplified.expression)):autosimplify()
        end
        if simplified.name == "tan" then
            return (internal * SEC(simplified.expression)^Integer(2)):autosimplify()
        end
        if simplified.name == "csc" then
            return (internal * -CSC(simplified.expression)*COT(simplified.expression)):autosimplify()
        end
        if simplified.name == "sec" then
            return (internal * -SEC(simplified.expression)*TAN(simplified.expression)):autosimplify()
        end
        if simplified.name == "cot" then
            return (internal * -CSC(simplified.expression)^Integer(2)):autosimplify()
        end
        if simplified.name == "arcsin" then
            return (internal / (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2))):autosimplify()
        end
        if simplified.name == "arccos" then
            return (-internal / (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2))):autosimplify()
        end
        if simplified.name == "arctan" then
            return (internal / (Integer(1)+simplified.expression^Integer(2))):autosimplify()
        end
        if simplified.name == "arccsc" then
            return (-internal / (ABS(simplified.expression) * (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2)))):autosimplify()
        end
        if simplified.name == "arcsec" then
            return (internal / (ABS(simplified.expression) * (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2)))):autosimplify()
        end
        if simplified.name == "arccot" then
            return (-internal / (Integer(1)+simplified.expression^Integer(2))):autosimplify()
        end
    end

    -- TODO: Piecewise functions
    if self:type() == AbsExpression then
        return DerivativeExpression(self.expression, self.symbol):autosimplify()
    end

    -- Uses linearity of derivatives to evaluate sum expressions
    if simplified.operation == BinaryOperation.ADD then
        local parts = {}
        for i, expression in pairs(simplified.expressions) do
            parts[i] = DerivativeExpression(expression, self.symbol)
        end
        return BinaryOperation(BinaryOperation.ADD, parts):autosimplify()
    end

    -- Uses product rule to evaluate product expressions
    if simplified.operation == BinaryOperation.MUL then
        local sums = {}
        for i, expression in pairs(simplified.expressions) do
            local products = {}
            for j, innerexpression in pairs(simplified.expressions) do
                if i ~= j then
                    products[j] = innerexpression
                else
                    products[j] = DerivativeExpression(innerexpression, self.symbol)
                end
            end
            sums[i] = BinaryOperation(BinaryOperation.MUL, products)
        end
        return BinaryOperation(BinaryOperation.ADD, sums):autosimplify()
    end

    -- Uses the generalized power rule to evaluate power expressions
    if simplified.operation == BinaryOperation.POW then
        local base = simplified.expressions[1]
        local exponent = simplified.expressions[2]

        return BinaryOperation.MULEXP({
                    BinaryOperation.POWEXP({base, exponent}),
                    BinaryOperation.ADDEXP({
                        BinaryOperation.MULEXP({
                            DD(base, self.symbol),
                            BinaryOperation.DIVEXP({exponent, base})}),
                        BinaryOperation.MULEXP({
                            DD(exponent, self.symbol),
                            LN(base)})})
                    }):autosimplify()
    end

    if simplified:type() == Logarithm then
        local base = simplified.base
        local expression = simplified.expression

        return BinaryOperation.SUBEXP({
                    BinaryOperation.DIVEXP({DD(expression, self.symbol),
                        BinaryOperation.MULEXP({expression, LN(base)})}),

                    BinaryOperation.DIVEXP({
                        BinaryOperation.MULEXP({LN(expression), DD(base, self.symbol)}),
                        BinaryOperation.MULEXP({BinaryOperation.POWEXP({LN(base), Integer(2)}), base})
                    })

                }):autosimplify()
    end

    return self
end

--- @return table<number, Expression>
function DerivativeExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return DerivativeExpression
function DerivativeExpression:setsubexpressions(subexpressions)
    return DerivativeExpression(subexpressions[1], self.symbol)
end

-- function DerivativeExpression:freeof(symbol)
--     return self.symbol.freeof(symbol) and self.expression:freeof(symbol)
-- end

-- Substitutes each expression for a new one.
-- function DerivativeExpression:substitute(map)
--     for expression, replacement in pairs(map) do
--         if self == expression then
--             return replacement
--         end
--     end
--     -- Typically, we only perform substitution on autosimplified expressions, so this won't get called. May give strange results, i.e.,
--     -- substituting and then evaluating the derivative may not return the same thing as evaluating the derivative and then substituting.
--     return DerivativeExpression(self.expression:substitute(map), self.symbol)
-- end

--- @param other Expression
--- @return boolean
function DerivativeExpression:order(other)
    if other:type() == IntegralExpression then
        return true
    end

    if other:type() ~= DerivativeExpression then
        return false
    end

    if self.symbol ~= other.symbol then
        return self.symbol:order(other.symbol)
    end

    return self.expression:order(other.expression)
end

--- @return string
function DerivativeExpression:tolatex()
    return '\\frac{d}{d' .. self.symbol:tolatex() .. '}(' .. self.expression:tolatex() .. ')'
end

-----------------
-- Inheritance --
-----------------
__DerivativeExpression.__index = CompoundExpression
__DerivativeExpression.__call = DerivativeExpression.new
DerivativeExpression = setmetatable(DerivativeExpression, __DerivativeExpression)

----------------------
-- Static constants --
----------------------
DD = function(expression, symbol)
    return DerivativeExpression(expression, symbol)
end