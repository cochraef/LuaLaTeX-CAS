--- @class CompoundExpression
--- Interface for an expression consisting of one or more subexpressions.
CompoundExpression = {}
__CompoundExpression = {}

----------------------
-- Instance methods --
----------------------

--- @param symbol SymbolExpression
--- @return boolean
function CompoundExpression:freeof(symbol)
    for _, expression in ipairs(self:subexpressions()) do
        if not expression:freeof(symbol) then
            return false
        end
    end
    return true
 end

--- @param map table<Expression, Expression>
--- @return Expression
function CompoundExpression:substitute(map)
    for expression, replacement in pairs(map) do
        if self == expression then
            return replacement
        end
    end

    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:substitute(map)
    end
    return self:setsubexpressions(results)
end

--- @return boolean
function CompoundExpression:isatomic()
    return false
end

--- @return boolean
function CompoundExpression:isconstant()
    return false
end

-----------------
-- Inheritance --
-----------------

__CompoundExpression.__index = Expression
CompoundExpression = setmetatable(CompoundExpression, __CompoundExpression)