--- @class FunctionExpression
--- Represents a generic function that takes zero or more expressions as inputs.
--- @field name SymbolExpression
--- @field expressions table<number, Expression>
--- @field orders table<number, Integer>
--- @field variables table<number,SymbolExpression>
--- @alias Function FunctionExpression
FunctionExpression = {}
local __FunctionExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new function expression with the given operation.
--- @param name string|SymbolExpression
--- @param expressions table<number, Expression>
--- @param derivatives table<number,Integer>
--- @return FunctionExpression
function FunctionExpression:new(name, expressions, derivatives)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    if type(name) == "table" and name:type() == SymbolExpression then
        name = name.symbol
    end

    if TrigExpression.NAMES[name] and #expressions == 1 then
        return TrigExpression(name, expressions[1])
    end

    -- TODO: Symbol Checking For Constructing derivatives like this
    --if string.sub(name, #name, #name) == "'" and #expressions == 1 then
    --   return DerivativeExpression(FunctionExpression(string.sub(name, 1, #name - 1), expressions), SymbolExpression("x"), true)
    --end

    o.name = name
    o.expressions = Copy(expressions)
    o.variables = Copy(expressions)
    for _,expression in ipairs(o.variables) do
        if not expression:isatomic() then
            o.variables = {}
            if #o.expressions < 4 then
                local defaultvars = {SymbolExpression('x'),SymbolExpression('y'),SymbolExpression('z')}
                for i=1,#o.expressions do
                    o.variables[i] = defaultvars[i]
                end
            else
                for i=1,#o.expressions do
                    o.variables[i] = SymbolExpression('x_'..tostring(i))
                end
            end
        end
    end
    if derivatives then
        o.derivatives = Copy(derivatives)
    else
        o.derivatives = {}
        for i=1,#o.variables do
            o.derivatives[i] = Integer.zero()
        end
    end

    __o.__index = FunctionExpression
    __o.__tostring = function(a)
        local total = Integer.zero()
        for _,integer in ipairs(a.derivatives) do
            total = total + integer
        end
        if total == Integer.zero() then
            local out = a.name .. '('
            for index, expression in ipairs(a.expressions) do
                out = out .. tostring(expression)
                if a.expressions[index + 1] then
                    out = out .. ', '
                end
            end
            return out .. ')'
        else
            local out = 'd'
            if total > Integer.one() then
                out = out ..'^' .. tostring(total)
            end
            out = out .. a.name .. '/'
            for index,integer in ipairs(a.derivatives) do
                if integer > Integer.zero() then
                    out = out .. 'd' .. tostring(a.variables[index])
                    if integer > Integer.one() then
                        out = out .. '^' .. tostring(integer)
                    end
                end
            end
            out = out .. '('
            for index, expression in ipairs(a.expressions) do
                out = out .. tostring(expression)
                if a.expressions[index + 1] then
                    out = out .. ', '
                end
            end
            return out .. ')'
        end
    end
    __o.__eq = function(a, b)
        -- if b:type() == TrigExpression then
        --     return a == b:tofunction()
        -- end
        if b:type() ~= FunctionExpression then
            return false
        end
        if #a.expressions ~= #b.expressions then
            return false
        end
        for index, _ in ipairs(a.expressions) do
            if a.expressions[index] ~= b.expressions[index] then
                return false
            end
        end
        for index,_ in ipairs(a.derivatives) do
            if a.derivatives[index] ~= b.derivatives[index] then
                return false
            end
        end
        return a.name == b.name
    end

    o = setmetatable(o, __o)

    return o
end

--- @return FunctionExpression
function FunctionExpression:evaluate()
    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:evaluate()
    end
    local result = FunctionExpression(self.name, results, self.derivatives)
    result.variables = self.variables
    return result
end

--- @return FunctionExpression
function FunctionExpression:autosimplify()
    -- Since the function is completely generic, we can't really do anything execpt autosimplify subexpressions.
    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:autosimplify()
    end
    local result = FunctionExpression(self.name, results, self.derivatives)
    result.variables = self.variables
    return result
end

--- @return table<number, Expression>
function FunctionExpression:subexpressions()
    return self.expressions
end

--- @param subexpressions table<number, Expression>
--- @return FunctionExpression
function FunctionExpression:setsubexpressions(subexpressions)
    local result = FunctionExpression(self.name, subexpressions, self.derivatives)
    result.variables = self.variables
    return result
end

--- @param other Expression
--- @return boolean
function FunctionExpression:order(other)
    if other:isatomic() then
        return false
    end

    -- CASC Autosimplfication has some symbols appearing before functions, but that looks bad to me, so all symbols appear before products now.
    -- if other:type() == SymbolExpression then
    --     return SymbolExpression(self.name):order(other)
    -- end

    if other:type() == BinaryOperation then
        if other.operation == BinaryOperation.ADD or other.operation == BinaryOperation.MUL then
            return BinaryOperation(other.operation, {self}):order(other)
        end

        if other.operation == BinaryOperation.POW then
            return (self^Integer.one()):order(other)
        end
    end

    if other:type() == SqrtExpression then
        return self:order(other:topower())
    end

    -- TODO: Make Logarithm and AbsExpression inherit from function expression to reduce code duplication
    if other:type() == Logarithm then
        return self:order(FunctionExpression("log", {other.base, other.expression}))
    end

    if other:type() ~= FunctionExpression and other:type() ~= TrigExpression then
        return true
    end

    if self.name ~= other.name then
        return SymbolExpression(self.name):order(SymbolExpression(other.name))
    end

    local k = 1
    while self:subexpressions()[k] and other:subexpressions()[k] do
        if self:subexpressions()[k] ~= other:subexpressions()[k] then
            return self:subexpressions()[k]:order(other:subexpressions()[k])
        end
        k = k + 1
    end
    return #self.expressions < #other.expressions
end

--- @return string
function FunctionExpression:tolatex()
    local out = tostring(self.name)
    if self:type() == TrigExpression then
        out = "\\" .. out
    end
    if self:type() ~= TrigExpression and #self.name>1 then
        --if out:sub(2,2) ~= "'" then
            --local fp = out:find("'")
            --if fp then
            --    out = '\\operatorname{' .. out:sub(1,fp-1) .. '}' .. out:sub(fp,-1)
            --else
        out = '\\operatorname{' .. out .. '}'
            --end
        --end
    end
    local total = Integer.zero()
    for _,integer in ipairs(self.derivatives) do
        total = total + integer
    end
    if #self.expressions == 1 then
        if total == Integer.zero() then
            goto continue
        else
            if total < Integer(5) then
                while total > Integer.zero() do
                    out = out .. "'"
                    total = total - Integer.one()
                end
            else
                out = out .. '^{(' .. total:tolatex() .. ')}'
            end
        end
    end
    if #self.expressions > 1 then
        if total == Integer.zero() then
            goto continue
        else
            if total < Integer(4) then
                out = out .. '_{'
                for index,integer in ipairs(self.derivatives) do
                    local i = integer:asnumber()
                    while i > 0 do
                        out = out .. self.variables[index]:tolatex()
                        i = i - 1
                    end
                end
                out = out .. '}'
            else
                out = '\\frac{\\partial^{' .. total:tolatex() .. '}' .. out .. '}{'
                for index, integer in ipairs(self.derivatives) do
                    if integer > Integer.zero() then
                        out = out .. '\\partial ' .. self.variables[index]:tolatex()
                        if integer ~= Integer.one() then
                            out = out .. '^{' .. integer:tolatex() .. '}'
                        end
                    end
                end
                out = out .. '}'
            end
        end
    end
    ::continue::
    out = out ..'\\mathopen{}' .. '\\left('
    for index, expression in ipairs(self:subexpressions()) do
        out = out .. expression:tolatex()
        if self:subexpressions()[index + 1] then
            out = out .. ', '
        end
    end
    return out .. '\\right)'
end

-----------------
-- Inheritance --
-----------------

__FunctionExpression.__index = CompoundExpression
__FunctionExpression.__call = FunctionExpression.new
FunctionExpression = setmetatable(FunctionExpression, __FunctionExpression)