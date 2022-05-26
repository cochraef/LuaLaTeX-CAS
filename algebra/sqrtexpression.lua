--- @class SqrtExpression
--- An expression that represents the positive real solution to x^n = a where n is a positive integer and a is constant.
--- @field expression Expression
SqrtExpression = {}
__SqrtExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new sqrt expression with the given expression.
--- @param expression Expression
--- @param integer Integer
--- @return SqrtExpression
function SqrtExpression:new(expression, root)
    root = root or Integer(2)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.expression = Copy(expression)
    o.root = root

    __o.__index = SqrtExpression
    __o.__tostring = function(a)
        return 'sqrt(' .. tostring(a.expression) .. ',' .. tostring(a.root) .. ')'
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
    if other:isconstant() then
        return false
    end

    if not (other:isconstant() or other:type() == SqrtExpression) then 
        return true
    end

    return self.expression:order(other.expression)
end

function SqrtExpression:autosimplify()
    if self.root == Integer.one() then 
        return self.expression:autosimplify()
    end

    if self.root:type() == Rational then 
        return SqrtExpression(self.expression ^ self.root.denominator, self.root.numerator):autosimplify()
    end

    if not self.root:isconstant() then 
        return BinaryOperation(BinaryOperation.POW,{self.expression,Integer.one() / self.root}):autosimplify()
    end

    if not self.expression:isconstant() then 
        local expression = self.expression:autosimplify()
        if expression.operation == BinaryOperation.MUL and expression.expressions[1]:isconstant() then 
            local coeff = SqrtExpression(expression.expressions[1],self.root):autosimplify()
            expression.expressions[1] = BinaryOperation(BinaryOperation.MUL,{Integer.one()})
            expression = expression:autosimplify()
            local sqrtpart = SqrtExpression(expression,self.root):autosimplify()
            local result = coeff*sqrtpart
            return result:autosimplify()
        end
        return BinaryOperation(BinaryOperation.POW,{self.expression,Integer.one() / self.root}):autosimplify()
    end

    if self.expression:type() == Rational then 
        local result = SqrtExpression(self.expression.numerator,self.root):autosimplify() / SqrtExpression(self.expression.denominator,self.root):autosimplify()
        return result:autosimplify()
    end

    if self.expression:type() == Integer then
        if self.expression == Integer.zero() then 
            return Integer.zero()
        end
        if self.expression == Integer.one() then
            return Integer.one()
        end
        if self.expression < Integer.zero() and self.root == Integer(2) then 
            local result = SqrtExpression(self.expression:neg(),self.root):autosimplify()
            result = I*result
            return result:autosimplify()
        end
        local root = self.root
        local primes = self.expression:primefactorization()
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
        root = root / reduction
        for index, term in ipairs(primes.expressions) do 
            local prime      = term.expressions[1]
            local primepower = term.expressions[2] / reduction
            local coeffpower = primepower // root   
            coeffresult[index] = prime ^ coeffpower
            local exprpower  = primepower - coeffpower*root
            exprresult[index]  = prime ^ exprpower
        end
        expression = BinaryOperation(BinaryOperation.MUL,exprresult):autosimplify()
        coeff      = BinaryOperation(BinaryOperation.MUL,coeffresult):autosimplify()
        if coeff == Integer.one() then 
            if reduction == Integer.one() then 
                goto stop
            end
            return SqrtExpression(expression,root)
        end
        if root == Integer.one() then 
            return coeff
        end
        return BinaryOperation(BinaryOperation.MUL,{coeff,SqrtExpression(expression,root)}):autosimplify()
    end
    ::stop::

    if self.expression.operation == BinaryOperation.POW and self.expression.expressions[2]:type() == Integer then
        local exponent = self.expression.expressions[2]
        local root = self.root
            local power = exponent // root
            local newexponent = exponent / root - power
            local coeff = self.expression.expressions[1] ^ power
            coeff = coeff:autosimplify()
            if newexponent == Integer.zero() then
                return coeff
            else
                local num = newexponent.numerator
                local den = newexponent.denominator
                local expression = self.expression ^ num
                expression = expression:autosimplify()
                local result = coeff * SqrtExpression(expression,den)
                return result
            end
    end

    return SqrtExpression(self.expression:autosimplify(),self.root)
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