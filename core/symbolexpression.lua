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
    local __o = Copy(__ExpressionOperations)
    __o.__index = SymbolExpression
    __o.__tostring = function(a)
        return a.symbol
    end
    __o.__eq = function(a, b)
        return a.symbol == b.symbol
    end

    if type(symbol) ~= "string" then
        error("Sent parameter of wrong type: symbol must be a string")
    end

    o.symbol = symbol
    o = setmetatable(o, __o)

    return o
end

-- This expression is free of a symbol if and only if the symbol is not the expression.
function SymbolExpression:freeof(symbol)
    return symbol~=self
end

-- Symbols can not be evaluated to a concrete value
function SymbolExpression:isevaluatable()
    return false
end

function SymbolExpression:order(other)
    -- Symbol Expressions come after concrete expressions
    if other.isevaluatable() then
        return false
    end

    if other:type() == SymbolExpression then
        if #other.symbol < #self.symbol then
            return false
        end
        for i = 1, #self.symbol do
            if string.byte(self.symbol, i) ~= string.byte(other.symbol, i) then
                return string.byte(self.symbol, i) < string.byte(other.symbol, i)
            end
        end

        return false
    end

    if other.operation == BinaryOperation.POW then
        return BinaryOperation(BinaryOperation.POW, {self, Integer.one()}):order(other)
    end

    if other.operation == BinaryOperation.MUL then
        return BinaryOperation(BinaryOperation.MUL, {self}):order(other)
    end

    if other.operation == BinaryOperation.ADD then
        return BinaryOperation(BinaryOperation.ADD, {self}):order(other)
    end

end

function SymbolExpression:topolynomial()
    return PolynomialRing({Integer.zero(), Integer.one()}, self.symbol), true
end

-- Variable names in LaTeX can be created with just that variable
function SymbolExpression:tolatex()
    return tostring(self)
end

-----------------
-- Inheritance --
-----------------

__SymbolExpression.__index = AtomicExpression
__SymbolExpression.__call = SymbolExpression.new
SymbolExpression = setmetatable(SymbolExpression, __SymbolExpression)
