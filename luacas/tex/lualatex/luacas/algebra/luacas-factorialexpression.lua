--- @class FactorialExpression
--- The factorial of an expression.
--- @field expression Expression
FactorialExpression = {}
local __FactorialExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new factorial expression with the given expression.
--- @param expression Expression
--- @return FactorialExpression
function FactorialExpression:new(expression)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.expression = expression

    __o.__index = FactorialExpression
    __o.__tostring = function(a)
        return '(' .. tostring(a.expression) .. ')!'
    end

    o = setmetatable(o, __o)
    return o
end

--- @return Expression
function FactorialExpression:evaluate()
    if self.expression:type() == Integer then
        if self.expression < Integer.zero() then
            error("Aritmetic Error: Factorials of negative integers are not defined.")
        end

        if not FactorialExpression.LIMIT then
            FactorialExpression.LIMIT = Integer(5000)
        end

        if self.expression > FactorialExpression.LIMIT then
            return self
        end
        -- TODO: More efficient factorial computations.
        local out = Integer.one()
        local i = Integer.zero()
        while i < self.expression do
        i = i + Integer.one()
        out = out * i
        end
        return out
    end
    return self
end

--- @return Expression
function FactorialExpression:autosimplify()
    return FactorialExpression(self.expression:autosimplify()):evaluate()
end

--- @return table<number, Expression>
function FactorialExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return AbsExpression
function FactorialExpression:setsubexpressions(subexpressions)
    return FactorialExpression(subexpressions[1])
end

--- @param other Expression
--- @return boolean
function FactorialExpression:order(other)
    return FunctionExpression("fact", self.expression):order(other)
end

--- @return string
function FactorialExpression:tolatex()
    if self.expression:isatomic() then
        return self.expression:tolatex() .. "!"
    end
    return "(" .. self.expression:tolatex() .. ")!"
end

-----------------
-- Inheritance --
-----------------

__FactorialExpression.__index = CompoundExpression
__FactorialExpression.__call = FactorialExpression.new
FactorialExpression = setmetatable(FactorialExpression, __FactorialExpression)

----------------------
-- Static constants --
----------------------

-- Do not attempt to compute factorials larger than this.
FactorialExpression.LIMIT = Integer(5000)

FACT = function (a)
    return FactorialExpression(a)
end