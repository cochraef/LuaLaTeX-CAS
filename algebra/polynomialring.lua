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

--------------------------
-- Static functionality --
--------------------------

-- Returns the immediate subrings of this ring
function PolynomialRing.subrings(construction)
    local child = construction.child
    local subrings = {child.getRing()}

    for i, subring in ipairs(child.subrings()) do
        local ring = Copy(construction)
        ring.child = subring
        subrings[i + 1] = ring
    end

    return subrings
end

-- Returns the GCD of two polynomials in a ring, assuming both rings are euclidean domains
function PolynomialRing.gcd(a, b)
    if a.symbol ~= b.symbol then
        error("Cannot take the gcd of two polynomials with different symbols")
    end
    while b.degree ~= Integer(0) or b.coefficients[0] ~= Integer(0) do
        a, b = b, a % b
    end
    return a // a:lc()
end


----------------------------
-- Instance functionality --
----------------------------

-- Creates a new polynomial ring given an array of coefficients and a symbol
function PolynomialRing:new(coefficients, symbol, degree)
    local o = {}
    local __o = Copy(__EuclideanOperations)
    __o.__index = PolynomialRing
    __o.__tostring = function(a)
        local out = ""
        local loc = a.degree:asNumber()
        while loc >= 0 do
            out = out .. tostring(a.coefficients[loc]) .. a.symbol .. "^" .. tostring(math.floor(loc)) .. "+"
            loc = loc - 1
        end
        return string.sub(out, 0, string.len(out) - 1)
    end
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
        if not coefficient.getRing() then
            error("Sent parameter of wrong type: Coefficients must be elements of a ring")
        end
        if not o.ring then
            o.ring = coefficient:getRing()
        else
            local newring = coefficient:getRing()
            if Ring.subringof(o.ring, newring) then
                o.ring = newring
            elseif not Ring.subringof(newring, o.ring) then
                error("Sent parameter of wrong type: Coefficients must all be part of the same ring")
            end
        end
    end

    if not coefficients[0] then
        -- Constructs the coefficients when a new polynomial is instantiated as an array
        for index, coefficient in ipairs(coefficients) do
            o.coefficients[index - 1] = coefficient
            o.degree = o.degree + Integer(1)
        end
    else
        -- Constructs the coefficients from an existing polynomial of coefficients
        local loc = o.degree:asNumber()
        while loc > 0 do
            if not coefficients[loc] or coefficients[loc] == o.ring.zero() then
                o.degree = o.degree - Integer(1)
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
        return o.ring:zero()
    end})

    return o
end

-- Returns the ring this object is an element of
function PolynomialRing:getRing()
    local t = {ring = PolynomialRing}
    if self then
        t.child = self.ring
        t.symbol = self.symbol
    end
    t = setmetatable(t, {__index = PolynomialRing, __eq = function(a, b)
        return a["ring"] == b["ring"] and
                (a["child"] == b["child"] or a["child"] == nil or b["child"] == nil) and
                (a["symbol"] == b["symbol"] or a["child"] == nil or b["child"] == nil)
    end})
    return t
end

-- Explicitly converts this element to an element of another ring
function PolynomialRing:inRing(ring)
    local coefficients = {}
    local loc = 0
    while loc <= self.degree:asNumber() do
        coefficients[loc] = self.coefficients[loc]:inRing(ring["child"])
        loc = loc + 1
    end
    return PolynomialRing(coefficients, self.symbol, self.degree)
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
    while loc <= larger.degree:asNumber() do
        new[loc] = self.coefficients[loc] + b.coefficients[loc]
        loc = loc + 1
    end

    return PolynomialRing(new, self.symbol, larger.degree)
end

function PolynomialRing:neg()
    local new = {}
    local loc = 0
    while loc <= self.degree:asNumber() do
        new[loc] = -self.coefficients[loc]
        loc = loc + 1
    end
    return PolynomialRing(new, self.symbol, self.degree)
end

function PolynomialRing:mul(b)
    if self.degree == Integer(0) and b.degree == Integer(0) then
        return PolynomialRing({self.coefficients[0] * b.coefficients[0]}, self.symbol, Integer(1))
    end

    local k = Integer.ceillog(Integer.max(self.degree, b.degree) + Integer(1), Integer(2))
    local n = Integer(2) ^ k
    local m = n / Integer(2)

    local a0, a1, b0, b1 = {}, {}, {}, {}

    for e = 0, m:asNumber() - 1 do
        a0[e] = self.coefficients[e]
        a1[e] = self.coefficients[e + m:asNumber()]
        b0[e] = b.coefficients[e]
        b1[e] = b.coefficients[e + m:asNumber()]
    end

    local p1 = PolynomialRing(a1, self.symbol, m - Integer(1)) * PolynomialRing(b1, self.symbol, m - Integer(1))
    local p2 = PolynomialRing(a0, self.symbol, m - Integer(1)) * PolynomialRing(b0, self.symbol, m - Integer(1))
    local p3 = (PolynomialRing(a0, self.symbol, m - Integer(1)) + PolynomialRing(a1, self.symbol, m - Integer(1))) *
                (PolynomialRing(b0, self.symbol, m - Integer(1)) + PolynomialRing(b1, self.symbol, m - Integer(1)))
                - p1 - p2

    return p1:multiplyDegree(n:asNumber()) + p3:multiplyDegree(m:asNumber()) + p2
end

function PolynomialRing:divremainder(b)
    local n, m = self.degree, b.degree
    local r, u = PolynomialRing(self.coefficients, self.symbol, self.degree), Integer(1) / b.coefficients[m:asNumber()]

    if(m > n) then
        return PolynomialRing({Integer(0)}, self.symbol, Integer(0)), self
    end

    local q = {}
    for i = (n-m):asNumber(), 0,-1 do
        if r.degree:asNumber() == m:asNumber() + i then
            q[i] = r.coefficients[r.degree:asNumber()] * u
            r = r - PolynomialRing({q[i]}, self.symbol):multiplyDegree(i) * b
        else
            q[i] = Integer(0)
        end
    end

    return PolynomialRing(q, self.symbol, self.degree), r
end

-- Polynomial rings are never fields, but when dividing by a polynomial by a constant we may want to use / instead of //
function PolynomialRing:div(b)
    return self:divremainder(b)
end

function PolynomialRing:zero()
    return self.ring.zero()
end

function PolynomialRing:one()
    return self.ring.one()
end

function PolynomialRing:eq(b)
    for i=0,math.max(self.degree:asNumber(), b.degree:asNumber()) do
        if self.coefficients[i] ~= b.coefficients[i] then
            return false
        end
    end
    return true
end

-- Returns the leading coefficient of this polynomial
function PolynomialRing:lc()
    return self.coefficients[self.degree:asNumber()]
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
            return self:toCompoundExpression():substitute(variables)
        end
    end

    return self
end

function PolynomialRing:autosimplify()
    return self:toCompoundExpression():autosimplify()
end

-- Transforms from array format to an expression format
function PolynomialRing:toCompoundExpression()
    local terms = {}
    for exponent, coefficient in pairs(self.coefficients) do
        terms[exponent + 1] = BinaryOperation(BinaryOperation.MUL, {coefficient,
                                                BinaryOperation(BinaryOperation.POW, {SymbolExpression(self.symbol), Integer(exponent)})})
    end
    return BinaryOperation(BinaryOperation.ADD, terms)
end

-- Multiplies this polynomial by x^n
function PolynomialRing:multiplyDegree(n)
    local new = {}
    for e = 0, n-1 do
        new[e] = self.ring.zero()
    end
    local loc = n
    while loc <= self.degree:asNumber() + n do
        new[loc] = self.coefficients[loc - n]
        loc = loc + 1
    end
    return PolynomialRing(new, self.symbol, self.degree + Integer(n))
end

-- Returns the formal derrivative of this polynomial
function PolynomialRing:derrivative()
    if self.degree == Integer(0) then
        return PolynomialRing({self.ring.zero()}, self.symbol, Integer(-1))
    end
    local new = {}
    for e = 1, self.degree:asNumber() do
        new[e - 1] = Integer(e) * self.coefficients[e]
    end
    return PolynomialRing(new, self.symbol, self.degree - Integer(1))
end

-- Returns the square-free factorization of a polynomial
function PolynomialRing:squarefreefactorization()
    local terms
    if self.ring == Rational.getRing() or self.ring == Integer.getRing() then
        terms = self:rationalsquarefreefactorization()
    elseif self.ring == IntegerModN.getRing() then
        if not self.ring.modulus:isprime() then
            error("Cannot compute a square-free factorization of a polynomial ring contructed from a ring that is not a field.")
        end
        terms = self:modularsquarefreefactorization()
    end

    local expressions = {self:lc()}
    local j = 1
    for index, term in ipairs(terms) do
        if term.degree ~= Integer(0) or term.coefficients[0] ~= Integer(1) then
            j = j + 1
            expressions[j] = BinaryOperation.POWEXP({term, Integer(index)})
        end
    end

    return BinaryOperation.MULEXP(expressions)
end

-- Square-free factorization in the rational field
function PolynomialRing:rationalsquarefreefactorization()
    local monic = self / self:lc()
    local terms = {}
    terms[0] = PolynomialRing.gcd(monic, monic:derrivative())
    local b = monic // terms[0]
    local c = monic:derrivative() // terms[0]
    local d = c - b:derrivative()
    local i = 1
    while b.degree ~= Integer(0) or b.coefficients[0] ~= Integer(1) do
        terms[i] = PolynomialRing.gcd(b, d)
        b, c = b // terms[i], d // terms[i]
        i = i + 1
        d = c - b:derrivative()
    end

    return terms
end

-- Square-free factorization in the modular field Zp
function PolynomialRing:modularsquarefreefactorization()
    local monic = self / self:lc()
    local terms = {}
    terms[0] = PolynomialRing.gcd(monic, monic:derrivative())
    local b = monic // terms[0]
    local c = monic:derrivative() // terms[0]
    local d = c - b:derrivative()
    local i = 1
    while b.degree ~= Integer(0) or b.coefficients[0] ~= Integer(1) do
        terms[i] = PolynomialRing.gcd(b, d)
        b, c = b // terms[i], d // terms[i]
        i = i + 1
        d = c - b:derrivative()
    end

    if not (terms[i-1]:derrivative().degree == Integer(0) and terms[i-1]:derrivative().coefficients[0] == Integer(0)) then
        return terms
    end

    local recursiveterms = terms[i-1]:collapseterms(self.ring.modulus):modularsquarefreefactorization()
    for k, poly in ipairs(recursiveterms) do
        recursiveterms[k] = poly:expandterms(self.ring.modulus)
    end
    return JoinArrays(terms, recursiveterms)
end

-- Returns a new polnomial consisting of every nth term of the old one - helper method for square-free factorization
function PolynomialRing:collapseterms(n)
    local new = {}
    local loc = 0
    local i = 0
    local nn = n:asNumber()
    while loc <= self.degree:asNumber() do
        new[i] = self.coefficients[loc]
        loc = loc + nn
        i = i + 1
    end

    return PolynomialRing(new, self.symbol, self.degree // n)
end

-- Returns a new polnomial consisting of every nth term of the old one - helper method for square-free factorization
function PolynomialRing:expandterms(n)
    local new = {}
    local loc = 0
    local i = 0
    local nn = n:asNumber()
    while i <= self.degree:asNumber() do
        new[loc] = self.coefficients[i]
        for j = 1, nn do
            new[loc + j] = IntegerModN(Integer(0), n)
        end
        loc = loc + nn
        i = i + 1
    end

    return PolynomialRing(new, self.symbol, self.degree * n)
end


-- Factors a polynomial into irreducible terms
function PolynomialRing:factor()
    local squarefree = self:squarefreefactorization()
    local result = {squarefree.expressions[1]}
    local j = 2
    for i, expression in ipairs(squarefree.expressions) do
        if i > 1 then
            local terms
            if self.ring == IntegerModN.getRing() then
                terms = expression.expressions[1]:berlekampfactor()
            end
            for _, squarefreeexpression in ipairs(terms) do
                result[j] = BinaryOperation.POWEXP({squarefreeexpression, expression.expressions[2]})
                j = j + 1
            end
        end
    end
    return BinaryOperation.MULEXP(result)
end

-- Uses Berlekamp's Algorithm to factor polynomials in mod p
function PolynomialRing:berlekampfactor()
    if self.degree == 0 or self.degree == 1 then
        return {self}
    end

    local R = self:RMatrix()
    local S = self:auxillarybasis(R)
    if #S == 1 then
        return {self}
    end
    return self:findfactors(S)
end

-- Gets the R Matrix for Berlekamp factorization
function PolynomialRing:RMatrix()
    local R = {}
    for i = 1, self.degree:asNumber() do
        R[i] = {}
    end
    for i = 0, self.degree:asNumber()-1 do
        local remainder = PolynomialRing({IntegerModN(Integer(1), self.ring.modulus)}, self.symbol):multiplyDegree(self.ring.modulus:asNumber()*i) % self
        for j = 0, self.degree:asNumber()-1 do
            R[j + 1][i + 1] = remainder.coefficients[j]
            if j == i then
                R[j + 1][i + 1] = R[j + 1][i + 1] - IntegerModN(Integer(1), self.ring.modulus)
            end
        end
    end
    return R
end

-- Creates an auxillary basis using the R matrix
function PolynomialRing:auxillarybasis(R)
    local P = {}
    local n = self.degree:asNumber()
    for i = 1, n do
        P[i] = 0
    end
    S = {}
    local q = 1
    for j = 1, n do
        local i = 1
        local pivotfound = false
        while not pivotfound and i <= n do
            if R[i][j] ~= self.ring:zero() and P[i] == 0 then
                pivotfound = true
            else
                i = i + 1
            end
        end
        if pivotfound then
            P[i] = j
            local a = R[i][j]:inv()
            for l = 1, n do
                R[i][l] = a * R[i][l]
            end
            for k = 1, n do
                if k ~= i then
                    local f = R[k][i]
                    for l = 1, n do
                        R[k][l] = R[k][l] - f*R[i][l]
                    end
                end
            end
        else
            local s = {}
            s[j] = self.ring:one()
            for l = 1, j - 1 do
                local e = 0
                i = 1
                while e == 0 and i <= n do
                    if l == P[i] then
                        e = i
                    else
                        i = i + 1
                    end
                end
                if e > 0 then
                    local c = -R[e][j]
                    s[l] = c
                else
                    s[l] = self.ring:zero()
                end
            end
            S[q] = PolynomialRing(s, self.symbol)
            q = q + 1
        end
    end
    return S
end

-- Uses the auxilary basis to find the irriducible factors of the polynomial
function PolynomialRing:findfactors(S)
    local r = #S
    local p = self.ring.modulus
    local factors = {self}
    for k = 2,r do
        local b = S[k]
        local old_factors = Copy(factors)
        for i = 1,#old_factors do
            local w = old_factors[i]
            local j = 0
            while j <= p:asNumber() - 1 do
                local g = PolynomialRing.gcd(b-IntegerModN(Integer(j), p), w)
                if g.degree == Integer(0) and g.coefficients[0] == Integer(1) then
                    j = j + 1
                elseif g == w then
                    j = p:asNumber()
                else
                    factors = Remove(factors, w)
                    local q = w // g
                    factors[#factors+1] = g
                    factors[#factors+1] = q
                    if #factors == r then
                        return factors
                    else
                        j = j + 1
                        w = q
                    end
                end

            end
        end
    end
end

-----------------
-- Inheritance --
-----------------

__PolynomialRing.__index = Ring
__PolynomialRing.__call = PolynomialRing.new
PolynomialRing = setmetatable(PolynomialRing, __PolynomialRing)