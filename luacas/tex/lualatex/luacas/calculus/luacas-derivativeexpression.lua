--- @class DerivativeExpression
--- An expression for a single-variable derivative of an expression.
--- @field symbol SymbolExpression
--- @field expression Expression
DerivativeExpression = {}
local __DerivativeExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new single-variable derivative operation with the given symbol and expression.
--- @param expression Expression
--- @param symbol Symbol
--- @return DerivativeExpression
function DerivativeExpression:new(expression, symbol)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.expression = Copy(expression)
    o.symbol = symbol or SymbolExpression("x")

    __o.__index = DerivativeExpression
    __o.__tostring = function(a)
        return '(d/d' .. tostring(a.symbol) .. " " .. tostring(a.expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not b:type() == DerivativeExpression then
            return false
        end
        return a.symbol == b.symbol and a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

--- @return Expression
function DerivativeExpression:evaluate()
    local exp = self.expression

    -- The derivative of a constant is 0
    if exp:isconstant() then
        return Integer.zero()
    end

    -- The derivative of a symbol is either 1 or 0
    if exp:type() == SymbolExpression then
        if self.symbol == exp then
            return Integer.one()
        end
        return Integer.zero()
    end

    -- Chain rule for arbitrary functions

    if exp:type() == FunctionExpression then
        local results = {}
        for index,expression in ipairs(exp.expressions) do
            local dout = FunctionExpression(exp.name,exp.expressions,exp.derivatives)
            dout.variables = exp.variables
            dout.derivatives[index] = dout.derivatives[index]+Integer.one()
            local dinn = DerivativeExpression(expression,self.symbol):evaluate()
            results[index] = dout*dinn
        end
        return BinaryOperation(BinaryOperation.ADD,results):autosimplify()
    end

    --if exp:type() == FunctionExpression then
    --    local results = {}
    --    for index,expression in ipairs(exp.expressions) do
    --        local inn = DerivativeExpression(expression,self.symbol):autosimplify()
    --        local out = Copy(exp)
    --        out.orders[index] = out.orders[index] + Integer.one()
    --        local result = inn*out
    --        table.insert(results,result)
    --    end
    --    return BinaryOperation(BinaryOperation.ADD,results):autosimplify()
    --end

    --if exp:type() == FunctionExpression then
    --    if exp.expressions[2] then
    --        return self
    --    end
    --    return DerivativeExpression(exp.expressions[1], self.symbol) * FunctionExpression(exp.name, exp.expressions, exp.orders[1] + Integer.one(), exp.variables[1]):autosimplify()
    --end

    -- Chain rule for trig functions
    if exp:type() == TrigExpression then
        local internal = DerivativeExpression(exp.expression, self.symbol)

        if exp.name == "sin" then
            return (internal * COS(exp.expression)):autosimplify()
        end
        if exp.name == "cos" then
            return (internal * -SIN(exp.expression)):autosimplify()
        end
        if exp.name == "tan" then
            return (internal * SEC(exp.expression)^Integer(2)):autosimplify()
        end
        if exp.name == "csc" then
            return (internal * -CSC(exp.expression)*COT(exp.expression)):autosimplify()
        end
        if exp.name == "sec" then
            return (internal * -SEC(exp.expression)*TAN(exp.expression)):autosimplify()
        end
        if exp.name == "cot" then
            return (internal * -CSC(exp.expression)^Integer(2)):autosimplify()
        end
        if exp.name == "arcsin" then
            return (internal / (Integer(1)-exp.expression^Integer(2))^(Integer(1)/Integer(2))):autosimplify()
        end
        if exp.name == "arccos" then
            return (-internal / (Integer(1)-exp.expression^Integer(2))^(Integer(1)/Integer(2))):autosimplify()
        end
        if exp.name == "arctan" then
            return (internal / (Integer(1)+exp.expression^Integer(2))):autosimplify()
        end
        if exp.name == "arccsc" then
            return (-internal / (ABS(exp.expression) * (Integer(1)-exp.expression^Integer(2))^(Integer(1)/Integer(2)))):autosimplify()
        end
        if exp.name == "arcsec" then
            return (internal / (ABS(exp.expression) * (Integer(1)-exp.expression^Integer(2))^(Integer(1)/Integer(2)))):autosimplify()
        end
        if exp.name == "arccot" then
            return (-internal / (Integer(1)+exp.expression^Integer(2))):autosimplify()
        end
    end

    -- TODO: Piecewise functions
    if self:type() == AbsExpression then
        return DerivativeExpression(self.expression, self.symbol):autosimplify()
    end

    -- Uses linearity of derivatives to evaluate sum expressions
    if exp.operation == BinaryOperation.ADD then
        local parts = {}
        for i, expression in pairs(exp.expressions) do
            parts[i] = DerivativeExpression(expression, self.symbol)
        end
        return BinaryOperation(BinaryOperation.ADD, parts):autosimplify()
    end

    -- Uses product rule to evaluate product expressions
    if exp.operation == BinaryOperation.MUL then
        local sums = {}
        for i, expression in pairs(exp.expressions) do
            local products = {}
            for j, innerexpression in pairs(exp.expressions) do
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
    if exp.operation == BinaryOperation.POW then
        local base = exp.expressions[1]
        local exponent = exp.expressions[2]

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

    if exp:type() == Logarithm then
        local base = exp.base
        local expression = exp.expression

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

--- @return Expression
function DerivativeExpression:autosimplify()
    return DerivativeExpression(self.expression:autosimplify(), self.symbol):evaluate()
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
    return '\\frac{d}{d' .. self.symbol:tolatex() .. '}\\left(' .. self.expression:tolatex() .. '\\right)'
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