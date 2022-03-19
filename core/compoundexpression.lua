-- Interface for an expression consisting of multiple other expressions and some function to apply to all of them
-- CompoundExpressions have the following instance variables:
--      name - the string name of the function
--      operation - the operation to apply to the list of operands
--      expressions - a list of subexpressions associated with this expression
-- CompoundExpressions have the following relations with other classes:
--      CompoundExpressions extend Expressions

CompoundExpression = {}
__CompoundExpression = {}

----------------------
-- Instance methods --
----------------------

-- Returns whether the expression is atomic or not
function CompoundExpression:isatomic()
    return false
end

-- Returns whether the expression can be evaluated by compound expressions or not
function CompoundExpression:isevaluatable()
    return false
end

function CompoundExpression:isconstant()
    return false
end

-----------------
-- Inheritance --
-----------------

__CompoundExpression.__index = Expression
CompoundExpression = setmetatable(CompoundExpression, __CompoundExpression)