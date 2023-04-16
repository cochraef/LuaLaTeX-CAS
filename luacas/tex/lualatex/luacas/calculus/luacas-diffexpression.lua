--- @class DiffExpression
--- An expression for a multi-variable higher-order derivatives of an expression.
--- @field symbols SymbolExpression
--- @field expression Expression

DiffExpression = {}
local __DiffExpression = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new derivative operation with the given symbols and expression.
--- @param expression Expression
--- @param symbols table<number, Symbol>
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
function DiffExpression:evaluate()
    local exp = self.expression

    for _,var in ipairs(self.symbols) do
        exp = DerivativeExpression(exp,var):evaluate()
    end
    return exp
end

--- @return Expression
function DiffExpression:autosimplify()
    return DiffExpression(self.expression:autosimplify(), self.symbols):evaluate()
end


--- @return table<number, Expression>
function DiffExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return DiffExpression
function DiffExpression:setsubexpressions(subexpressions)
    return DiffExpression(subexpressions[1], self.symbols)
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
function DiffExpression:tolatex()
    local varlist = '\\frac{'
    if self.degree == 1 then
        varlist = varlist .. 'd}{d' .. self.symbols[1]:tolatex() .. '}\\left(' .. self.expression:tolatex() .. '\\right)'
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
            varlist = varlist .. 'd^{' .. self.degree .. '}}{' .. 'd' .. cvarlist[1][1]:tolatex() .. '^{' .. self.degree .. '}'
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

__DiffExpression.__index = CompoundExpression
__DiffExpression.__call = DiffExpression.new
DiffExpression = setmetatable(DiffExpression, __DiffExpression)

----------------------
-- Static constants --
----------------------

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