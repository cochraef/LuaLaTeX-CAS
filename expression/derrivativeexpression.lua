-- An expression for a single-variable derrivative of an expression
-- DerrivativeExpressions have the following instance variables:
--      symbol - the SymbolExpression that the derrivative is taken with respect to
--      expression - an Expression to take the derrivative of
-- DerrivativeExpressions have the following relations with other classes:
--      DerrivativeExpressions extend CompoundExpressions

DerrivativeExpression = {}
__DerrivativeExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new derrivative operation with the given symbol and expression
function DerrivativeExpression:new(symbol, expression)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    if not symbol or not expression then
        error("Send wrong number of parameters: derrivatives must have a variable to differentiate with respect to and an expression to differentiate.")
    end

    o.symbol = symbol
    o.expression = Copy(expression)

    __o.__index = DerrivativeExpression
    __o.__tostring = function(a)
        return '(d/d' .. tostring(a.symbol) .. " " .. tostring(a.expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == DerrivativeExpression then
            return false
        end
        return a.symbol == b.symbol and a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

-- Substitutes each variable for a new one.
function DerrivativeExpression:substitute(variables)
    return DerrivativeExpression(self.symbol:substitute(variables), self.expression:substitute(variables))
end

-- Performs automatic simplification of a derrivative
function DerrivativeExpression:autosimplify()
    local simplified = self.expression:autosimplify()

    -- The derrivative of a constant is 0
    if simplified:isconstant() then
        return Integer.zero()
    end

    -- The derrivative of a symbol is either 1 or 0
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
        return DerrivativeExpression(self.symbol, simplified.expressions[1]):autosimplify() * FunctionExpression(simplified.name .. "'", simplified.expressions)
    end


    -- Uses linearity of derrivatives to evaluate sum expressions
    if simplified.operation == BinaryOperation.ADD then
        local parts = {}
        for i, expression in pairs(simplified.expressions) do
            parts[i] = DerrivativeExpression(self.symbol, expression)
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
                    products[j] = DerrivativeExpression(self.symbol, innerexpression)
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
                            DD(self.symbol, base),
                            BinaryOperation.DIVEXP({exponent, base})}),
                        BinaryOperation.MULEXP({
                            DD(self.symbol, exponent),
                            LN(base)})})
                    }):autosimplify()
    end

    if simplified:type() == Logarithm then
        local base = simplified.base
        local expression = simplified.expression

        return BinaryOperation.SUBEXP({
                    BinaryOperation.DIVEXP({DD(self.symbol, expression),
                        BinaryOperation.MULEXP({expression, LN(base)})}),

                    BinaryOperation.DIVEXP({
                        BinaryOperation.MULEXP({LN(expression), DD(self.symbol, base)}),
                        BinaryOperation.MULEXP({BinaryOperation.POWEXP({LN(base), Integer(2)}), base})
                    })

                }):autosimplify()
    end

    return self
end

function DerrivativeExpression:order(other)
    if other:type() ~= DerrivativeExpression then
        return false
    end

    if self.symbol ~= other.symbol then
        return self.symbol:order(other.symbol)
    end

    return self.expression:order(other.expression)
end

function DerrivativeExpression:tolatex()
    return '\\frac{d}{d' .. self.symbol:tolatex() .. '}(' .. self.expression:tolatex() .. ')'
end


-----------------
-- Inheritance --
-----------------
__DerrivativeExpression.__index = CompoundExpression
__DerrivativeExpression.__call = DerrivativeExpression.new
DerrivativeExpression = setmetatable(DerrivativeExpression, __DerrivativeExpression)

----------------------
-- Static constants --
----------------------

DD = function(symbol, expression)
    return DerrivativeExpression(symbol, expression)
end