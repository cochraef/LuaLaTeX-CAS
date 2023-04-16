--- @class SqrtExpression
--- An expression that represents the positive real solution to x^n = a where n is a positive integer and a is constant.
--- @field expression Expression
SqrtExpression = {}
local __SqrtExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new sqrt expression with the given expression.
--- @param expression Expression
--- @param root Integer
--- @return SqrtExpression
function SqrtExpression:new(expression, root)
    root = root or Integer(2)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.expression = Copy(expression)
    o.root = root

    __o.__index = SqrtExpression
    __o.__tostring = function(a)
        return tostring(a.expression) .. ' ^ (1/' .. tostring(a.root) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == SqrtExpression then
            return false
        end
        return a.expression == b.expression and a.root == b.root
    end
    o = setmetatable(o, __o)

    return o
end


--- @return table<number, Expression>
function SqrtExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return SqrtExpression
function SqrtExpression:setsubexpressions(subexpressions)
    return SqrtExpression(subexpressions[1], self.root)
end

--- @param other Expression
--- @return boolean
function SqrtExpression:order(other)
    return self:topower():order(other)
end

function SqrtExpression:topower()
    local exponent = BinaryOperation(BinaryOperation.DIV,{Integer.one(),self.root}):autosimplify()
    local base     = self.expression
    return BinaryOperation(BinaryOperation.POW,{base,exponent}):autosimplify()
end

function SqrtExpression:autosimplify()
    local expression = self.expression:autosimplify()
    local root = self.root:autosimplify()

    if root == Integer.one() then
        return expression
    end

    if root:type() == Rational then
        return SqrtExpression(BinaryOperation(BinaryOperation.POW,{expression,root.denominator}):autosimplify(), root.numerator):autosimplify()
    end

    if not root:isconstant() then
        return BinaryOperation(BinaryOperation.POW,{expression,Integer.one() / root}):autosimplify()
    end

    if not expression:isconstant() then
        if expression.operation == BinaryOperation.MUL and expression.expressions[1]:isconstant() then
            local coeff = SqrtExpression(expression.expressions[1],root):autosimplify()
            expression.expressions[1] = BinaryOperation(BinaryOperation.MUL,{Integer.one()})
            expression = expression:autosimplify()
            local sqrtpart = SqrtExpression(expression,root):autosimplify()
            local result = coeff*sqrtpart
            return result:autosimplify()
        end
        return BinaryOperation(BinaryOperation.POW,{expression,Integer.one() / root}):autosimplify()
    end

    if expression:type() == Rational then
        local result = BinaryOperation(BinaryOperation.MUL, {SqrtExpression(expression.numerator,root):autosimplify(),BinaryOperation(BinaryOperation.POW,{SqrtExpression(expression.denominator,root):autosimplify(),Integer(-1)})})
        return result:autosimplify()
    end

    if expression:type() == Integer then
        if expression == Integer.zero() then
            return Integer.zero()
        end
        if expression == Integer.one() then
            return Integer.one()
        end
        if expression < Integer.zero() then
            if root == Integer(2) then
                local result = SqrtExpression(expression:neg(),root):autosimplify()
                result = I*result
                return result:autosimplify()
            end
            if root % Integer(2) == Integer.one() then
                local result = SqrtExpression(expression:neg(),root):autosimplify()
                result = -result
                return result:autosimplify()
            end
        end
        local primes = expression:primefactorization()
        local coeffresult = {}
        local exprresult  = {}
        local reduction = root
        for _, term in ipairs(primes.expressions) do
            local primepower = term.expressions[2]
            reduction = Integer.gcd(primepower,reduction)
            if reduction == Integer.one() then
                goto skip
            end
        end
        ::skip::
        local newroot = root / reduction
        for index, term in ipairs(primes.expressions) do
            local prime      = term.expressions[1]
            local primepower = term.expressions[2] / reduction
            local coeffpower = primepower // newroot
            coeffresult[index] = prime ^ coeffpower
            local exprpower  = primepower - coeffpower*newroot
            exprresult[index]  = prime ^ exprpower
        end
        local newexpression = BinaryOperation(BinaryOperation.MUL,exprresult):autosimplify()
        local coeff      = BinaryOperation(BinaryOperation.MUL,coeffresult):autosimplify()
        if coeff == Integer.one() then
            if reduction == Integer.one() then
                goto stop
            end
            return SqrtExpression(newexpression,newroot)
        end
        if newroot == Integer.one() then
            return coeff
        end
        return BinaryOperation(BinaryOperation.MUL,{coeff,SqrtExpression(newexpression,newroot)}):autosimplify()
    end
    ::stop::

    if expression.operation == BinaryOperation.POW and expression.expressions[2]:type() == Integer then
        local exponent = expression.expressions[2]
            local power = exponent // root
            local newexponent = (exponent / root) - power
            local coeff = expression.expressions[1] ^ power
            coeff = coeff:evaluate()
            if newexponent == Integer.zero() then
                return coeff
            else
                local num = newexponent.numerator
                local den = newexponent.denominator
                local newexpression = expression ^ num
                newexpression = newexpression:autosimplify()
                local result = coeff * SqrtExpression(newexpression,den)
                return result
            end
    end

    return SqrtExpression(expression,root)
end

function SqrtExpression:tolatex()
    local printout = '\\sqrt'
    if self.root == Integer(2) then
        printout = printout .. '{' .. self.expression:tolatex() .. '}'
    else
        printout = printout .. '[' .. self.root:tolatex() .. ']' .. '{' .. self.expression:tolatex() .. '}'
    end
    return printout
end


-----------------
-- Inheritance --
-----------------
__SqrtExpression.__index = CompoundExpression
__SqrtExpression.__call = SqrtExpression.new
SqrtExpression = setmetatable(SqrtExpression, __SqrtExpression)

----------------------
-- Static constants --
----------------------

sqrt = function(expression, root)
    return SqrtExpression(expression, root)
end