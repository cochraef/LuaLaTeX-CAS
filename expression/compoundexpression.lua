-- An expression consisting of multiple other expressions and some function to apply to all of them
-- CompoundExpressions have the following instance variables:
--      name - the string name of the function
--      operation - the operation to apply to the list of operands
--      expressions - a list of subexpressions associated with this expression
-- CompoundExpressions have the following relations with other classes:
--      CompoundExpressions extend expressions

CompoundExpression = {}
__CompoundExpression = {}

----------------------
-- Instance methods --
----------------------

function CompoundExpression:new(operation, expressions, name)
    local o = {}
    local __o = {}

    __o.__index = CompoundExpression
    __o.__tostring = function(a)
        local expressionnames = "";
        for _, expression in ipairs(expressions) do
           expressionnames = expressionnames .. " " .. tostring(expression)
        end
        return "(" .. a.name .. expressionnames .. " )"
    end

    if type(name) ~= "string" and type(name) ~= "nil" then
        error("Sent parameter of wrong type: name must be a string")
    end

    if type(operation) ~= "function" then
        error("Sent parameter of wrong type: operation must be a function")
    end

    if type(expressions) ~= "table" then
        error("Sent parameter of wrong type: expressions must be an array")
    end

    o.name = name
    o.operation = operation
    o.expressions = Copy(expressions)

    return o
end

-- Evaluates each sub-expression and returns the evaluation of this expression
function CompoundExpression:evaluate()
    local results = {}
    local reducible = true
    for index, expression in ipairs(self.expressions) do
        results[index] = expression.evaluate()
        if not expression:isAtomic() then
            reducible = false
        end
    end
    if not reducible then
        return CompoundExpression(self.operation, results, self.name)
    end
    return self.operation(results)
end

-- Substitutes each variable for a new one
function CompoundExpression:substitute(variables)
    local results = {}
    for index, expression in pairs(self.expressions) do
        results[index] = expression:substitute(variables)
    end
    return CompoundExpression(self.operation, self.results, self.name)
end

-- Returns whether the expression is atomic or not
function CompoundExpression:isAtomic()
    return false
end

-- Returns whether the expression can be evaluated by compound expressions or not
function CompoundExpression:isEvaluatable()
    return false
end

-----------------
-- Inheritance --
-----------------

__CompoundExpression.index = Expression
__CompoundExpression.call = CompoundExpression.new
CompoundExpression = setmetatable(CompoundExpression, __CompoundExpression)