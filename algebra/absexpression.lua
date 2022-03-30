--- @class AbsExpression
--- The absolute value of an expression.
--- @field expression Expression
AbsExpression = {}
__AbsExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new absolute value expression with the given expression.
--- @param expression Expression
--- @return AbsExpression
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

--- @return Expression
function AbsExpression:evaluate()
    if self.expression:isconstant() then
        if self.expression >= Integer(0) then
            return self.expression
        end
        return -self.expression
    end
    return self
end

--- @return Expression
function AbsExpression:autosimplify()
    return self:evaluate()
end

--- @return table<number, Expression>
function AbsExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return AbsExpression
function AbsExpression:setsubexpressions(subexpressions)
    return AbsExpression(subexpressions[1])
end

--- @param other Expression
--- @return boolean
function AbsExpression:order(other)
    if other:isatomic() then
        return false
    end

    if other:type() ~= AbsExpression then
        return true
    end

    return self.expression:order(other.expression)
end

--- @return string
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