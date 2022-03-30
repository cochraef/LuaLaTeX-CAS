--- @class SymbolExpression
--- @alias Symbol SymbolExpression
--- An atomic expression corresponding to a symbol representing an arbitary value.
--- @field symbol string
SymbolExpression = {}
__SymbolExpression = {}

----------------------
-- Instance methods --
----------------------

--- Given the name of the symbol as a string, creates a new symbol.
--- @param symbol string
--- @return SymbolExpression
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

--- @return boolean
function SymbolExpression:freeof(symbol)
    return symbol~=self
end

--- @return boolean
function SymbolExpression:isconstant()
    return false
end

--- @param other Expression
--- @return boolean
function SymbolExpression:order(other)

    -- Symbol Expressions come after constant expressions.
    if other:isconstant() then
        return false
    end

    -- Lexographic order on symbols.
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

    return false
end

--- Converts this symbol to an element of a polynomial ring.
--- @return PolynomialRing, boolean
function SymbolExpression:topolynomial()
    return PolynomialRing({Integer.zero(), Integer.one()}, self.symbol), true
end

-----------------
-- Inheritance --
-----------------

__SymbolExpression.__index = AtomicExpression
__SymbolExpression.__call = SymbolExpression.new
SymbolExpression = setmetatable(SymbolExpression, __SymbolExpression)


----------------------
-- Static Constants --
----------------------

-- The constant pi.
PI = SymbolExpression("pi")

-- Approximates pi as a rational number. Uses continued fraction expansion.
function PI:approximate()
    return Integer(313383936) / Integer(99753205)
end

function PI:tolatex()
    return "\\pi"
end

-- The constant e.
E = SymbolExpression("e")

-- Approximates pi as a rational number. Uses continued fraction expansion.
function E:approximate()
    return Integer(517656) / Integer(190435)
end


-- The imaginary constant i.
I = SymbolExpression("i")