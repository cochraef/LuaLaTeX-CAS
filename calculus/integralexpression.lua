--- @class IntegralExpression
--- An expression for the integral of an expression.
--- @field symbol SymbolExpression
--- @field expression Expression
--- @field upper Expression
--- @field lower Expression

IntegralExpression = {}
__IntegralExpression = {}


--------------------------
-- Static functionality --
--------------------------

--- Recursive part of the indefinite integral operator. Returns nil if the expression could not be integrated.
--- We switch to funcional programming here because it is more natural.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.integrate(expression, symbol)
    local simplified = expression:autosimplify()

    local F = IntegralExpression.table(simplified, symbol)
    if F then return F end

    F = IntegralExpression.linearproperties(simplified, symbol)
    if F then return F end

    F = IntegralExpression.substitutionmethod(simplified, symbol)
    if F then return F end

    F = IntegralExpression.rationalfunction(simplified, symbol)
    if F then return F end

    F = IntegralExpression.partsmethod(simplified, symbol)
    if F then return F end

    F = IntegralExpression.eulersformula(simplified, symbol)
    if F then return F end

    local expanded = simplified:expand()
    if expression ~= expanded then
        F = IntegralExpression.integrate(expanded, symbol)
        if F then return F end
    end

    return nil
end

--- A table of basic integrals, returns nil if the integrand isn't in the table.
--- @param integrand Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.table(integrand, symbol)

    -- Constant integrand rule - int(c, x) = c*x
    if integrand:freeof(symbol) then
        return integrand*symbol
    end

    if integrand:type() == SymbolExpression then

        -- int(x, x) = x^2/2
        if integrand == symbol then
            return integrand ^ Integer(2) / Integer(2)
        end

        -- Constant integrand rule again
        return integrand*symbol
    end

    if integrand:type() == BinaryOperation then

        if integrand.operation == BinaryOperation.POW then
            -- int(1/x, x) = ln(x)
            if integrand.expressions[1] == symbol and integrand.expressions[2] == Integer(-1) then
                return LN(symbol)
            end

            -- Cavalieri's formula - int(x^n, x) = x^(n+1)/(n+1)
            if integrand.expressions[1] == symbol and integrand.expressions[2]:freeof(symbol) then
                return symbol ^ (integrand.expressions[2] + Integer.one()) / (integrand.expressions[2] + Integer.one())
            end

            -- int(n^x, x) = n^x/ln(n)
            if integrand.expressions[1]:freeof(symbol) and integrand.expressions[2] == symbol then
                return integrand / LN(integrand.expressions[1])
            end

            -- int(csc(x)^2, x) = -cot(x)
            if integrand.expressions[1] == CSC(symbol) and integrand.expressions[2] == Integer(2) then
                return -COT(symbol)
            end

            -- int(sec(x)^2, x) = tan(x)
            if integrand.expressions[1] == SEC(symbol) and integrand.expressions[2] == Integer(2) then
                return TAN(symbol)
            end
        end

        if integrand.operation == BinaryOperation.MUL and #integrand.expressions == 2 then
            -- int(tan(x)sec(x), x) = sec(x)
            if integrand.expressions[1] == TAN(symbol) and integrand.expressions[2] == SEC(symbol) then
                return SEC(symbol)
            end

            -- int(csc(x)cot(x), x) = -csc(x)
            if integrand.expressions[1] == CSC(symbol) and integrand.expressions[2] == COT(symbol) then
                return -CSC(symbol)
            end
        end

        return nil
    end

    if integrand:type() == Logarithm then
        -- int(log_n(x), x) = (x*ln(x)-x)/ln(n)
        if integrand.base:freeof(symbol) and integrand.expression == symbol then
            return (symbol * LN(symbol) - symbol) / LN(integrand.base)
        end

        return nil
    end

    if integrand:type() == TrigExpression then
        if integrand == SIN(symbol) then
            return -COS(symbol)
        end

        if integrand == COS(symbol) then
            return SIN(symbol)
        end

        if integrand == TAN(symbol) then
            return -LN(COS(symbol))
        end

        if integrand == CSC(symbol) then
            return -LN(CSC(symbol)+COT(symbol))
        end

        if integrand == SEC(symbol) then
            return LN(SEC(symbol) + TAN(symbol))
        end

        if integrand == COT(symbol) then
            return LN(SIN(symbol))
        end

        if integrand == ARCSIN(symbol) then
            return symbol*ARCSIN(symbol) + (1-symbol^(Integer(2)))^(Integer(1)/Integer(2))
        end

        if integrand == ARCCOS(symbol) then
            return symbol*ARCCOS(symbol) - (1-symbol^(Integer(2)))^(Integer(1)/Integer(2))
        end

        if integrand == ARCTAN(symbol) then
            return symbol*ARCTAN(symbol) - (Integer(1)/Integer(2))*LN(1+symbol^Integer(2))
        end

        if integrand == ARCCSC(symbol) then
            return symbol*ARCCSC(symbol) + LN(symbol*(1+(1-symbol^(Integer(-2)))^(Integer(1)/Integer(2))))
        end

        if integrand == ARCSEC(symbol) then
            return symbol*ARCSEC(symbol) - LN(symbol*(1+(1-symbol^(Integer(-2)))^(Integer(1)/Integer(2))))
        end

        if integrand == ARCCOT(symbol) then
            return symbol*ARCCOT(symbol) + (Integer(1)/Integer(2))*LN(1+symbol^Integer(2))
        end
    end

    return nil
end

--- Uses linearity to break up the integral and integrate each piece.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.linearproperties(expression, symbol)
    if expression:type() == BinaryOperation then
        if expression.operation == BinaryOperation.MUL then
            local freepart = Integer.one()
            local variablepart = Integer.one()
            for _, term in ipairs(expression.expressions) do
                if term:freeof(symbol) then
                   freepart = freepart*term
                else
                   variablepart = variablepart*term
                end
            end
            if freepart == Integer.one() then
                return nil
            end
            local F = IntegralExpression.integrate(variablepart, symbol)
            if F then
                return freepart*F
            end
            return nil
        end

        if expression.operation == BinaryOperation.ADD then
            local sum = Integer.zero()
            for _, term in ipairs(expression.expressions) do
                local F = IntegralExpression.integrate(term, symbol)
                if F then
                    sum = sum + F
                else
                    return nil
                end

            end
            return sum
        end
    end

    return nil
end

--- Attempts u-substitutions to evaluate the integral.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.substitutionmethod(expression, symbol)
    local P = IntegralExpression.trialsubstitutions(expression)
    local F = nil
    local i = 1;

    while not F and i <= #P do
        local g = P[i]
        if g ~= symbol and not g:freeof(symbol) then
            local subsymbol = SymbolExpression("u")
            if symbol == SymbolExpression("u") then
                subsymbol = SymbolExpression("v")
            end
            local u = (expression / (DerivativeExpression(g, symbol))):autosimplify()
            u = u:substitute({[g]=subsymbol}):autosimplify()
            if u:freeof(symbol) then
                local FF = IntegralExpression.integrate(u, subsymbol)
                if FF then
                    F = FF:substitute({[subsymbol]=g})
                end
            end
        end
        i = i + 1
    end

    return F
end

--- Generates a list of possible u-substitutions to attempt
--- @param expression Expression
--- @return table<number, Expression>
function IntegralExpression.trialsubstitutions(expression)
    local substitutions = {}

    -- Recursive part - evaluates each term in a product.
    if expression:type() == BinaryOperation and expression.operation == BinaryOperation.MUL then
        for _, term in ipairs(expression.expressions) do
            substitutions = JoinArrays(substitutions, IntegralExpression.trialsubstitutions(term))
        end
    end

    -- Function forms and arguments of function forms (includes a recursive part)
    if expression:type() == TrigExpression or expression:type() == Logarithm then
        substitutions[#substitutions+1] = expression
        substitutions[#substitutions+1] = expression.expression
        substitutions = JoinArrays(substitutions, IntegralExpression.trialsubstitutions(expression.expression))
    end

    -- Bases and exponents of powers
    if expression:type() == BinaryOperation and expression.operation == BinaryOperation.POW then
        -- Atomic expressions are technically valid substitutions, but they won't be useful
        if not expression.expressions[1]:isatomic() then
            substitutions[#substitutions+1] = expression.expressions[1]
        end
        if not expression.expressions[2]:isatomic() then
            substitutions[#substitutions+1] = expression.expressions[2]
        end
    end

    return substitutions
end


--- Uses Lazard, Rioboo, Rothstein, and Trager's method to integrate rational functions.
--- This is mostly to try to avoid factoring and finding the roots of the full denominator whenever possible.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.rationalfunction(expression, symbol)

    -- Type checking and conversion to polynomial type.
    local f, g, fstat, gstat
    if expression:type() == BinaryOperation and expression.operation == BinaryOperation.POW and expression.expressions[2] == Integer(-1) then
        g, gstat = expression.expressions[1]:topolynomial()
        if not gstat then
            return false
        end
        f = PolynomialRing({Integer.one()}, g.symbol)
    else
        if expression:type() ~= BinaryOperation or expression.operation ~= BinaryOperation.MUL or expression.expressions[3] then
            return nil
        end
        if expression.expressions[2]:type() == BinaryOperation and expression.expressions[2].operation == BinaryOperation.POW and expression.expressions[2].expressions[2] == Integer(-1) then
            if expression.expressions[1].topolynomial ~=nil and expression.expressions[2].expressions[1].topolynomial ~=nil then 
                f, fstat = expression.expressions[1]:topolynomial()
                g, gstat = expression.expressions[2].expressions[1]:topolynomial()
            end
        elseif expression.expressions[1]:type() == BinaryOperation and expression.expressions[1].operation == BinaryOperation.POW and expression.expressions[1].expressions[2] == Integer(-1) then
            if expression.expressions[2].topolynomial ~= nil and expression.expressions[1].expressions[1].topolynomial ~= nil then 
                f, fstat = expression.expressions[2]:topolynomial()
                g, gstat = expression.expressions[1].expressions[1]:topolynomial()
            end
        else
            return nil
        end

        if not fstat or not gstat or f.symbol ~= symbol.symbol or g.symbol ~= symbol.symbol then
        return nil
        end
    end

    -- Explicit handling of degree 1 over a binomial.
    do
        local disc =  g.coefficients[1]*g.coefficients[1]-Integer(4)*g.coefficients[2]*g.coefficients[0]
        if f == Integer.one() and g.degree == Integer(2) and disc < Integer.zero() then
            return Integer(2) * ARCTAN((Integer(2)*g.coefficients[2]*symbol+g.coefficients[1]) / (Integer(4)*g.coefficients[0]*g.coefficients[2]-g.coefficients[1] ^ Integer(2)) ^ (Integer(1)/Integer(2))) / (Integer(4)*g.coefficients[0]*g.coefficients[2]-g.coefficients[1] ^ Integer(2)) ^ (Integer(1)/Integer(2))
        end
    end

    -- If the polynomials are not relatively prime, divides out the common factors.
    local gcd = PolynomialRing.gcd(f, g)
    if gcd ~= Integer(1) then
        f, g = f // gcd, g // gcd
    end

    -- Seperates out the polynomial part and rational part and integrates the polynomial part.
    local q, h = f:divremainder(g)
    U = IntegralExpression.integrate(q, symbol)

    if h == Integer.zero() then
        return U
    end

    -- Performs partial fraction decomposition into square-free denominators on the rational part.
    local gg = g:squarefreefactorization()
    local pfd = PolynomialRing.partialfractions(h, g, gg)

    -- Hermite reduction.
    local V = Integer.zero()
    for _, term in ipairs(pfd.expressions) do
        local i = #term.expressions
        if i > 1 then
            for j = 1, i-1 do
                local n = term.expressions[j].expressions[1]
                local d = term.expressions[j].expressions[2].expressions[1]
                local p = term.expressions[j].expressions[2].expressions[2]

                local _, s, t = PolynomialRing.extendedgcd(d, d:derivative())
                s = s * n
                t = t * n
                V = V - t / ((p-Integer.one()) * BinaryOperation.POWEXP({d, p-Integer.one()}))
                term.expressions[j+1].expressions[1] = term.expressions[j+1].expressions[1] + s + t:derivative() / (p-Integer.one())
            end
        end
    end

    --Lazard-Rioboo-Trager method.
    local W = Integer.zero()
    for _, term in ipairs(pfd.expressions) do
        local a = term.expressions[#term.expressions].expressions[1]
        local b = term.expressions[1].expressions[2].expressions[1]
        local y = a - b:derivative() * PolynomialRing({Integer.zero(), Integer.one()}, "_")
        local r = PolynomialRing.resultant(b, y)


        local rr = r:squarefreefactorization()
        local remainders = PolynomialRing.monicgcdremainders(b, y)
        for pos, factor in ipairs(rr.expressions) do
            if pos > 1 then
                local re = factor.expressions[1]
                local e = factor.expressions[2]
                local roots = re:roots()
                for _, root in ipairs(roots) do
                    local w
                    for _, remainder in ipairs(remainders) do
                        if remainder.degree == e then
                            w = remainder
                            break
                        end
                    end
                    W = W + root*LN(w:substitute({[SymbolExpression("_")] = root}))
                end
            end
        end
    end

    return U + V + W
end


--- Attempts integration by parts for expressions with a polynomial factor in them. Other product expressions use Euler's formula.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.partsmethod(expression, symbol)
    if expression:type() ~= BinaryOperation or expression.operation ~= BinaryOperation.MUL then
        return
    end

    -- looking for ATE
    local u
    local vp = Integer.one()
    for _, exp in ipairs(expression:subexpressions()) do
        local _, bool = exp:topolynomial()
        if bool then
            u = exp
        else
            vp = vp * exp
        end
    end

    if not u or u:freeof(symbol) then
        return
    else
        vp = vp:autosimplify()
    end

    if (vp:type() == TrigExpression and (vp.name == "cos" or vp.name == "sin")) or (vp.operation == BinaryOperation.POW and vp.expressions[1]:isconstant()) then 
        local results = {}
        while u ~= Integer.zero() do
            local v = IntegralExpression.integrate(vp, symbol)
            if not v then
                return
            end
            local up = DerivativeExpression(u, symbol):autosimplify()
            results[#results+1] = u*v
            u = up
            vp = v
        end

        local result = results[#results]
        for i=#results-1,1,-1 do
            result = results[i] - result
        end

        return result:autosimplify()
    end
end

--- Attempts integration using Euler's formula and kind. Alternative for integration by parts for many expressions.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @return Expression|nil
function IntegralExpression.eulersformula(expression, symbol)
    local new = expression:substitute({[COS(symbol)] = (E^(I*symbol) + E^(-I*symbol))/Integer(2),
                                       [SIN(symbol)] = (E^(I*symbol) - E^(-I*symbol))/(Integer(2)*I)})

    if new == expression then
        return
    end

    local complexresult = IntegralExpression.integrate(new:expand(), symbol)

    if not complexresult then
        return
    end

    -- TODO: Proper complex number conversion methods
    local function converttorectangular(exp)
        exp = exp:expand()
        local results = {}
        for index, sub in ipairs(exp:subexpressions()) do
            results[index] = converttorectangular(sub)
        end
        local converted = exp:setsubexpressions(results)

        if converted.operation == BinaryOperation.POW and converted.expressions[1] == E and converted.expressions[2].operation == BinaryOperation.MUL then
            local ipart
            local rest = Integer.one()
            for _, factor in ipairs(converted.expressions[2]:subexpressions()) do
                if factor == I then
                    ipart = true
                else
                    rest = rest * factor
                end
            end
            if ipart then
                return (COS(rest) + I*SIN(rest)):autosimplify()
            end
        end

        return converted
    end

    return converttorectangular(complexresult:autosimplify()):expand():autosimplify()

end

----------------------------
-- Instance functionality --
----------------------------

--- Creates a new integral operation with the given symbol and expression.
--- @param expression Expression
--- @param symbol SymbolExpression
--- @param lower Expression
--- @param upper Expression
function IntegralExpression:new(expression, symbol, lower, upper)
    local o = {}
    local __o = Copy(__ExpressionOperations)

    if not symbol or not expression then
        error("Send wrong number of parameters: integrals must have a variable to integrate with respect to and an expression to integrate.")
    end

    if lower and not upper then
        error("Send wrong number of parameters: definite integrals must have an upper and a lower bound.")
    end

    o.symbol = symbol
    o.expression = Copy(expression)
    o.upper = Copy(upper)
    o.lower = Copy(lower)

    __o.__index = IntegralExpression
    __o.__tostring = function(a)
        if a:isdefinite() then
            return 'int(' .. tostring(a.expression) .. ", " .. tostring(a.symbol) .. ", ".. tostring(a.lower) .. ', ' .. tostring(a.upper) .. ')'
        end
        return 'int(' .. tostring(a.expression) .. ", " .. tostring(a.symbol) .. ')'
    end
    __o.__eq = function(a, b)
        -- This shouldn't be needed, since __eq should only fire if both metamethods have the same function, but for some reason Lua always rungs this anyway
        if not b:type() == IntegralExpression then
            return false
        end
        return a.symbol == b.symbol and a.expression == b.expression and a.upper == b.upper and a.lower == b.lower
    end
    o = setmetatable(o, __o)

    return o
end

--- Returns true if the integral is definite, i.e., has an upper and lower bound.
--- @return boolean
function IntegralExpression:isdefinite()
    return self.upper ~= nil
end

--- @return Expression
function IntegralExpression:autosimplify()
    local integrated = IntegralExpression.integrate(self.expression, self.symbol)

    -- Our expression could not be integrated.
    if not integrated then
        return self
    end

    if self:isdefinite() then
        return (integrated:substitute({[self.symbol]=self.upper}) - integrated:substitute({[self.symbol]=self.lower})):autosimplify()
    end

    return integrated:autosimplify()
end


--- @return table<number, Expression>
function IntegralExpression:subexpressions()
    if self:isdefinite() then
        return {self.expression, self.lower, self.upper}
    end

    return {self.expression}
end

--- @param subexpressions table<number, Expression>
--- @return IntegralExpression
function IntegralExpression:setsubexpressions(subexpressions)
    return IntegralExpression(subexpressions[1], self.symbol, subexpressions[2], subexpressions[3])
end

-- function IntegralExpression:freeof(symbol)
--     if self:isdefinite() then
--         return self.expression:freeof(symbol) and self.upper:freeof(symbol) and self.lower:freeof(symbol)
--     end
--     return self.expression:freeof(symbol)
-- end

-- -- Substitutes each expression for a new one.
-- function IntegralExpression:substitute(map)
--     for expression, replacement in pairs(map) do
--         if self == expression then
--             return replacement
--         end
--     end
--     -- Typically, we only perform substitution on autosimplified expressions, so this won't get called. May give strange results, i.e.,
--     -- substituting and then evaluating the integral may not return the same thing as evaluating the integral and then substituting.
--     if self:isdefinite() then
--         return IntegralExpression(self.symbol, self.expression:substitute(map), self.upper:substitute(map), self.lower:substitute(map))
--     end
--     return IntegralExpression(self.symbol, self.expression:substitute(map))
-- end

--- @param other Expression
--- @return boolean
function IntegralExpression:order(other)
    if other:type() ~= IntegralExpression then
        return false
    end

    if self.symbol ~= other.symbol then
        return self.symbol:order(other.symbol)
    end

    return self.expression:order(other.expression)
end

--- @return string
function IntegralExpression:tolatex()
    if self:isdefinite() then
        return '\\int_{' .. self.lower:tolatex() .. '}{' .. self.upper:tolatex() .. '}{' .. self.expression:tolatex() .. '\\hspace{1pt}d' .. self.symbol:tolatex() .. '}'
    end
    return '\\int{' .. self.expression:tolatex() .. '\\hspace{1pt}d' .. self.symbol:tolatex() .. '}'
end


-----------------
-- Inheritance --
-----------------
__IntegralExpression.__index = CompoundExpression
__IntegralExpression.__call = IntegralExpression.new
IntegralExpression = setmetatable(IntegralExpression, __IntegralExpression)

----------------------
-- Static constants --
----------------------
INT = function(symbol, expression, lower, upper)
    return IntegralExpression(symbol, expression, lower, upper)
end