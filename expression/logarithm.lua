-- An expression for the logarithm of an expression with respect to another.
-- Currently, logarithms are not being evaluated since we are just doing symbolic computation.
-- Logarithms have the following instance variables:
--      base - an Expression
--      expression - another Expression
-- DerrivativeExpressions have the following relations with other classes:
--      DerrivativeExpressions extend CompoundExpressions

Logarithm = {}
__Logarithm = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new logarithm expression with the given symbol and expression
function Logarithm:new(base, expression)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.base = Copy(base)
    o.expression = Copy(expression)

    __o.__index = Logarithm
    __o.__tostring = function(a)
        return 'log(' .. tostring(base) .. ', ' .. tostring(expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == Logarithm then
            return false
        end
        return a.base == b.base and a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

-- Substitutes each variable for a new one
function Logarithm:substitute(variables)
    return Logarithm(self.base:substitute(variables), self.expression:substitute(variables))
end

-- Performs automatic simplification of a logarithm
function Logarithm:autosimplify()

    local base = self.base:autosimplify()
    local expression = self.expression:autosimplify()

    -- Uses the property that log(b, 1) = 0
    if expression == Integer(1) then
        return Integer(0)
    end

    -- Uses the property that log(b, b) = 1
    if expression == base then
        return Integer(1)
    end

    -- Uses the propery that log(b, x^y) = y * log(b, x)
    if expression.operation == BinaryOperation.POW then
        return BinaryOperation.MULEXP({expression.expressions[2], Logarithm(base, expression.expressions[1])}):autosimplify()
    end

    -- Our expression cannot be simplified
    return Logarithm(base, expression)
end

function Logarithm:order(other)
    if other:isAtomic() then
        return false
    end

    if other:type() == Logarithm then
        if self.base ~= other.base then
            return self.base:order(other.base)
        end
        return self.expression:order(other.expression)
    end


    return true
end

function Logarithm:tolatex()
    if self.base == E then
        return '\\ln(' .. self.expression:tolatex() .. ')'
    end
    return '\\log_' .. self.base:tolatex() .. '(' .. self.expression:tolatex() .. ')'
end

-----------------
-- Inheritance --
-----------------
__Logarithm.__index = CompoundExpression
__Logarithm.__call = Logarithm.new
Logarithm = setmetatable(Logarithm, __Logarithm)

----------------------
-- Static constants --
----------------------

LOG = function(base, expression)
    return Logarithm(base, expression)
end

LN = function(expression)
    return Logarithm(E, expression)
end