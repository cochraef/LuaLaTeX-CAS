-- Represents a trigonometric function from one expression to another.
-- TrigExpressions have the following instance variables:
--      name - the string name of the function
--      expression - an expression that is passed in to the function
-- TrigExpressions have the following relations to other classes:
--      TrigExpressions extend CompoundExpressions
TrigExpression = {}
__TrigExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new trig expression with the given name and expression
function TrigExpression:new(name, expression)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    if not TrigExpression.NAMES[name] then
        error("Argument error: " .. name .. " is not the name of a trigonometric function.")
    end

    o.name = name
    o.expression = expression

    __o.__index = TrigExpression
    __o.__tostring = function(a)
        return tostring(a.name) .. '(' .. tostring(a.expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not b:type() == TrigExpression then
            return false
        end
        return a.name == b.name and a.expression == b.expression
    end

    o = setmetatable(o, __o)
    return o
end

function TrigExpression:evaluate()
    return self
end

function TrigExpression:freeof(symbol)
    return self.expression:freeof(symbol)
end

function TrigExpression:substitute(map)
    for expression, replacement in pairs(map) do
        if self == expression then
            return replacement
        end
    end
    return TrigExpression(self.name, self.expression:substitute(map))
end

-- TODO : Trigonometric autosimplification
function TrigExpression:autosimplify()
    return TrigExpression(self.name, self.expression:autosimplify())
end

function TrigExpression:order(other)
    if other:type() == FunctionExpression then
        return true
    end

    if other:type() ~= TrigExpression then
        return false
    end

    if TrigExpression.NAMES[self.name] ~= TrigExpression.NAMES[other.name] then
        return TrigExpression.NAMES[self.name] < TrigExpression.NAMES[other.name]
    end
    return self.expression:order(other.expression)
end

function TrigExpression:tolatex()
    return "\\" + self.name + "(" + self.expression:tolatex() + ")"
end

-----------------
-- Inheritance --
-----------------

__TrigExpression.__index = CompoundExpression
__TrigExpression.__call = TrigExpression.new
TrigExpression = setmetatable(TrigExpression, __TrigExpression)

----------------------
-- Static constants --
----------------------
TrigExpression.NAMES = {sin=1, cos=2, tan=3, csc=4, sec=5, cot=6,
                         arcsin=7, arccos=8, arctan=9, arccsc=10, arcsec=11, arccot=12}

SIN = function (a)
    return TrigExpression("sin", a)
end

COS = function (a)
    return TrigExpression("cos", a)
end

TAN = function (a)
    return TrigExpression("tan", a)
end

CSC = function (a)
    return TrigExpression("csc", a)
end

SEC = function (a)
    return TrigExpression("sec", a)
end

COT = function (a)
    return TrigExpression("cot", a)
end

ARCSIN = function (a)
    return TrigExpression("arcsin", a)
end

ARCCOS = function (a)
    return TrigExpression("arccos", a)
end

ARCTAN = function (a)
    return TrigExpression("arctan", a)
end

ARCCSC = function (a)
    return TrigExpression("arccsc", a)
end

ARCSEC = function (a)
    return TrigExpression("arcsec", a)
end

ARCCOT = function (a)
    return TrigExpression("arccot", a)
end
