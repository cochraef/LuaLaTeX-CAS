--- @class Equation
--- An expression that represents an equation of the form lhs = rhs.
--- @field lhs Expression
--- @field rhs Expression
Equation = {}
__Equation = {}

--------------------------
-- Static functionality --
--------------------------

--- Attempts to isolate the variable var in lhs by moving expressions to rhs. Ony performs a single step.
--- @param lhs Expression
--- @param rhs Expression
--- @param var SymbolExpression
--- @return Expression, Expression
function Equation.isolatelhs(lhs, rhs, var)
    if lhs:type() == BinaryOperation then
        local stay = Integer.zero()
        local switch = Integer.zero()
        if lhs.operation == BinaryOperation.ADD then
            for _, exp in ipairs(lhs:subexpressions()) do
                if exp:freeof(var) then
                    switch = switch + exp
                else
                    stay = stay + exp
                end
            end
            if switch == Integer.zero() then
                lhs = lhs:factor() -- TODO: Replace with collect for efficiency reasons
            else
                return stay:autosimplify(), (rhs - switch):autosimplify()
            end
        end
        if lhs.operation == BinaryOperation.MUL then
            stay = Integer.one()
            switch = Integer.one()
            for _, exp in ipairs(lhs:subexpressions()) do
                if exp:freeof(var) then
                    switch = switch * exp
                else
                    stay = stay * exp
                end
            end
            return stay:autosimplify(), (rhs / switch):autosimplify()
        end
        if lhs.operation == BinaryOperation.POW then
            if lhs:subexpressions()[1]:freeof(var) then
                return lhs:subexpressions()[2]:autosimplify(), Logarithm(lhs:subexpressions()[1], rhs):autosimplify()
            elseif lhs:subexpressions()[2]:freeof(var) then
                return lhs:subexpressions()[1]:autosimplify(), (rhs ^ (Integer.one()/lhs:subexpressions()[2])):autosimplify()
            end
        end
    elseif lhs:type() == Logarithm then
        if lhs.base:freeof(var) then
            return lhs.expression:autosimplify(), (lhs.base ^ rhs):autosimplify()
        elseif lhs.expression:freeof(var) then
            return lhs.base:autosimplify(), (lhs.expression ^ (Integer.one()/rhs)):autosimplify()
        end
    elseif lhs:type() == TrigExpression then
        return lhs.expression:autosimplify(), TrigExpression(TrigExpression.INVERSES[lhs.name], rhs):autosimplify()
    end

    return lhs, rhs
end

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new equation with the given expressions.
--- @param lhs Expression
--- @param rhs Expression
--- @return Equation
function Equation:new(lhs, rhs)

    if lhs:type() == Equation or rhs:type() == Equation then
        error("Sent parameter of wrong type: cannot nest equations or inequalities")
    end

    local o = {}
    local __o = Copy(__ExpressionOperations)     -- TODO: Ensure only one metatable for each instance of a class

    o.lhs = lhs
    o.rhs = rhs

    __o.__index = Equation
    __o.__tostring = function(a)
        return tostring(a.lhs) .. ' = ' .. tostring(a.rhs)
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always runs this anyway
        if not b:type() == Equation then
            return false
        end
        return a.lhs == b.lhs and a.rhs == b.rhs
    end
    o = setmetatable(o, __o)

    return o
end

--- Evaluation in this case just checks for structural equality, or guarenteed inequality in the case of constants
--- @return Equation|boolean
function Equation:evaluate()
    if self.lhs == self.rhs then
        return true -- TODO: Add Boolean Expressions
    end
    if self.lhs:isconstant() and self.rhs:isconstant() and self.lhs ~= self.rhs then
        return false
    end
    return self
end

--- @return Equation|boolean
function Equation:autosimplify()
    local lhs = self.lhs:autosimplify()
    local rhs = self.rhs:autosimplify()

    return Equation(lhs, rhs):evaluate()
end

--- @return table<number, Expression>
function Equation:subexpressions()
    return {self.lhs, self.rhs}
end

--- Attempts to solve the equation for a particular variable.
---  @param var SymbolExpression
--- @return Equation
function Equation:solvefor(var)
    local lhs = self.lhs
    local rhs = self.rhs

    if lhs:freeof(var) and rhs:freeof(var) then
        return self
    end

    -- Check for monovariate polynomial expressions
    local root = (lhs - rhs):autosimplify()
    local poly, status = root:expand():topolynomial()
    if status then
        -- TODO: Add Set expressions
        return Equation(var, poly:roots()[1])
    end

    local newlhs, newrhs = root, Integer(0)
    local oldlhs
    while newlhs ~= var and oldlhs ~= newlhs do
        oldlhs = newlhs
        newlhs, newrhs = Equation.isolatelhs(newlhs, newrhs, var)
    end

    return Equation(newlhs, newrhs)
end

--- @param subexpressions table<number, Expression>
--- @return Equation
function Equation:setsubexpressions(subexpressions)
    return Equation(subexpressions[1], subexpressions[2])
end

--- @param other Expression
--- @return boolean
function Equation:order(other)
    if other:isatomic() then
        return false
    end

    return self.lhs:order(other)
end

--- @return string
function Equation:tolatex()
    return self.lhs:tolatex() .. '=' .. self.rhs:tolatex()
end

-----------------
-- Inheritance --
-----------------
__Equation.__index = CompoundExpression
__Equation.__call = Equation.new
Equation = setmetatable(Equation, __Equation)