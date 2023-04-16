--- @class RootExpression
--- An expression that represents the solutions to expression = 0.
--- @field expression Expression
RootExpression = {}
local __RootExpression = {}

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new root expression with the given expression.
--- @param expression Expression
--- @return RootExpression
function RootExpression:new(expression)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    o.expression = Copy(expression)

    __o.__index = RootExpression
    __o.__tostring = function(a)
        return 'Root Of: (' .. tostring(a.expression) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == RootExpression then
            return false
        end
        return a.expression == b.expression
    end
    o = setmetatable(o, __o)

    return o
end

--- @return Expression
function RootExpression:autosimplify(subpart)
    local simplified = self.expression:autosimplify()
    local simplified, ispoly = simplified:topolynomial()

    if simplified:isconstant() then
        -- 0 = 0 is always true (obviously).
        return simplified == simplified:zero()
    end

    if ispoly then
        if simplified.degree == Integer.zero() then
            return simplified == simplified:zero()
        end
        if simplified.degree == Integer.one() then
            return {-simplified.coefficients[0] / simplified.coefficients[1]}
        end
        if simplified.degree == Integer(2) then
            local a = simplified.coefficients[2]
            local b = simplified.coefficients[1]
            local c = simplified.coefficients[0]
            -- This is a hack until we can get more expression manipulation working, but that's okay.
            if subpart then
                c = (c - subpart):autosimplify()
            end
            return {((-b + sqrt(b^Integer(2) - Integer(4) * a * c)) / (Integer(2) * a)):autosimplify(),
                    ((-b - sqrt(b^Integer(2) - Integer(4) * a * c)) / (Integer(2) * a)):autosimplify()}
        end
        if simplified.degree == Integer(3) then
            local a = simplified.coefficients[3]
            local b = simplified.coefficients[2]
            local c = simplified.coefficients[1]
            local d = simplified.coefficients[0]
            -- This is a hack until we can get more expression manipulation working, but that's okay.
            if subpart then
                d = (d - subpart):autosimplify()
            end

            local delta0 = (b^Integer(2) - Integer(3)*a*c):autosimplify()
            local delta1 = (Integer(2) * b^Integer(3) - Integer(9)*a*b*c+Integer(27)*a^Integer(2)*d):autosimplify()

            local C = sqrt((delta1 + sqrt(delta1 ^ Integer(2) - Integer(4) * delta0 ^ Integer(3))) / Integer(2), Integer(3)):autosimplify()

            if C == Integer.zero() then
                C = sqrt((delta1 - sqrt(delta1 ^ Integer(2) - Integer(4) * delta0 ^ Integer(3))) / Integer(2), Integer(3)):autosimplify()
            end

            if C == Integer.zero() then
                C = (-b/(Integer(3)*a)):autosimplify()
            end

            local eta = ((Integer(-1) + sqrt(Integer(-3))) / Integer(2)):autosimplify()

            return {((-Integer.one() / (Integer(3) * a)) * (b + C + delta0 / C)):autosimplify(),
                    ((-Integer.one() / (Integer(3) * a)) * (b + C*eta + delta0 / (C*eta))):autosimplify(),
                    ((-Integer.one() / (Integer(3) * a)) * (b + C*eta^Integer(2) + delta0 / (C*eta^Integer(2)))):autosimplify()}
        end
    end
    if ispoly then
        simplified = simplified:autosimplify()
    end
    if subpart then
        simplified = (simplified - subpart):autosimplify()
    end
    return {RootExpression(simplified)}
end

--- @return table<number, Expression>
function RootExpression:subexpressions()
    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return RootExpression
function RootExpression:setsubexpressions(subexpressions)
    return RootExpression(subexpressions[1])
end

--- @param other Expression
--- @return boolean
function RootExpression:order(other)
    --- TODO: Fix ordering on new expression types
    if other:type() ~= RootExpression then
        return false
    end

    return self.expression:order(other.expression)
end

--- @return string
function RootExpression:tolatex()
    return '\\operatorname{RootOf}\\left(' .. self.expression:tolatex() .. '\\right)'
end

-----------------
-- Inheritance --
-----------------
__RootExpression.__index = CompoundExpression
__RootExpression.__call = RootExpression.new
RootExpression = setmetatable(RootExpression, __RootExpression)