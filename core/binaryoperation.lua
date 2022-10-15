--- @class BinaryOperation
--- Represents a binary operation with two inputs and one output.
--- Represents a generic function that takes zero or more expressions as inputs.
--- @field name string
--- @field operation function
--- @field expressions table<number, Expression>
BinaryOperation = {}
__BinaryOperation = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new binary operation with the given operation.
--- @param operation function
--- @param expressions table<number, Expression>
--- @return BinaryOperation
function BinaryOperation:new(operation, expressions)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    if type(operation) ~= "function" then
        error("Sent parameter of wrong type: operation must be a function")
    end

    if type(expressions) ~= "table" then
        error("Sent parameter of wrong type: expressions must be an array")
    end

    o.name = BinaryOperation.DEFAULT_NAMES[operation]
    o.operation = operation
    o.expressions = Copy(expressions)

    if BinaryOperation.COMMUTATIVITY[operation] then
        function o:iscommutative()
            return true
        end
    else
        function o:iscommutative()
            return false
        end
    end

    if not o:iscommutative() and o.operation ~= BinaryOperation.SUB and #o.expressions ~= 2 then
        error("Sent parameter of wrong type: noncommutative operations cannot have an arbitrary number of paramaters")
    end

    __o.__index = BinaryOperation
    __o.__tostring = function(a)
        local expressionnames = ''
        for index, expression in ipairs(a.expressions) do
            if index == 1 and not a.expressions[index + 1] then
                expressionnames = expressionnames .. a.name .. ' '
            end
            if index > 1 then
                expressionnames = expressionnames .. ' '
            end
            if expression:isatomic() and not (a.operation == BinaryOperation.POW and expression:type() == Rational) then
                expressionnames = expressionnames .. tostring(expression)
            else
                expressionnames = expressionnames .. '(' .. tostring(expression) .. ')'
            end
            if a.expressions[index + 1] then
                expressionnames = expressionnames .. ' ' .. a.name
            end
        end
        return expressionnames
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not a.operation or not b.operation then
            return false
        end
        local loc = 1
        while a.expressions[loc] or b.expressions[loc] do
            if not a.expressions[loc] or not b.expressions[loc] or
                (a.expressions[loc] ~= b.expressions[loc]) then
                return false
            end
            loc = loc + 1
        end
        return a.operation == b.operation
    end
    o = setmetatable(o, __o)

    return o
end

--- @return Expression
function BinaryOperation:evaluate()
    local results = {}
    local reducible = true
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:evaluate()
        if not results[index]:isconstant() then
            reducible = false
        end
    end
    if not reducible then
        return BinaryOperation(self.operation, results)
    end

    if not self.expressions[1] then
        error("Execution error: cannot perform binary operation on zero expressions")
    end

    local result = results[1]
    for index, expression in ipairs(results) do
        if not (index == 1) then
            result = self.operation(result, expression)
        end
    end
    return result
end

--- @return Expression
function BinaryOperation:autosimplify()
    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:autosimplify()
    end
    local simplified = BinaryOperation(self.operation, results)
    if simplified.operation == BinaryOperation.POW then
        return simplified:simplifypower()
    end
    if simplified.operation == BinaryOperation.MUL then
        return simplified:simplifyproduct()
    end
    if simplified.operation == BinaryOperation.ADD then
        return simplified:simplifysum()
    end
    if simplified.operation == BinaryOperation.DIV then
        return simplified:simplifyquotient()
    end
    if simplified.operation == BinaryOperation.SUB then
        return simplified:simplifydifference()
    end
    return simplified
end

--- @return table<number, Expression>
function BinaryOperation:subexpressions()
    return self.expressions
end

--- @param subexpressions table<number, Expression>
--- @return BinaryOperation
function BinaryOperation:setsubexpressions(subexpressions)
    return BinaryOperation(self.operation, subexpressions)
end

--- @return Expression
function BinaryOperation:expand()
    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:expand()
    end
    local expanded = BinaryOperation(self.operation, results)
    if expanded.operation == BinaryOperation.MUL then
        local allsums = BinaryOperation(BinaryOperation.ADD, {Integer.one()})
        for _, expression in ipairs(expanded.expressions) do
            allsums = allsums:expand2(expression)
        end
        return allsums:autosimplify()
    end
    if expanded.operation == BinaryOperation.POW and expanded.expressions[2]:type() == Integer then
        if expanded.expressions[1]:type() ~= BinaryOperation then
            return expanded:autosimplify()
        end
        local exp = BinaryOperation.MULEXP({Integer.one()})
        local pow = expanded.expressions[2]:asnumber()
        for _ = 1, math.abs(pow) do
            exp = exp:expand2(expanded.expressions[1])
            if _ > 1 then
                exp = exp:autosimplify()
            end
        end
        if pow < 0 then
            exp = exp^Integer(-1)
        end
        return exp
    end
    if expanded.operation == BinaryOperation.POW and expanded.expressions[2].operation == BinaryOperation.ADD then
        local exp = {}
        for i = 1, #expanded.expressions[2].expressions do
            exp[#exp+1] = (expanded.expressions[1]^expanded.expressions[2].expressions[i]):autosimplify()
        end
        return BinaryOperation.MULEXP(exp)
    end
    return expanded:autosimplify()
end

--- Helper for expand - multiplies two addition expressions.
--- @return Expression
function BinaryOperation:expand2(other)
    local result = {}
    for _, expression in ipairs(self:subexpressions()) do
        if other:type() == BinaryOperation and other.operation == BinaryOperation.ADD then
            for _, expression2 in ipairs(other.expressions) do
                result[#result+1] = expression * expression2
            end
        else
            result[#result+1] = expression * other
        end
    end
    return BinaryOperation(BinaryOperation.ADD, result)
end

--- @return Expression
function BinaryOperation:factor()
    local results = {}

    -- Recursively factors sub-expressions
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:factor()
    end

    -- Attempts to factor expressions as monovariate polynomials
    local factoredsubs = BinaryOperation(self.operation, results)
    local subs = factoredsubs:getsubexpressionsrec()
    for index, sub in ipairs(subs) do
        local substituted = factoredsubs:substitute({[sub]=SymbolExpression("_")}):autosimplify()
        local polynomial, result = substituted:topolynomial()
        if result then
            local factored = polynomial:factor():autosimplify()
            if factored ~= substituted then
                return factored:substitute({[SymbolExpression("_")]=sub})
            end
        end
    end

    -- Pulls common sub-expressions out of sum expressions
    if self.operation == BinaryOperation.ADD then
        local gcf
        for _, expression in ipairs(factoredsubs:subexpressions()) do
            if expression.operation ~= BinaryOperation.MUL then
                expression = BinaryOperation.MULEXP({expression})
            end
            if not gcf then
                gcf = expression
            else
                local newgcf = Integer.one()
                for _, gcfterm in ipairs(gcf:subexpressions()) do
                    local gcfpower = Integer.one()
                    if gcfterm:type() == BinaryOperation and gcfterm.operation == BinaryOperation.POW and gcfterm.expressions[2]:type() == Integer then
                        gcfpower = gcfterm.expressions[2]
                        gcfterm = gcfterm.expressions[1]
                    end
                    for _, term in ipairs(expression:subexpressions()) do
                        local power = Integer.one()
                        if term:type() == BinaryOperation and term.operation == BinaryOperation.POW and term.expressions[2]:type() == Integer then
                            power = term.expressions[2]
                            term = term.expressions[1]
                        end
                        if term == gcfterm then
                            newgcf = newgcf * term^Integer.min(power, gcfpower)
                        end
                    end
                end
                gcf = newgcf
            end
        end
        if gcf:type() ~= Integer then
            local out = Integer.zero()
            for _, expression in ipairs(factoredsubs:subexpressions()) do
                out = out + expression/gcf
            end
            out = gcf*(out:autosimplify():factor())
            return out:autosimplify()
        end
    end

    return factoredsubs
end

--- @return Expression
function BinaryOperation:combine()
    local den, num, aux, mul, input = {}, {}, {}, {}, self:autosimplify():expand()
    if input.operation ~= BinaryOperation.ADD then
        return input
    end
    for _, expr in ipairs(input.expressions) do
        local numpart, denpart = Integer.one(), Integer.one()
        if expr.operation == BinaryOperation.POW and expr.expressions[2]:type() == Integer and expr.expressions[2] < Integer.zero() then
            denpart = denpart*expr.expressions[1] ^ expr.expressions[2]:neg()
            for index,term in ipairs(den) do
                if expr.expressions[1] == den[index] then
                    if expr.expressions[2]:neg() > mul[index] then
                        mul[index] = expr.expressions[2]:neg()
                        goto continue
                    else
                        goto continue
                    end
                end
            end
            table.insert(den,expr.expressions[1])
            table.insert(mul,expr.expressions[2]:neg())
            ::continue::
        end
        if expr.operation == BinaryOperation.MUL then
            for _,subexpr in ipairs(expr.expressions) do
                if subexpr.operation == BinaryOperation.POW and subexpr.expressions[2]:type() == Integer and subexpr.expressions[2] < Integer.zero() then
                    denpart = denpart*subexpr.expressions[1] ^ subexpr.expressions[2]:neg()
                    for index,term in ipairs(den) do
                        if subexpr.expressions[1] == den[index] then
                            if subexpr.expressions[2]:neg() > mul[index] then
                                mul[index] = subexpr.expressions[2]:neg()
                                goto continue
                            else
                                goto continue
                            end
                        end
                    end
                    table.insert(den,subexpr.expressions[1])
                    table.insert(mul,subexpr.expressions[2]:neg())
                    ::continue::
                else
                    numpart = numpart*subexpr
                end
            end
        end
        if expr.operation ~= BinaryOperation.POW and expr.operation ~= BinaryOperation.MUL then
            numpart = expr
        end
        table.insert(num,numpart)
        table.insert(aux,denpart)
    end
    local denominator = Integer.one()
    local numerator   = Integer.zero()
    for index,expr in ipairs(den) do
        denominator = denominator*den[index] ^ mul[index]
    end
    denominator = denominator:autosimplify()
    for index,expr in ipairs(num) do
        local uncommon = denominator/aux[index]
        uncommon = uncommon:factor():simplify()
        numerator = numerator + expr*uncommon
    end
    numerator = numerator:simplify():factor()
    if denominator == Integer.one() then
        return numerator
    else
        return numerator/denominator
    end
end

--- @param collect Expression
--- @return Expression
function BinaryOperation:collect(collect)
    -- Constant expressions cannot be collected
    if collect:isconstant() then
        return self
    end

    -- Recusively collect subexpressions
    local results = {}
    for index, expression in ipairs(self:subexpressions()) do
        results[index] = expression:collect(collect)
    end
    local collected = BinaryOperation(self.operation, results)

    if not (collected.operation == BinaryOperation.ADD) then
        return collected:autosimplify()
    end

    local coefficients = {}

    -- TODO: Add an expression map class
    setmetatable(coefficients, {__index =
                                        function(table, key)
                                            local out = rawget(table, tostring(key))
                                            return out or Integer.zero()
                                        end,
                                __newindex =
                                        function (table, key, value)
                                            rawset(table, tostring(key), value)
                                        end
    })

    -- Finds all instances of a constant power of the expression to be collected, and maps each power to all terms it is multiplied by
    for _, expression in ipairs(collected:subexpressions()) do
        if expression == collect then
            coefficients[Integer.one()] = coefficients[Integer.one()] + Integer.one()
        elseif expression.operation == BinaryOperation.POW and expression:subexpressions()[1] == collect and expression:subexpressions()[2]:isconstant() then
            coefficients[expression:subexpressions()[2]] = coefficients[expression:subexpressions()[2]] + Integer.one()
        elseif collect:type() == BinaryOperation and collect.operation == BinaryOperation.POW and
                expression.operation == BinaryOperation.POW and expression:subexpressions()[1] == collect:subexpressions()[1] then
            -- Handle the fact that autosimplify turns (a^x^n -> a^(xn)), this is needed if the term to collect is itself an exponential
            local power = (expression:subexpressions()[2] / collect:subexpressions()[2]):autosimplify()
            if power:isconstant() then
                coefficients[power] = coefficients[power] + Integer.one()
            else
                coefficients[Integer.zero()] = coefficients[Integer.zero()] + expression
            end
        elseif expression.operation == BinaryOperation.MUL then
            local varpart
            local coeffpart = Integer.one()
            for _, term in ipairs(expression:subexpressions()) do
                if term == collect then
                    varpart = Integer.one()
                elseif (term.operation == BinaryOperation.POW and term:subexpressions()[1] == collect and term:subexpressions()[2]:isconstant()) then
                    varpart = term:subexpressions()[2]
                elseif collect:type() == BinaryOperation and collect.operation == BinaryOperation.POW and
                        term.operation == BinaryOperation.POW and term:subexpressions()[1] == collect:subexpressions()[1] then
                    local power = (term:subexpressions()[2] / collect:subexpressions()[2]):autosimplify()
                    if power:isconstant() then
                        varpart = power
                    end
                else
                    coeffpart = coeffpart * term
                end
            end
            if varpart then
                coefficients[varpart] = coefficients[varpart] + coeffpart
            else
                coefficients[Integer.zero()] = coefficients[Integer.zero()] + expression
            end
        else
            coefficients[Integer.zero()] = coefficients[Integer.zero()] + expression
        end


    end

    local out = Integer.zero()
    for index, value in pairs(coefficients) do
        out = out + collect ^ Rational.fromstring(index) * value
    end

    return out:autosimplify()
end

--- @param other Expression
--- @return boolean
function BinaryOperation:order(other)
    if other:isconstant() then
        return false
    end

    if other:isatomic() then
        if self.operation == BinaryOperation.POW then
            return self:order(BinaryOperation(BinaryOperation.POW, {other, Integer.one()}))
        end

        if self.operation == BinaryOperation.MUL then
            return self:order(BinaryOperation(BinaryOperation.MUL, {other}))
        end

        if self.operation == BinaryOperation.ADD then
            return self:order(BinaryOperation(BinaryOperation.ADD, {other}))
        end
    end

    if self.operation == BinaryOperation.POW and other.operation == BinaryOperation.POW then
        if self.expressions[1] ~= other.expressions[1] then
            return self.expressions[1]:order(other.expressions[1])
        end
        return self.expressions[2]:order(other.expressions[2])
    end

    if (self.operation == BinaryOperation.MUL and other.operation == BinaryOperation.MUL) or
    (self.operation == BinaryOperation.ADD and other.operation == BinaryOperation.ADD) then
        local k = 0
        while #self.expressions - k > 0 and #other.expressions - k > 0 do
            if self.expressions[#self.expressions - k] ~= other.expressions[#other.expressions - k] then
                return self.expressions[#self.expressions - k]:order(other.expressions[#other.expressions - k])
            end
            k = k + 1
        end
        return #self.expressions < #other.expressions
    end

    if (self.operation == BinaryOperation.MUL) and (other.operation == BinaryOperation.POW or other.operation == BinaryOperation.ADD) then
        return self:order(BinaryOperation(BinaryOperation.MUL, {other}))
    end

    if (self.operation == BinaryOperation.POW) and (other.operation == BinaryOperation.MUL) then
        return BinaryOperation(BinaryOperation.MUL, {self}):order(other)
    end

    if (self.operation == BinaryOperation.POW) and (other.operation == BinaryOperation.ADD) then
        return self:order(BinaryOperation(BinaryOperation.POW, {other, Integer.one()}))
    end

    if (self.operation == BinaryOperation.ADD) and (other.operation == BinaryOperation.MUL) then
        return BinaryOperation(BinaryOperation.MUL, {self}):order(other)
    end

    if (self.operation == BinaryOperation.ADD) and (other.operation == BinaryOperation.POW) then
        return BinaryOperation(BinaryOperation.POW, {self, Integer.one()}):order(other)
    end

    if other:type() == FunctionExpression or other:type() == TrigExpression or other:type() == Logarithm then
        if self.operation == BinaryOperation.ADD or self.operation == BinaryOperation.MUL then
            return self:order(BinaryOperation(self.operation, {other}))
        end

        if self.operation == BinaryOperation.POW then
            return self:order(other^Integer.one())
        end
    end

    return true
end

--- Returns whether the binary operation is commutative.
--- @return boolean
function BinaryOperation:iscommutative()
    error("Called unimplemented method: iscommutative()")
end

--- @return PolynomialRing, boolean
function BinaryOperation:topolynomial()
    local addexp = self
    if not self.operation or self.operation ~= BinaryOperation.ADD then
        addexp = BinaryOperation(BinaryOperation.ADD, {self})
    end

    local poly = {}
    local degree = 0
    local symbol
    for _, expression in ipairs(addexp.expressions) do
        local coefficient
        local sym
        local power
        -- Expressions of the form c
        if expression:isconstant() then
            coefficient = expression
            power = 0
        -- Expressions of the form x
        elseif expression:type() == SymbolExpression then
            coefficient = Integer.one()
            sym = expression.symbol
            power = 1
        -- Expressions of the form c*x
        elseif expression.operation and expression.operation == BinaryOperation.MUL and #expression.expressions == 2
                    and expression.expressions[1]:isconstant() and expression.expressions[2]:type() == SymbolExpression then

            coefficient = expression.expressions[1]
            sym = expression.expressions[2].symbol
            power = 1
        -- Expressions of the form c*x^n (totally not confusing)
        elseif expression.operation and expression.operation == BinaryOperation.MUL and #expression.expressions == 2
                    and expression.expressions[1]:isconstant() and expression.expressions[2].operation and
                    expression.expressions[2].operation == BinaryOperation.POW and #expression.expressions[2].expressions == 2
                    and expression.expressions[2].expressions[1]:type() == SymbolExpression and expression.expressions[2].expressions[2].getring
                    and expression.expressions[2].expressions[2]:getring() == Integer.getring() and expression.expressions[2].expressions[2] > Integer.zero() then

            coefficient = expression.expressions[1]
            sym = expression.expressions[2].expressions[1].symbol
            power = expression.expressions[2].expressions[2]:asnumber()
        -- Expressions of the form x^n
        elseif expression.operation and expression.operation == BinaryOperation.POW and #expression.expressions == 2
                    and expression.expressions[1]:type() == SymbolExpression and expression.expressions[2].getring
                    and expression.expressions[2]:getring() == Integer.getring() and expression.expressions[2] > Integer.zero() then

            coefficient = Integer.one()
            sym = expression.expressions[1].symbol
            power = expression.expressions[2]:asnumber()
        else
            return self, false
        end

        if symbol and sym and symbol ~= sym then
            return self, false
        end
        if not symbol then
            symbol = sym
        end
        poly[power + 1] = coefficient
        if power > degree then
            degree = power
        end
    end

    for i = 1,degree+1 do
        poly[i] = poly[i] or Integer.zero()
    end

    return PolynomialRing(poly, symbol), true
end

function BinaryOperation:tolatex()
    if self.operation == BinaryOperation.POW then
        if self.expressions[2]:type() == Integer and self.expressions[2] < Integer.zero() then
            local base = self.expressions[1]
            local exponent = self.expressions[2]
            if exponent == Integer(-1) then
                return "\\frac{1}{" .. base:tolatex() .. "}"
            else
                if base:isatomic() then
                    return "\\frac{1}{" .. base:tolatex() .. "^{" .. exponent:neg():tolatex() .. "}}"
                else
                    return "\\frac{1}{\\left(" .. base:tolatex() .. "\\right)^{" .. exponent:neg():tolatex() .. "}}"
                end
            end
        end
        if self.expressions[1]:isatomic() then
            if self.expressions[2]:isconstant() and self.expressions[2]:getring() == Rational:getring() and self.expressions[2].numerator == Integer.one() then
                if self.expressions[2].denominator == Integer(2) then
                    return "\\sqrt{" .. self.expressions[1]:tolatex() .. '}'
                end
                return "\\sqrt[" .. self.expressions[2].denominator:tolatex() .. ']{' .. self.expressions[1]:tolatex() .. '}'
            end
            return self.expressions[1]:tolatex() .. '^{' .. self.expressions[2]:tolatex() .. '}'
        else
            if self.expressions[2]:isconstant() and self.expressions[2]:getring() == Rational:getring() and self.expressions[2].numerator == Integer.one() then
                if self.expressions[2].denominator == Integer(2) then
                    return "\\sqrt{" .. self.expressions[1]:tolatex() .. '}'
                end
                return "\\sqrt[" .. self.expressions[2].denominator:tolatex() .. ']{' .. self.expressions[1]:tolatex() .. '}'
            end
            return "\\left(" .. self.expressions[1]:tolatex() .. "\\right)" .. '^{' .. self.expressions[2]:tolatex() .. '}'
        end
    end
    if self.operation == BinaryOperation.MUL then
        local sign = ''
        local out = ''
        local denom = ''
        if self:autosimplify():isconstant() then
            for index, expression in ipairs(self.expressions) do
                if index == 1 then
                    out = out .. expression:tolatex()
                else
                    out = out .. "\\cdot " .. expression:tolatex()
                end
            end
            return out
        end
        if #self.expressions == 2 and self.expressions[2]:type() == BinaryOperation and self.expressions[2].operation == BinaryOperation.POW and self.expressions[2].expressions[2] == -Integer.one() then
            out = '\\frac{' .. self.expressions[1]:tolatex() .. '}{' .. self.expressions[2].expressions[1]:tolatex() .. '}'
            return out
        end
        for _, expression in ipairs(self.expressions) do
            if expression:type() == BinaryOperation then
                if expression.operation == BinaryOperation.POW and expression.expressions[2]:isconstant() and expression.expressions[2] < Integer.zero() then
                    local reversed = (Integer.one() / expression):autosimplify()
                    if reversed.operation == BinaryOperation.ADD or expression.operation == BinaryOperation.SUB then
                        denom = denom .. '\\left('.. reversed:tolatex() .. '\\right)'
                    else
                        denom = denom .. reversed:tolatex()
                    end
                elseif expression.operation == BinaryOperation.ADD or expression.operation == BinaryOperation.SUB then
                    out = out .. '\\left(' .. expression:tolatex() .. '\\right)'
                else
                    out = out .. expression:tolatex()
                end
            else
                if expression == Integer(-1) then
                    out = out .. '-'
                elseif expression:type() == Rational and expression.numerator == Integer.one() then
                    denom = denom .. expression.denominator:tolatex()
                elseif expression:type() == Rational and expression.numerator == Integer(-1) then
                    out = out .. '-'
                    denom = denom .. expression.denominator:tolatex()
                elseif expression:type() == Rational then
                    out = out .. expression.numerator:tolatex()
                    denom = denom .. expression.denominator:tolatex()
                else
                    out = out .. expression:tolatex()
                end
            end
        end
        if string.sub(out,1,1) == '-' then
            sign = '-'
            out = string.sub(out,2,-1)
        end
        if denom ~= '' and out == '' then
            return sign .. '\\frac{' .. '1' .. '}{' .. denom .. '}'
        end
        if denom ~= '' then
            return sign .. '\\frac{' .. out .. '}{' .. denom .. '}'
        end
        return sign..out
    end
    if self.operation == BinaryOperation.ADD then
        local out = ''
        for index, expression in ipairs(self.expressions) do
            out = out .. expression:tolatex()
            if self.expressions[index + 1] and string.sub(self.expressions[index + 1]:tolatex(), 1, 1) ~= "-" then
                out = out .. '+'
            end
        end
        return out
    end
    if self.operation == BinaryOperation.DIV then
        return '\\frac{' .. self.expressions[1]:tolatex() .. '}{' .. self.expressions[2]:tolatex() .. '}'
    end
    if self.operation == BinaryOperation.SUB then
        local out = ''
        if not self.expressions[2] then
            if not self.expressions[1]:isatomic() then
                out = '-\\left(' .. self.expressions[1]:tolatex() .. '\\right)'
            else
                out = '-' .. self.expressions[1]:tolatex()
            end
        else
            for index, expression in ipairs(self.expressions) do
                if expression.operation and (expression.operation == BinaryOperation.ADD or expression.operation == BinaryOperation.SUB) and index >1 then
                    out = out .. "\\left(" .. expression:tolatex() .. "\\right)"
                else
                    out = out .. expression:tolatex()
                end
                if self.expressions[index + 1] then
                    out = out .. '-'
                end
            end
        end
        return out
    end
    return self
end

-----------------
-- Inheritance --
-----------------

__BinaryOperation.__index = CompoundExpression
__BinaryOperation.__call = BinaryOperation.new
BinaryOperation = setmetatable(BinaryOperation, __BinaryOperation)

----------------------
-- Static constants --
----------------------

BinaryOperation.ADD = function(a, b)
    return a + b
end

BinaryOperation.SUB = function(a, b)
    return a - b
end

BinaryOperation.MUL = function(a, b)
    return a * b
end

BinaryOperation.DIV = function(a, b)
    return a / b
end

BinaryOperation.IDIV = function(a, b)
    return a // b
end

BinaryOperation.MOD = function(a, b)
    return a % b
end

BinaryOperation.POW = function(a, b)
    return a ^ b
end

BinaryOperation.DEFAULT_NAMES = {
    [BinaryOperation.ADD] = "+",
    [BinaryOperation.SUB] = "-",
    [BinaryOperation.MUL] = "*",
    [BinaryOperation.DIV] = "/",
    [BinaryOperation.IDIV] = "//",
    [BinaryOperation.MOD] = "%",
    [BinaryOperation.POW] = "^"
}

BinaryOperation.COMMUTATIVITY = {
    [BinaryOperation.ADD] = true,
    [BinaryOperation.SUB] = false,
    [BinaryOperation.MUL] = true,
    [BinaryOperation.DIV] = false,
    [BinaryOperation.IDIV] = false,
    [BinaryOperation.MOD] = false,
    [BinaryOperation.POW] = false
}

BinaryOperation.ADDEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.ADD, expressions, name)
end

BinaryOperation.SUBEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.SUB, expressions, name)
end

BinaryOperation.MULEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.MUL, expressions, name)
end

BinaryOperation.DIVEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.DIV, expressions, name)
end

BinaryOperation.IDIVEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.IDIV, expressions, name)
end

BinaryOperation.MODEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.MOD, expressions, name)
end

BinaryOperation.POWEXP = function(expressions, name)
    return BinaryOperation(BinaryOperation.POW, expressions, name)
end