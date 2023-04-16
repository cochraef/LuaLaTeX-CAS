--- @class AtomicExpression
--- Interface for an atomic mathematical expression that has no sub-expressions.
AtomicExpression = {}
local __AtomicExpression = {}


----------------------
-- Required methods --
----------------------

--- Converts an atomic expression to its equivalent compound expression, if it has one.
--- @return Expression
function AtomicExpression:tocompoundexpression()
    return self
end

----------------------
-- Instance methods --
----------------------

--- @return AtomicExpression
function AtomicExpression:evaluate()
    return self
end

--- @return AtomicExpression
function AtomicExpression:autosimplify()
    return self
end

--- @return table<number, Expression>
function AtomicExpression:subexpressions()
    return {}
end

--- @param subexpressions table<number, Expression>
--- @return AtomicExpression
function AtomicExpression:setsubexpressions(subexpressions)
    return self
end

--- @param map table<Expression, Expression>
--- @return Expression
function AtomicExpression:substitute(map)
    for expression, replacement in pairs(map) do
        if self == expression then
            return replacement
        end
    end
    return self
end

--- @return boolean
function AtomicExpression:isatomic()
    return true
end

--- @return string
function AtomicExpression:tolatex()
    -- Most atomic expressions should have the same __tostring as LaTeX's output
    return tostring(self)
end


-----------------
-- Inheritance --
-----------------

__AtomicExpression.__index = Expression
AtomicExpression = setmetatable(AtomicExpression, __AtomicExpression)