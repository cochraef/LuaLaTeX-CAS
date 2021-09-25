-- A symbolic expression that can be substituted for another expression
-- SymbolExpressions have the following instance variables:
--      symbol - the string representation of the symbol
-- SymbolExpressions have the following relations to other classes:
--      SymbolExpressions extend AtomicExpressions
SymbolExpression = {}
__SymbolExpression = {}

----------------------
-- Instance methods --
----------------------

-- Given the name of the symbol as a string, creates a new symbol
function SymbolExpression:new(symbol)
    local o = {}
    local __o = {}
    __o.__index = SymbolExpression
    __o.__tostring = function(a)
        return a.symbol
    end

    if type(symbol) ~= "string" then
        error("Sent parameter of wrong type: symbol must be a string")
    end

    o.symbol = symbol
    o = setmetatable(o, __o)

    return o
end

-- Substitutes the variable for a new one
function SymbolExpression:substitute(variables)
    if type(variables) ~= "table" then
        error("Sent parameter of wrong type: variables must be a table")
    end

    for index, expression in pairs(variables) do
        if type(index) ~= "string" then
            error("Sent parameter of wrong type: variables must have strings as indicies")
        end
        if index == self.symbol then
            return expression
        end
    end

    return self
end

-- Symbols can not be evaluated to a concrete value
function SymbolExpression:isEvaluatable()
    return false
end

-----------------
-- Inheritance --
-----------------

__SymbolExpression.__index = AtomicExpression
__SymbolExpression.__call = SymbolExpression.new
SymbolExpression = setmetatable(SymbolExpression, __SymbolExpression)
