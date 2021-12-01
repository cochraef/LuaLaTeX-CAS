-- Represents an unspecified function from one expression to another
-- FunctionExpressions have the following instance variables:
--      name - the string name of the function
--      expressions - a list of expressions that are passed in to the function
-- FunctionExpressions have the following relations to other classes:
--      FunctionExpressions extend CompoundExpressions
FunctionExpression = {}
__FunctionExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new function expression with the given operation
function FunctionExpression:new(name, expressions)
    local o = {}
    local __o = {}

    o.name = name
    o.expressions = expressions

    __o.__index = FunctionExpression
    __o.__tostring = function(a)
        local expressionnames = name .. '(';
        for index, expression in ipairs(a.expressions) do
            expressionnames = expressionnames .. tostring(expression)
            if a.expressions[index + 1] then
                expressionnames = expressionnames .. ', '
            end
        end
        return expressionnames .. ')'
    end

    o = setmetatable(o, __o)

    return o
end

function FunctionExpression:evaluate()
    return self
end

function FunctionExpression:substitute(variables)
    local results = {}
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:substitute(variables)
    end
    return FunctionExpression(self.name, results)
end

function FunctionExpression:autosimplify()
    local results = {}
    for index, expression in ipairs(self.expressions) do
        results[index] = expression:autosimplify()
    end
    return FunctionExpression(self.name, results)
end

function FunctionExpression:order(other)
    if other:type() == DerrivativeExpression then
        return true
    end

    if other:type() ~= FunctionExpression then
        return false
    end

    if self.name ~= other.name then
        return SymbolExpression(self.name):order(SymbolExpression(other.name))
    end

    local k = 1
    while self.expressions[k] and other.expressions[k] do
        if self.expressions[k] ~= other.expressions[k] then
            return self.expressions[k]:order(other.expressions[k])
        end
        k = k + 1
    end
    return #self.expressions < #other.expressions
end

function FunctionExpression:tolatex()
    local out = self.name .. '(';
    for index, expression in ipairs(self.expressions) do
        out = out .. expression:tolatex()
        if self.expressions[index + 1] then
            out = out .. ', '
        end
    end
    return out .. ')'
end

-----------------
-- Inheritance --
-----------------

__FunctionExpression.__index = CompoundExpression
__FunctionExpression.__call = FunctionExpression.new
FunctionExpression = setmetatable(FunctionExpression, __FunctionExpression)