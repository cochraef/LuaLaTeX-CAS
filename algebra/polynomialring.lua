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
    while b ~= Integer(0) do
        a, b = b, a % b
    end
    return a // a:lc()
end

-- Returns the GCD of two polynomials in a ring, assuming both rings are euclidean domains
-- Also returns bezouts coefficients via extended gcd
function PolynomialRing.extendedgcd(a, b)
    local oldr, r  = a, b
    local olds, s  = Integer(1), Integer(0)
    local oldt, t  = Integer(0), Integer(1)
    while r ~= Integer(0) do
        local q = oldr // r
        oldr, r  = r, oldr - q*r
        olds, s = s, olds - q*s
        oldt, t = t, oldt - q*t
    end
    return oldr // oldr:lc(), olds, oldt
end


----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the Euclidean operations each time
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
        if not coefficient.getRing then
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
    return PolynomialRing(PolynomialRing.mul_rec(self.coefficients, b.coefficients), self.symbol, self.degree + b.degree)
end

-- Performs Karatsuba multiplication without constructing new polynomials recursively
function PolynomialRing.mul_rec(a, b)
    if #a==0 and #b==0 then
        return {[0]=a[0] * b[0], [1]=Integer(0)}
    end

    local k = Integer.ceillog(Integer.max(Integer(#a), Integer(#b)) + Integer(1), Integer(2))
    local n = Integer(2) ^ k
    local m = n / Integer(2)
    local nn = n:asNumber()
    local mn = m:asNumber()

    local a0, a1, b0, b1 = {}, {}, {}, {}

    for e = 0, mn - 1 do
        a0[e] = a[e] or Integer(0)
        a1[e] = a[e + mn] or Integer(0)
        b0[e] = b[e] or Integer(0)
        b1[e] = b[e + mn] or Integer(0)
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

function PolynomialRing:divremainder(b)
    local n, m = self.degree, b.degree
    local r, u = PolynomialRing(self.coefficients, self.symbol, self.degree), Integer(1) / b.coefficients[m:asNumber()]

    if(m > n) then
        return PolynomialRing({Integer(0)}, self.symbol, Integer(0)), self
    end

    local q = {}
    for i = (n-m):asNumber(), 0,-1 do
        if r.degree:asNumber() == m:asNumber() + i then
            q[i] = r:lc() * u
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

-- Factors the largest possible constant out of a polynomial whos underlying ring is a Euclidean domain but not a field
function PolynomialRing:factorconstant()
    local gcd = Integer(0)
    for i = 0, self.degree:asNumber() do
        gcd = self.ring.gcd(gcd, self.coefficients[i])
    end
    if gcd == Integer(0) then
        return Integer(1), self
    end
    return gcd, self / gcd
end

-- Converts a polynomial in the rational polynomial ring to the integer polynomial ring
function PolynomialRing:rationaltointeger()
    local lcm = Integer(1)
    for i = 0, self.degree:asNumber() do
        if self.coefficients[i]:getRing() == Rational:getRing() then
            lcm = lcm * self.coefficients[i].denominator / Integer.gcd(lcm, self.coefficients[i].denominator)
        end
    end
    return Integer(1) / lcm, self * lcm
end

-- Returns the square-free factorization of a polynomial
function PolynomialRing:squarefreefactorization(keeplc)
    local terms
    if self.ring == Rational.getRing() or self.ring == Integer.getRing() then
        terms = self:rationalsquarefreefactorization(keeplc)
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
function PolynomialRing:rationalsquarefreefactorization(keeplc)
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
    if keeplc and terms[1] then
        terms[0] = Integer(1)
        terms[1] = terms[1] * self:lc()
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
    local squarefree
    local result
    if self.ring == Rational:getRing() then
        local factor, integerpoly = self:rationaltointeger()
        squarefree = integerpoly:squarefreefactorization(true)
        result = {factor}
    else
        squarefree = self:squarefreefactorization()
        result = {squarefree.expressions[1]}
    end
    local j = 2
    for i, expression in ipairs(squarefree.expressions) do
        if i > 1 then
            local terms
            if self.ring == Integer.getRing() or self.ring == Rational.getRing() then
                terms = expression.expressions[1]:zassenhausfactor()
            end
            if self.ring == IntegerModN.getRing() then
                terms = expression.expressions[1]:berlekampfactor()
            end
            for _, factor in ipairs(terms) do
                result[j] = BinaryOperation.POWEXP({factor, expression.expressions[2]})
                j = j + 1
            end
        end
    end
    return BinaryOperation.MULEXP(result)
end

-- Uses Zassenhaus's Algorithm to factor polynomials over the intergers
function PolynomialRing:zassenhausfactor()

    -- Creates a monic polynomial V with related roots
    local V = {}
    local n = self.degree:asNumber()
    local l = self:lc()
    for i = 0, n - 1 do
        V[i] = l ^ Integer(n - 1 - i) * self.coefficients[i]
    end
    V[n] = Integer(1)
    V = PolynomialRing(V, "y", self.degree)

    -- Performs Berlekamp Factorization in a sutable prime base
    local p = V:findprime()
    local P = PolynomialRing({IntegerModN(Integer(0), p)}, "y")
    local S = V:inRing(P:getRing()):berlekampfactor()

    -- If a polynomial is irreducible with coefficients in mod p, it is also irreducible over the integers
    if #S == 1 then
        return {self}
    end

    -- Performs Hensel lifting on the factors mod p
    local k = V:findmaxlifts(p)
    local W = V:henselift(S, k)
    local M = {}

    -- Returns the solutions back to the original from the monic transformation
    for i, factor in ipairs(W) do
        local w = {}
        for j = 0, factor.degree:asNumber() do
            w[j] = factor.coefficients[j]:inRing(Integer.getRing()) * l ^ Integer(j)
        end
        _, M[i] = PolynomialRing(w, self.symbol, factor.degree):factorconstant()
    end

    return M

end

-- Finds the smallest prime such that this polynomial with coefficients in mod p is square-free
function PolynomialRing:findprime()

    local smallprimes = {Integer(2), Integer(3), Integer(5), Integer(7), Integer(11), Integer(13), Integer(17), Integer(19), Integer(23),
                            Integer(29), Integer(31), Integer(37), Integer(41), Integer(43), Integer(47), Integer(53), Integer(59)}

    for _, p in pairs(smallprimes) do
        local P = PolynomialRing({IntegerModN(Integer(1), p)}, self.symbol)
        local s = self:inRing(P:getRing())
        if PolynomialRing.gcd(s, s:derrivative()) == P then
            return p
        end
    end

    error("Execution error: No suitable prime found for factoring.")
end

-- Finds the maximum number of times Hensel Lifting will be applied to raise solutions to the appropriate power
function PolynomialRing:findmaxlifts(p)
    local n = self.degree:asNumber()
    local h = self.coefficients[0]
    for i=0 , n do
        if self.coefficients[i] > h then
            h = self.coefficients[i]
        end
    end

    local B = 2^n * math.sqrt(n) * h:asNumber()
    return Integer(math.ceil(math.log(2*B, p:asNumber())))
end

-- Uses Hensel lifting on the factors of a polynomial S mod p to find them in the integers
function PolynomialRing:henselift(S, k)
    if k == Integer(1) then
        return self:truefactors(S, k)
    end
    local p = S[1].coefficients[0].modulus
    G = self:genextendsigma(S)
    local V = S
    for j = 2, k:asNumber() do
        local Vp = V[1]:inRing(PolynomialRing({Integer(0)}, "y"):getRing())
        for i = 2, #V do
            Vp = Vp * V[i]:inRing(PolynomialRing({Integer(0)}, "y"):getRing())
        end
        local E = self - Vp:inRing(PolynomialRing({Integer(0)}, "y"):getRing())
        print(E)
        if E == Integer(0) then
            return V
        else
            E = E:inRing(PolynomialRing({IntegerModN(Integer(0), p ^ Integer(j))}, "y"):getRing()):inRing(PolynomialRing({Integer(0)}, "y"):getRing())
            F = E / p ^ (Integer(j) - Integer(1))
            R = self:genextendR(V, G, F)
            local Vnew = {}
            for i, v in ipairs(V) do
                local vnew = v:inRing(PolynomialRing({IntegerModN(Integer(0), p ^ Integer(j))}, "y"):getRing())
                local rnew = R[i]:inRing(PolynomialRing({IntegerModN(Integer(0), p ^ Integer(j))}, "y"):getRing())
                Vnew[i] = vnew + (p) ^ (Integer(j) - Integer(1)) * rnew
            end
            V = Vnew;
        end
    end
    return self:truefactors(V, k)
end

-- Gets a list of sigma polynomials for use in hensel lifting
function PolynomialRing:genextendsigma(S)
    local v = S[1]
    for i = 2, #S do
        v = v * S[i]
    end
    local G = {}
    for i, factor in ipairs(S) do
        G[i] = v // factor
    end
    local _, A, B = PolynomialRing.extendedgcd(G[1], G[2])
    local SIGMA = {A, B}
    for i, s in ipairs(S) do
        if i >= 3 then
            local sum = SIGMA[1]
            for j = 2, i-1 do
                sum = sum + SIGMA[j] * G[j]
            end
            _, A, B = PolynomialRing.extendedgcd(sum, G[i])
            for j = 1, i-1 do
                SIGMA[j] = SIGMA[j] * A
            end
            SIGMA[i] = B
        end
    end

    return SIGMA
end

-- Gets a list of r polynomials for use in hensel lifting
function PolynomialRing:genextendR(V, G, F)
    R = {}
    for i, v in ipairs(V) do
        local pring = G[1]:getRing()
        R[i] = F:inRing(pring) * G[i] % v:inRing(pring)
    end
    return R
end

-- Updates factors of the polynomial to the correct ones in the integer ring
function PolynomialRing:truefactors(l, k)
    local U = self
    local L = l
    local factors = {}
    local m = 1
    local p = S[1].coefficients[0].modulus
    while m <= #L / 2 do
        local C = Subarrays(L, m)
        while #C > 0 do
            local t = C[1]
            local prod = t[1]
            for i = 2, #t do
                prod = prod * t[i]
            end
            local T = prod:inRing(PolynomialRing({IntegerModN(Integer(0), p ^ k)}, "y"):getRing())
            local Q, R = U:divremainder(T)
            if R == Integer(0) then
                factors[#factors+1] = T
                U = Q
                L = RemoveAll(L, t)
                C = RemoveAny(C, t)
            else
                C = Remove(C, t)
            end
        end
        m = m + 1
    end
    if U ~= Integer(1) then
        factors[#factors+1] = U
    end
    return factors;
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
                if g == Integer(1) then
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