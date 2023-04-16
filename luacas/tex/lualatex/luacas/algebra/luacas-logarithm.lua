--- @class Logarithm
--- An expression for the logarithm of an expression with respect to another.
--- Currently, logarithms are not being evaluated since we are just doing symbolic computation.
--- @field base Expression
--- @field expression Expression
Logarithm = {}
local __Logarithm = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new logarithm expression with the given symbol and expression.
--- @param base Expression
--- @param expression Expression
--- @
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
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not b:type() == Logarithm then
            return false
        end
        return a.base == b.base and a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

--- @return Expression
function Logarithm:evaluate()

    if (self.base:isconstant() and (self.base <= Integer.zero() or self.base == Integer.one())) or
        (self.expression:isconstant() and self.expression <= Integer.zero()) then
        error("Arithmetic error: division by zero")
    end

    if not self.base:isconstant() or not self.expression:isconstant() then
        return self
    end

    local power = Integer.one()
    local base = self.base
    if base:type() == Integer then
        local pp, b, p = base:isperfectpower()
        if pp then
            base = b
            power = p
        end
    end

    if base:type() == Rational then
        local ppn, bn, pn = base.numerator:isperfectpower()
        local ppd, bd, pd = base.denominator:isperfectpower()
        if base.numerator == Integer.one() then
            ppn = true
            bn = Integer.one()
            pn = pd
        end
        if ppn and ppd and pn == pd then
            base = bn / bd
            power = pn
        end
    end

    local result = Integer.one()
    local expression = self.expression
    local sign = Integer.one()
    if base < Integer.one() then
        base = Integer.one() / base
        sign = -sign
    end


    local current = base
    while current < expression do
        current = current * base
        result = result + Integer.one()
    end
    if current == expression then
        return sign * result / power
    else
        while current > expression do
            current = current / base
            result = result - Integer.one()
        end
        if current == expression then
            return sign * result / power
        end
    end

    return self
end

--- @return Expression
function Logarithm:autosimplify()

    local base = self.base:autosimplify()
    local expression = self.expression:autosimplify()

    local evaluated = Logarithm(base, expression):evaluate()
    if evaluated:type() ~= Logarithm then
        return evaluated
    end

    -- Uses the property that log(b, 1) = 0
    if expression == Integer.one() then
        return Integer.zero()
    end

    -- Uses the property that log(b, b) = 1
    if expression == base then
        return Integer.one()
    end

    -- Uses the propery that log(b, x^y) = y * log(b, x)
    if expression.operation == BinaryOperation.POW then
        return BinaryOperation.MULEXP({expression.expressions[2], Logarithm(base, expression.expressions[1])}):autosimplify()
    end

    if expression:type() == Rational and expression.numerator == Integer.one() then
        return (-Logarithm(base, expression.denominator)):autosimplify()
    end

    -- Our expression cannot be simplified
    return Logarithm(base, expression)
end

--- @return Expression
function Logarithm:expand()
    return Logarithm(self.base:expand(), self.expression:expand()):autosimplify()
end

--- @return table<number, Expression>
function Logarithm:subexpressions()
    return {self.base, self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return Logarithm
function Logarithm:setsubexpressions(subexpressions)
    return Logarithm(subexpressions[1], subexpressions[2])
end

--- @param other Expression
--- @return boolean
function Logarithm:order(other)
    return FunctionExpression("log", {self.base, self.expression}):order(other)
end

--- @return string
function Logarithm:tolatex()
    if self.base == E then
        return '\\ln\\mathopen{}\\left(' .. self.expression:tolatex() .. '\\right)'
    end
    return '\\log_' .. self.base:tolatex() .. '\\mathopen{}\\left(' .. self.expression:tolatex() .. '\\right)'
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