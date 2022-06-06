--- @class TrigExpression
--- Represents a trigonometric function from one expression to another.
--- @field name SymbolExpression
--- @field expression Expression
TrigExpression = {}
__TrigExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new trig expression with the given name and expression.
--- @param name string|SymbolExpression
--- @param expression Expression
--- @return TrigExpression
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
        -- if b:type() == FunctionExpression then
        --     return a:tofunction() == b
        -- end
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not b:type() == TrigExpression then
            return false
        end
        return a.name == b.name and a.expression == b.expression
    end

    o = setmetatable(o, __o)
    return o
end

--- @return TrigExpression
function TrigExpression:evaluate()
    return self
end

--- checks if expression is a rational multiple of pi
--- @return boolean
function Expression:ismulratlPI()
    if self.operation == BinaryOperation.MUL and #self.expressions == 2 and (self.expressions[1]:type() == Integer or self.expressions[1]:type() == Rational) and self.expressions[2] == PI then
        return true
    end

    return false
end

-- TODO : Trigonometric autosimplification
--- @return TrigExpression
function TrigExpression:autosimplify()
    local expression = self.expression:autosimplify()

     -- uses periodicity of sin and cos and friends
     if self.name == "sin" or self.name == "cos" or self.name == "csc" or self.name == "sec" then
        if expression == Integer.zero() or expression == PI then
            goto skip
        end
        if expression.operation ~= BinaryOperation.ADD then
            expression = BinaryOperation(BinaryOperation.ADD,{expression})
        end
        for index,component in ipairs(expression.expressions) do
            if component:ismulratlPI() then
                local coeff = component.expressions[1]
                if coeff:type() == Integer then
                    coeff = coeff % Integer(2)
                    coeff = coeff:autosimplify()
                end
                if coeff:type() == Rational then
                    local n = coeff.numerator
                    local d = coeff.denominator
                    local m = {n:divremainder(d)}
                    coeff = (m[1] % Integer(2)) + m[2]/d
                    coeff = coeff:autosimplify()
                end
                expression.expressions[index].expressions[1] = coeff
                expression = expression:autosimplify()
            end
        end
        expression = expression:autosimplify()
        ::skip::
    end

    -- uses periodicity of tan and cot
    if self.name == "tan" or self.name == "cot" then
        if expression == Integer.zero() or expression == PI then
            goto skip
        end
        if expression.operation ~= BinaryOperation.ADD then
            expression = BinaryOperation(BinaryOperation.ADD,{expression})
        end
        for index,component in ipairs(expression.expressions) do
            if component:ismulratlPI() then
                local coeff = component.expressions[1]
                if coeff:type() == Integer then
                    coeff = Integer.zero()
                end
                if coeff:type() == Rational then
                    local n = coeff.numerator
                    local d = coeff.denominator
                    local m = {n:divremainder(d)}
                    coeff = m[2]/d
                    coeff = coeff:autosimplify()
                end
                expression.expressions[index].expressions[1] = coeff
                expression = expression:autosimplify()
            end
            if component == PI then
                expression.expressions[index] = Integer.zero()
                expression = expression:autosimplify()
            end
        end
        ::skip::
    end

    if self.name == "cos" then
        if expression == Integer.zero() then
            return Integer.one()
        end
        if expression == PI then
            return -Integer.one()
        end
        if expression:ismulratlPI() then
            local coeff = expression.expressions[1]
            if coeff > Integer.one() then
                coeff = (Integer(2)-coeff):autosimplify()
            end
            if TrigExpression.VALUES[tostring(coeff)] ~= nil then
                return TrigExpression.VALUES[tostring(coeff)]:autosimplify()
            end
        end
    end

    if self.name == "sin" then
        if expression == Integer.zero() then
            return Integer.zero()
        end
        if expression == PI then
            return Integer.zero()
        end
        if expression:ismulratlPI() then
            local coeff = expression.expressions[1]
            local sign = Integer.one()
            if coeff > Integer.one() then
                coeff = (Integer(2) - coeff):autosimplify()
                sign = -sign:autosimplify()
            end
            if TrigExpression.VALUES[tostring(coeff)] ~= nil then
                return (sign*sqrt(Integer.one()-cos(expression)^Integer(2))):autosimplify()
            end
        end
    end

    if self.name == "tan" then
        if expression == Integer.zero() then
            return Integer.zero()
        end
        if expression == PI then
            return Integer.zero()
        end
        if expression:ismulratlPI() then
            local coeff = expression.expressions[1]
            if TrigExpression.VALUES[tostring(coeff)] ~= nil then
                return (sin(expression) / cos(expression)):autosimplify()
            end
        end
    end

    return TrigExpression(self.name, expression)
end

--- @return table<number, Expression>
function TrigExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return TrigExpression
function TrigExpression:setsubexpressions(subexpressions)
    return TrigExpression(self.name, subexpressions[1])
end

-- function TrigExpression:freeof(symbol)
--     return self.expression:freeof(symbol)
-- end

-- function TrigExpression:substitute(map)
--     for expression, replacement in pairs(map) do
--         if self == expression then
--             return replacement
--         end
--     end
--     return TrigExpression(self.name, self.expression:substitute(map))
-- end

-- function TrigExpression:order(other)
--     return self:tofunction():order(other)
-- end

-- function TrigExpression:tofunction()
--     return FunctionExpression(self.name, {self.expression}, true)
-- end

-----------------
-- Inheritance --
-----------------

__TrigExpression.__index = FunctionExpression
__TrigExpression.__call = TrigExpression.new
TrigExpression = setmetatable(TrigExpression, __TrigExpression)

----------------------
-- Static constants --
----------------------
TrigExpression.NAMES = {sin=1, cos=2, tan=3, csc=4, sec=5, cot=6,
                         arcsin=7, arccos=8, arctan=9, arccsc=10, arcsec=11, arccot=12}

TrigExpression.VALUES = {
    ["0"] = Integer.one(),
    ["1/6"] = sqrt(Integer(3))/Integer(2),
    ["1/4"] = sqrt(Integer(2))/Integer(2),
    ["1/3"] = Integer.one()/Integer(2),
    ["1/2"] = Integer.zero(),
    ["2/3"] = -Integer.one()/Integer(2),
    ["3/4"] = -sqrt(Integer(2))/Integer(2),
    ["5/6"] = -sqrt(Integer(3))/Integer(2),
    ["1"]   = -Integer.one()
}

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