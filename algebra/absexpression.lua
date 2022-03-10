-- Represents the absolute value of an expression.
-- AbsExpressions have the following instance variables:
--      expression - the expression inside the absolute value
-- AbsExpressions have the following relations to other classes:
--      AbsExpression extend CompoundExpressions
AbsExpression = {}
__AbsExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new absolute value expression with the given expression.
function AbsExpression:new(expression)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.expression = expression

    __o.__index = AbsExpression
    __o.__tostring = function(a)
        return '|' .. tostring(a.expression) .. '|'
    end


    o = setmetatable(o, __o)
    return o
end

function AbsExpression:evaluate()
    if self.expression:isevaluatable() then
        if self.expression >= Integer(0) then
            return self.expression
        end
        return -self.expression
    end
    return self
end

function AbsExpression:freeof(symbol)
    return self.expression:freeof(symbol)
end

function AbsExpression:substitute(map)
    for expression, replacement in pairs(map) do
        if self == expression then
            return replacement
        end
    end
    return AbsExpression(self.expression:substitute(map))
end

function AbsExpression:autosimplify()
    return self:evaluate()
end

function AbsExpression:order(other)
    if other:isatomic() then
        return false
    end

    if other:type() ~= AbsExpression then
        return true
    end

    return self.expression:order(other.expression)
end

function AbsExpression:tolatex()
    return "|" + self.expression:tolatex() + "|"
end

-----------------
-- Inheritance --
-----------------

__AbsExpression.__index = CompoundExpression
__AbsExpression.__call = AbsExpression.new
AbsExpression = setmetatable(AbsExpression, __AbsExpression)

----------------------
-- Static constants --
----------------------
ABS = function (a)
    return AbsExpression(a)
end