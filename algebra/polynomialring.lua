-- Represents an element of a polynomial ring
-- PolynomialRings have the following instance variables:
--      ring - the Ring used to generate the PolynomialRing
--      coefficients - A map from Integers to the Ring representing the coefficients in the polynomial
--      degree - the Integer degree of the PolynomialRing
--      symbol - the symbol adjoined to the ring to create the PolynomialRing
-- PolynomialRings have the following relationships with other classes:
--      PolynomialRings implement Rings
PolynomialRing = {}
__PolynomialRing = {}

-- Metatable for ring objects.
local __obj = {__index = PolynomialRing, __eq = function(a, b)
    return a["ring"] == b["ring"] and
            (a["child"] == b["child"] or a["child"] == nil or b["child"] == nil) and
            (a["symbol"] == b["symbol"] or a["child"] == nil or b["child"] == nil)
end, __tostring = function(a)
    if a.child and a.symbol then return tostring(a.child) .. "[" .. a.symbol .. "]" else return "(Generic Polynomial Ring)" end
end}

--------------------------
-- Static functionality --
--------------------------

-- Returns the immediate subrings of this ring.
function PolynomialRing.subrings(construction)
    local child = construction.child
    local subrings = {child}

    for i, subring in ipairs(child.subrings(child)) do
        local ring = Copy(construction)
        ring.child = subring
        subrings[i + 1] = ring
    end

    return subrings
end

-- Creates a new ring with the given symbol and child ring.
function PolynomialRing.makering(symbol, child)
    local t = {ring = PolynomialRing}
    t.symbol = symbol
    t.child = child
    t = setmetatable(t, __obj)
    return t
end

-- Shorthand constructor for a polynomial ring with integer or integer mod ring coefficients
function PolynomialRing.R(symbol, modulus)
    if modulus then
        return PolynomialRing.makering(symbol, IntegerModN.makering(modulus))
    end
    return PolynomialRing.makering(symbol, Integer.getring())
end

-- Returns the GCD of two polynomials in a ring, assuming both rings are euclidean domains
function PolynomialRing.gcd(a, b)
    if a.symbol ~= b.symbol then
        error("Cannot take the gcd of two polynomials with different symbols")
    end
    while b ~= Integer.zero() do
        a, b = b, a % b
    end
    return a // a:lc()
end

-- Returns the GCD of two polynomials in a ring, assuming both rings are euclidean domains
-- Also returns bezouts coefficients via extended gcd
function PolynomialRing.extendedgcd(a, b)
    local oldr, r  = a, b
    local olds, s  = Integer.one(), Integer.zero()
    local oldt, t  = Integer.zero(), Integer.one()
    while r ~= Integer.zero() do
        local q = oldr // r
        oldr, r  = r, oldr - q*r
        olds, s = s, olds - q*s
        oldt, t = t, oldt - q*t
    end
    return oldr // oldr:lc(), olds // oldr:lc(), oldt // oldr:lc()
end


----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the Euclidean operations each time
local __o = Copy(__EuclideanOperations)
__o.__index = PolynomialRing
__o.__tostring = function(a)
    local out = ""
    local loc = a.degree:asnumber()
    while loc >= 0 do
        if a.ring == PolynomialRing.getring() then
            out = out .. "(" .. tostring(a.coefficients[loc]) .. ")" .. a.symbol .. "^" .. tostring(math.floor(loc)) .. "+"
        else
            out = out .. tostring(a.coefficients[loc]) .. a.symbol .. "^" .. tostring(math.floor(loc)) .. "+"
        end
        loc = loc - 1
    end
    return string.sub(out, 1, string.len(out) - 1)
end

-- Creates a new polynomial ring given an array of coefficients and a symbol
function PolynomialRing:new(coefficients, symbol, degree)
    local o = {}
    o = setmetatable(o, __o)

    if type(coefficients) ~= "table" then
        error("Sent parameter of wrong type: Coefficients must be in an array")
    end
    o.coefficients = {}
    o.degree = degree or Integer(-1)

    if type(symbol) ~= "string" then
        error("Symbol must be a string")
    end
    o.symbol = symbol

    -- Determines what ring the polynomial ring should have as its child
    for index, coefficient in pairs(coefficients) do
        if type(index) ~= "number" then
            error("Sent parameter of wrong type: Coefficients must be in an array")
        end
        if not coefficient.getring then
            error("Sent parameter of wrong type: Coefficients must be elements of a ring")
        end
        if not o.ring then
            o.ring = coefficient:getring()
        else
            local newring = coefficient:getring()
            local combinedring = Ring.resultantring(o.ring, newring)
            if combinedring == newring then
                o.ring = newring
            elseif not o.ring == combinedring then
                error("Sent parameter of wrong type: Coefficients must all be part of the same ring")
            end
        end
    end

    if not coefficients[0] then
        -- Constructs the coefficients when a new polynomial is instantiated as an array
        for index, coefficient in ipairs(coefficients) do
            o.coefficients[index - 1] = coefficient
            o.degree = o.degree + Integer.one()
        end
    else
        -- Constructs the coefficients from an existing polynomial of coefficients
        local loc = o.degree:asnumber()
        while loc > 0 do
            if not coefficients[loc] or coefficients[loc] == coefficients[loc]:zero() then
                o.degree = o.degree - Integer.one()
            else
                break
            end
            loc = loc - 1
        end

        while loc >= 0 do
            o.coefficients[loc] = coefficients[loc]
            loc = loc - 1
        end
    end

    -- Each value of the polynomial greater than its degree is implicitly zero
    o.coefficients = setmetatable(o.coefficients, {__index = function (table, key)
        return o:zeroc()
    end})
    return o
end

-- Returns the ring this object is an element of
function PolynomialRing:getring()
    local t = {ring = PolynomialRing}
    if self then
        t.child = self.ring
        t.symbol = self.symbol
    end
    t = setmetatable(t, __obj)
    return t
end

-- Explicitly converts this element to an element of another ring
function PolynomialRing:inring(ring)

    -- Faster equality check
    if ring == self:getring() then
        return self
    end

    if ring.symbol == self.symbol then
        local out = {}
        for i = 0, self.degree:asnumber() do
            out[i + 1] = self.coefficients[i]:inring(ring.child)
        end
        return PolynomialRing(out, self.symbol)
    end

    if ring == PolynomialRing:getring() then
        return PolynomialRing({self:inring(ring.child)}, ring.symbol)
    end

    error("Unable to convert element to proper ring.")
end


-- Returns whether the ring is commutative
function PolynomialRing:isCommutative()
    return true
end

function PolynomialRing:add(b)
    local larger

    if self.degree > b.degree then
        larger = self
    else
        larger = b
    end

    local new = {}
    local loc = 0
    while loc <= larger.degree:asnumber() do
        new[loc] = self.coefficients[loc] + b.coefficients[loc]
        loc = loc + 1
    end

    return PolynomialRing(new, self.symbol, larger.degree)
end

function PolynomialRing:neg()
    local new = {}
    local loc = 0
    while loc <= self.degree:asnumber() do
        new[loc] = -self.coefficients[loc]
        loc = loc + 1
    end
    return PolynomialRing(new, self.symbol, self.degree)
end

function PolynomialRing:mul(b)
    -- Grade-school multiplication is actually faster up to a very large polynomial size due to Lua's overhead.
    local new = {}

    local sd = self.degree:asnumber()
    local bd = b.degree:asnumber()

    for i = 0, sd+bd do
        new[i] = self:zeroc()
        for j = math.max(0, i-bd), math.min(sd, i) do
            new[i] = new[i] + self.coefficients[j]*b.coefficients[i-j]
        end
    end
    return PolynomialRing(new, self.symbol, self.degree + b.degree)
    -- return PolynomialRing(PolynomialRing.mul_rec(self.coefficients, b.coefficients), self.symbol, self.degree + b.degree)
end

-- Performs Karatsuba multiplication without constructing new polynomials recursively
function PolynomialRing.mul_rec(a, b)
    if #a==0 and #b==0 then
        return {[0]=a[0] * b[0], [1]=Integer.zero()}
    end

    local k = Integer.ceillog(Integer.max(Integer(#a), Integer(#b)) + Integer.one(), Integer(2))
    local n = Integer(2) ^ k
    local m = n / Integer(2)
    local nn = n:asnumber()
    local mn = m:asnumber()

    local a0, a1, b0, b1 = {}, {}, {}, {}

    for e = 0, mn - 1 do
        a0[e] = a[e] or Integer.zero()
        a1[e] = a[e + mn] or Integer.zero()
        b0[e] = b[e] or Integer.zero()
        b1[e] = b[e + mn] or Integer.zero()
    end

    local p1 = PolynomialRing.mul_rec(a1, b1)
    local p2a = Copy(a0)
    local p2b = Copy(b0)
    for e = 0, mn - 1 do
        p2a[e] = p2a[e] + a1[e]
        p2b[e] = p2b[e] + b1[e]
    end
    local p2 = PolynomialRing.mul_rec(p2a, p2b)
    local p3 = PolynomialRing.mul_rec(a0, b0)
    local r = {}
    for e = 0, mn - 1 do
        p2[e] = p2[e] - p1[e] - p3[e]
        r[e] = p3[e]
        r[e + mn] = p2[e]
        r[e + nn] = p1[e]
    end
    for e = mn, nn - 1 do
        p2[e] = p2[e] - p1[e] - p3[e]
        r[e] = r[e] + p3[e]
        r[e + mn] = r[e + mn] + p2[e]
        r[e + nn] = p1[e]
    end

    return r
end

-- Uses synthetic division
function PolynomialRing:divremainder(b)
    local n, m = self.degree:asnumber(), b.degree:asnumber()

    if m > n then
        return self:zero(), self
    end

    local o = Copy(self.coefficients)
    local lc = b:lc()
    for i = n, m, -1 do
        o[i] = o[i] / lc

        if o[i] ~= self:zeroc() then
            for j = 1, m do
                o[i-j] = o[i-j] - b.coefficients[m - j] * o[i]
            end
        end
    end

    local q = {}
    local r = {}
    for i = 0, m-1 do
        r[i] = o[i]
    end

    r[0] = r[0] or self:zeroc()

    for i = m, #o do
        q[i - m] = o[i]
    end

    return PolynomialRing(q, self.symbol, self.degree), PolynomialRing(r, self.symbol, b.degree-Integer.one())
end

-- Polynomial rings are never fields, but when dividing by a polynomial by a constant we may want to use / instead of //
function PolynomialRing:div(b)
    return self:divremainder(b)
end

function PolynomialRing:zero()
    return self.coefficients[0]:zero():inring(self:getring())
end

function PolynomialRing:zeroc()
    return self.coefficients[0]:zero()
end

function PolynomialRing:one()
    return self.coefficients[0]:one():inring(self:getring())
end

function PolynomialRing:onec()
    return self.coefficients[0]:one()
end

function PolynomialRing:eq(b)
    for i=0,math.max(self.degree:asnumber(), b.degree:asnumber()) do
        if self.coefficients[i] ~= b.coefficients[i] then
            return false
        end
    end
    return true
end

-- Returns the leading coefficient of this polynomial
function PolynomialRing:lc()
    return self.coefficients[self.degree:asnumber()]
end

-- Polynomials can not generally be evaluated to a concrete number.
function PolynomialRing:isevaluatable()
    return false
end

-- Given a table mapping variables to expressions, replaces each variable with a new expressions
function PolynomialRing:substitute(variables)
    if type(variables) ~= "table" then
        error("Sent parameter of wrong type: variables must be a table")
    end

    for index, expression in pairs(variables) do
        if type(index) ~= "string" then
            error("Sent parameter of wrong type: variables must have strings as indicies")
        end
        if index == self.symbol then
            return self:tocompoundexpression():substitute(variables)
        end
    end

    return self
end

function PolynomialRing:autosimplify()
    return self:tocompoundexpression():autosimplify()
end

-- Transforms from array format to an expression format.
function PolynomialRing:tocompoundexpression()
    local terms = {}
    for exponent, coefficient in pairs(self.coefficients) do
        terms[exponent + 1] = BinaryOperation(BinaryOperation.MUL, {coefficient,
                                                BinaryOperation(BinaryOperation.POW, {SymbolExpression(self.symbol), Integer(exponent)})})
    end
    return BinaryOperation(BinaryOperation.ADD, terms)
end

-- Uses Horner's rule to evaluate a polynomial at a point
function PolynomialRing:evaluateAt(x)
    local out = self:zero()
    for i = self.degree:asnumber(), 0, -1 do
        out = out + self.coefficients[i]
        out = out * x
    end
    return out
end

-- Multiplies this polynomial by x^n
function PolynomialRing:multiplyDegree(n)
    local new = {}
    for e = 0, n-1 do
        new[e] = self:zeroc()
    end
    local loc = n
    while loc <= self.degree:asnumber() + n do
        new[loc] = self.coefficients[loc - n]
        loc = loc + 1
    end
    return PolynomialRing(new, self.symbol, self.degree + Integer(n))
end

-- Returns the formal derrivative of this polynomial
function PolynomialRing:derrivative()
    if self.degree == Integer.zero() then
        return PolynomialRing({self:zeroc()}, self.symbol, Integer(-1))
    end
    local new = {}
    for e = 1, self.degree:asnumber() do
        new[e - 1] = Integer(e) * self.coefficients[e]
    end
    return PolynomialRing(new, self.symbol, self.degree - Integer.one())
end

-- Returns the square-free factorization of a polynomial
function PolynomialRing:squarefreefactorization()
    local terms
    if self.ring == Rational.getring() or self.ring == Integer.getring() then
        terms = self:rationalsquarefreefactorization()
    elseif self.ring == IntegerModN.getring() then
        if not self.ring.modulus:isprime() then
            error("Cannot compute a square-free factorization of a polynomial ring contructed from a ring that is not a field.")
        end
        terms = self:modularsquarefreefactorization()
    end

    local expressions = {self:lc()}
    local j = 1
    for index, term in ipairs(terms) do
        if term.degree ~= Integer.zero() or term.coefficients[0] ~= Integer.one() then
            j = j + 1
            expressions[j] = BinaryOperation.POWEXP({term, Integer(index)})
        end
    end

    return BinaryOperation.MULEXP(expressions)
end

-- Factors a polynomial into irreducible terms
function PolynomialRing:factor()
    -- Square-free factorization over an integral domain (so a polynomial ring constructed from a field)
    local squarefree = self:squarefreefactorization()
    local squarefreeterms = {}
    local result = {squarefree.expressions[1]}
    for i, expression in ipairs(squarefree.expressions) do
        if i > 1 then
            -- Converts square-free polynomials with rational coefficients to integer coefficients so Rational Roots / Zassenhaus can factor them
            if expression.expressions[1].ring == Rational.getring() then
                local factor, integerpoly = expression.expressions[1]:rationaltointeger()
                result[1] = result[1] * factor ^ expression.expressions[2]
                squarefreeterms[i - 1] = integerpoly
            else
                squarefreeterms[i - 1] = expression.expressions[1]
            end
        end
    end

    for i, expression in ipairs(squarefreeterms) do
        local terms
        if expression.ring == Integer.getring() then
            -- Factoring over the integers first uses the rational roots test to factor out monomials (for efficiency purposes)
            local remaining, factors = expression:rationalroots()
            terms = factors
            -- Then applies the Zassenhaus algorithm if there entire polynomial has not been factored into monomial
            if remaining ~= Integer.one() then
                remaining = remaining:zassenhausfactor()
                for _, exp in ipairs(remaining) do
                    terms[#terms+1] = exp
                end
            end
        end
        if expression.ring == IntegerModN.getring() then
            -- Berlekamp factorization is used for rings with integers mod a prime as coefficients
            terms = expression:berlekampfactor()
        end
        for _, factor in ipairs(terms) do
            result[#result+1] = BinaryOperation.POWEXP({factor, squarefree.expressions[i + 1].expressions[2]})
        end
    end
    return BinaryOperation.MULEXP(result)
end

-- Uses the Rational Root test to factor out monomials of a square-free polynomial.
function PolynomialRing:rationalroots()
    local remaining = self
    local roots = {}
    if self.coefficients[0] == Integer.zero() then
        roots[1] = PolynomialRing({Integer.zero(), Integer.one()}, self.symbol)
        remaining = remaining // roots[1]
    end
    -- This can be slower than Zassenhaus if the digits are large enough, since factoring integers is slow
    -- if self.coefficients[0] > Integer(Integer.DIGITSIZE - 1) or self:lc() > Integer(Integer.DIGITSIZE - 1) then
    --     return remaining, roots
    -- end
    while remaining ~= Integer.one() do
        :: nextfactor ::
        local a = remaining.coefficients[0]
        local b = remaining:lc()
        local afactors = a:divisors()
        local bfactors = b:divisors()
        for _, af in ipairs(afactors) do
            for _, bf in ipairs(bfactors) do
                local testroot = Rational(af, bf, true)
                if remaining:evaluateAt(testroot) == Integer.zero() then
                    roots[#roots+1] = PolynomialRing({-testroot.numerator, testroot.denominator}, self.symbol)
                    remaining = remaining // roots[#roots]
                    goto nextfactor
                end
                if remaining:evaluateAt(-testroot) == Integer.zero() then
                    roots[#roots+1] = PolynomialRing({testroot.numerator, testroot.denominator}, self.symbol)
                    remaining = remaining // roots[#roots]
                    goto nextfactor
                end
            end
        end
        break
    end

    return remaining, roots
end

-- Returns a list of roots of the polynomial, simplified up to cubics.
function PolynomialRing:roots()
    local roots = {}
    local factorization = self:factor()

    for i, factor in ipairs(factorization.expressions) do
        if i > 1 then
            local decomp = factor.expressions[1]:decompose()
            local factorroots = RootExpression(decomp[#decomp]):autosimplify()
            if factorroots == true then
                return true
            end
            if factorroots == false then
                goto nextfactor
            end
            local replaceroots = {}
            for j = #decomp - 1,1,-1 do
                for _, root in ipairs(factorroots) do
                    local temp = RootExpression(decomp[j]):autosimplify(root)
                    if temp == true then
                        return true
                    end
                    if factorroots == false then
                        goto nextfactor
                    end
                    replaceroots = JoinArrays(replaceroots, temp)
                end
                factorroots = replaceroots
            end
            roots = JoinArrays(roots, factorroots)
        end
    end
    ::nextfactor::
    return roots
end

-----------------
-- Inheritance --
-----------------

__PolynomialRing.__index = Ring
__PolynomialRing.__call = PolynomialRing.new
PolynomialRing = setmetatable(PolynomialRing, __PolynomialRing)