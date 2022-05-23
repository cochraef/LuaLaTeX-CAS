--- @class SqrtExpression
--- An expression that represents the solutions to expression = 0.
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
    if not self.expression:isconstant() then 
        return SqrtExpression(self.expression:autosimplify(),self.root)
    end

    

    if self.expression:type() == Integer then 
        if self.expression == Integer.one() then
            return Integer.one()
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
        return BinaryOperation(BinaryOperation.MUL,{coeff,SqrtExpression(expression,root)})
    end
    ::stop::
    return self
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