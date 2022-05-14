--- @class DerrivativeExpression
--- An expression for a single-variable derrivative of an expression.
--- @field symbol SymbolExpression
--- @field expression Expression
DerrivativeExpression = {}
__DerrivativeExpression = {}

DiffExpression = {}
__DiffExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new derrivative operation with the given symbol and expression.
--- @param expression Expression
--- @param symbol Symbol
--- @return DerrivativeExpression
function DerrivativeExpression:new(expression, symbol)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    symbol = symbol or SymbolExpression("x")

    o.symbol = symbol
    o.expression = Copy(expression)

    __o.__index = DerrivativeExpression
    __o.__tostring = function(a)
        return '(d/d' .. tostring(a.symbol) .. " " .. tostring(a.expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == DerrivativeExpression then
            return false
        end
        return a.symbol == b.symbol and a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

-- Creates a new derivative operation with the given symbols and expression.
--- @param expression Expression 
--- @param symbols Symbols 
--- @return DiffExpression 
function DiffExpression:new(expression,symbols)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.symbols = Copy(symbols)
    o.degree   = #o.symbols
    o.expression = Copy(expression)

    __o.__tostring = function(a) 
        local varlist = '(d'
        if a.degree == 1 then 
            varlist = varlist .. '/d' .. tostring(a.symbols[1]) .. " " .. tostring(a.expression) .. ')'
        end
        if a.degree > 1 then 
            varlist = varlist .. '^' .. tostring(a.degree) .. '/'
            local varnum = 1
            for index = 1, #a.symbols do 
                local var = a.symbols[#a.symbols-index+1] 
                if a.symbols[#a.symbols-index] == var then 
                    varnum = varnum + 1 
                    goto nextvar
                end
                if a.symbols[#a.symbols-index] ~=var then 
                    if varnum == 1 then 
                        varlist = varlist .. 'd' ..  tostring(var)
                    else
                        varlist = varlist .. 'd' ..  tostring(var) .. '^' .. tostring(varnum)
                    end
                    varnum = 1
                end
                ::nextvar::
            end 
            varlist = varlist .. " " .. tostring(a.expression) .. ')' 
        end 
        return varlist 
    end 

    __o.__index = DiffExpression
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == DiffExpression then
            return false
        end
        if a.expression ~= b.expression then 
            return false
        end
        local loc = 1
        while a.symbols[loc] or b.symbols[loc] do
            if not a.symbols[loc] or not b.symbols[loc] or
                (a.symbols[loc] ~= b.symbols[loc]) then
                return false
            end
            loc = loc + 1
        end
        return true 
    end
    o = setmetatable(o, __o)

    return o
end

--- @return Expression
function DerrivativeExpression:autosimplify()
    local simplified = self.expression:autosimplify()

    -- The derrivative of a constant is 0
    if simplified:isconstant() then
        return Integer.zero()
    end

    -- The derrivative of a symbol is either 1 or 0
    if simplified:type() == SymbolExpression then
        if self.symbol == simplified then
            return Integer.one()
        end
        return Integer.zero()
    end

    -- Chain rule for arbitrary functions
    if simplified:type() == FunctionExpression then
        if simplified.expressions[2] then
            return self
        end
        return (DerrivativeExpression(simplified.expressions[1], self.symbol) * FunctionExpression(simplified.name .. "'", simplified.expressions)):autosimplify()
    end

    -- Chain rule for trig functions
    if simplified:type() == TrigExpression then
        local internal = DerrivativeExpression(simplified.expression, self.symbol)

        if simplified.name == "sin" then
            return (internal * COS(simplified.expression)):autosimplify()
        end
        if simplified.name == "cos" then
            return (internal * -SIN(simplified.expression)):autosimplify()
        end
        if simplified.name == "tan" then
            return (internal * SEC(simplified.expression)^Integer(2)):autosimplify()
        end
        if simplified.name == "csc" then
            return (internal * -CSC(simplified.expression)*COT(simplified.expression)):autosimplify()
        end
        if simplified.name == "sec" then
            return (internal * -SEC(simplified.expression)*TAN(simplified.expression)):autosimplify()
        end
        if simplified.name == "cot" then
            return (internal * -CSC(simplified.expression)^Integer(2)):autosimplify()
        end
        if simplified.name == "arcsin" then
            return (internal / (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2))):autosimplify()
        end
        if simplified.name == "arccos" then
            return (-internal / (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2))):autosimplify()
        end
        if simplified.name == "arctan" then
            return (internal / (Integer(1)+simplified.expression^Integer(2))):autosimplify()
        end
        if simplified.name == "arccsc" then
            return (-internal / (ABS(simplified.expression) * (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2)))):autosimplify()
        end
        if simplified.name == "arcsec" then
            return (internal / (ABS(simplified.expression) * (Integer(1)-simplified.expression^Integer(2))^(Integer(1)/Integer(2)))):autosimplify()
        end
        if simplified.name == "arccot" then
            return (-internal / (Integer(1)+simplified.expression^Integer(2))):autosimplify()
        end
    end

    -- TODO: Piecewise functions
    if self:type() == AbsExpression then
        return DerrivativeExpression(self.expression, self.symbol):autosimplify()
    end

    -- Uses linearity of derrivatives to evaluate sum expressions
    if simplified.operation == BinaryOperation.ADD then
        local parts = {}
        for i, expression in pairs(simplified.expressions) do
            parts[i] = DerrivativeExpression(expression, self.symbol)
        end
        return BinaryOperation(BinaryOperation.ADD, parts):autosimplify()
    end

    -- Uses product rule to evaluate product expressions
    if simplified.operation == BinaryOperation.MUL then
        local sums = {}
        for i, expression in pairs(simplified.expressions) do
            local products = {}
            for j, innerexpression in pairs(simplified.expressions) do
                if i ~= j then
                    products[j] = innerexpression
                else
                    products[j] = DerrivativeExpression(innerexpression, self.symbol)
                end
            end
            sums[i] = BinaryOperation(BinaryOperation.MUL, products)
        end
        return BinaryOperation(BinaryOperation.ADD, sums):autosimplify()
    end

    -- Uses the generalized power rule to evaluate power expressions
    if simplified.operation == BinaryOperation.POW then
        local base = simplified.expressions[1]
        local exponent = simplified.expressions[2]

        return BinaryOperation.MULEXP({
                    BinaryOperation.POWEXP({base, exponent}),
                    BinaryOperation.ADDEXP({
                        BinaryOperation.MULEXP({
                            DD(base, self.symbol),
                            BinaryOperation.DIVEXP({exponent, base})}),
                        BinaryOperation.MULEXP({
                            DD(exponent, self.symbol),
                            LN(base)})})
                    }):autosimplify()
    end

    if simplified:type() == Logarithm then
        local base = simplified.base
        local expression = simplified.expression

        return BinaryOperation.SUBEXP({
                    BinaryOperation.DIVEXP({DD(expression, self.symbol),
                        BinaryOperation.MULEXP({expression, LN(base)})}),

                    BinaryOperation.DIVEXP({
                        BinaryOperation.MULEXP({LN(expression), DD(base, self.symbol)}),
                        BinaryOperation.MULEXP({BinaryOperation.POWEXP({LN(base), Integer(2)}), base})
                    })

                }):autosimplify()
    end

    return self
end

--- @return Expression
function DiffExpression:autosimplify()
    local simplified = self.expression:autosimplify()

    for index,var in ipairs(self.symbols) do 
        simplified = DerrivativeExpression(simplified,var):autosimplify()
    end
    return simplified
end

--- @return table<number, Expression>
function DerrivativeExpression:subexpressions()
    return {self.expression}
end

--- @return table<number, Expression>
function DiffExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return DerrivativeExpression
function DerrivativeExpression:setsubexpressions(subexpressions)
    return DerrivativeExpression(subexpressions[1], self.symbol)
end

--- @param subexpressions table<number, Expression>
--- @return DiffExpression
function DiffExpression:setsubexpressions(subexpressions)
    return DiffExpression(subexpressions[1], self.symbols)
end

-- function DerrivativeExpression:freeof(symbol)
--     return self.symbol.freeof(symbol) and self.expression:freeof(symbol)
-- end

-- Substitutes each expression for a new one.
-- function DerrivativeExpression:substitute(map)
--     for expression, replacement in pairs(map) do
--         if self == expression then
--             return replacement
--         end
--     end
--     -- Typically, we only perform substitution on autosimplified expressions, so this won't get called. May give strange results, i.e.,
--     -- substituting and then evaluating the derrivative may not return the same thing as evaluating the derrivative and then substituting.
--     return DerrivativeExpression(self.expression:substitute(map), self.symbol)
-- end

--- @param other Expression
--- @return boolean
function DerrivativeExpression:order(other)
    if other:type() == IntegralExpression then
        return true
    end

    if other:type() ~= DerrivativeExpression then
        return false
    end

    if self.symbol ~= other.symbol then
        return self.symbol:order(other.symbol)
    end

    return self.expression:order(other.expression)
end

--- @param other Expression
--- @return boolean
function DiffExpression:order(other)
    if other:type() == IntegralExpression then
        return true
    end

    if other:type() ~= DiffExpression then
        return false
    end

    if self.degree > other.degree then
        return false
    end

    if self.degree < other.degree then 
        return true
    end

    return self.expression:order(other.expression)
end

--- @return string
function DerrivativeExpression:tolatex()
    return '\\frac{d}{d' .. self.symbol:tolatex() .. '}(' .. self.expression:tolatex() .. ')'
end

function DiffExpression:tolatex()
    local varlist = '\\frac{'
    if self.degree == 1 then
        varlist = varlist .. '\\mathrm{d}}{\\mathrm{d}' .. self.symbols[1]:tolatex() .. '}\\left(' .. self.expression:tolatex() .. '\\right)'
    end
    if self.degree > 1 then       
        local cvarlist = {}
        local count = 1
        for index, var in ipairs(self.symbols) do 
            if var == self.symbols[index+1] then 
                count = count + 1
            else
                table.insert(cvarlist,{var,count})
                count = 1
            end
        end   
        if #cvarlist == 1 then 
            varlist = varlist .. '\\mathrm{d}^{' .. self.degree .. '}}{' .. '\\mathrm{d}' .. cvarlist[1][1]:tolatex() .. '^{' .. self.degree .. '}'
        end
        if #cvarlist > 1 then 
            varlist = varlist .. '\\partial^{' .. self.degree .. '}}{' 
            for index, varnum in ipairs(cvarlist) do 
                var = cvarlist[#cvarlist - index+1][1]
                num = cvarlist[#cvarlist - index+1][2]
                if num == 1 then 
                    varlist = varlist .. '\\partial ' .. var:tolatex()
                else 
                    varlist = varlist .. '\\partial ' .. var:tolatex() .. '^{' .. num .. '}'
                end
            end
        end 
        varlist = varlist .. '} \\left(' .. self.expression:tolatex() .. '\\right)'
    end 
    return varlist 
end 

-----------------
-- Inheritance --
-----------------
__DerrivativeExpression.__index = CompoundExpression
__DerrivativeExpression.__call = DerrivativeExpression.new
DerrivativeExpression = setmetatable(DerrivativeExpression, __DerrivativeExpression)

__DiffExpression.__index = CompoundExpression
__DiffExpression.__call = DiffExpression.new
DiffExpression = setmetatable(DiffExpression, __DiffExpression)

----------------------
-- Static constants --
----------------------
DD = function(expression, symbol)
    return DerrivativeExpression(expression, symbol)
end

diff = function(expression,...)
    local symbols = {}
    for i = 1, select("#",...) do 
        local var = select(i,...)
        if #var == 0 then 
            table.insert(symbols,var) 
        end
        if #var > 0 then 
            for index=1, RR(var[2]) do 
                table.insert(symbols,var[1])
            end
        end
    end
    return DiffExpression(expression,symbols)
end