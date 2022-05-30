-- Methods related to the Berlekamp factoring algorithm.

-- Square-free factorization in the modular field Zp.
function PolynomialRing:modularsquarefreefactorization()
    local monic = self / self:lc()
    local terms = {}
    terms[0] = PolynomialRing.gcd(monic, monic:derivative())
    local b = monic // terms[0]
    local c = monic:derivative() // terms[0]
    local d = c - b:derivative()
    local i = 1
    while b ~= Integer.one() do
        terms[i] = PolynomialRing.gcd(b, d)
        b, c = b // terms[i], d // terms[i]
        i = i + 1
        d = c - b:derivative()
    end

    if not (terms[i-1]:derivative().degree == Integer.zero() and terms[i-1]:derivative().coefficients[0] == Integer.zero()) then
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
    local nn = n:asnumber()
    while loc <= self.degree:asnumber() do
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
    local nn = n:asnumber()
    while i <= self.degree:asnumber() do
        new[loc] = self.coefficients[i]
        for j = 1, nn do
            new[loc + j] = IntegerModN(Integer.zero(), n)
        end
        loc = loc + nn
        i = i + 1
    end

    return PolynomialRing(new, self.symbol, self.degree * n)
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
    for i = 1, self.degree:asnumber() do
        R[i] = {}
    end
    for i = 0, self.degree:asnumber()-1 do
        local remainder = PolynomialRing({IntegerModN(Integer.one(), self.ring.modulus)}, self.symbol):multiplyDegree(self.ring.modulus:asnumber()*i) % self
        for j = 0, self.degree:asnumber()-1 do
            R[j + 1][i + 1] = remainder.coefficients[j]
            if j == i then
                R[j + 1][i + 1] = R[j + 1][i + 1] - IntegerModN(Integer.one(), self.ring.modulus)
            end
        end
    end
    return R
end

-- Creates an auxillary basis using the R matrix
function PolynomialRing:auxillarybasis(R)
    local P = {}
    local n = self.degree:asnumber()
    for i = 1, n do
        P[i] = 0
    end
    S = {}
    local q = 1
    for j = 1, n do
        local i = 1
        local pivotfound = false
        while not pivotfound and i <= n do
            if R[i][j] ~= self:zeroc() and P[i] == 0 then
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
                    local f = R[k][j]
                    for l = 1, n do
                        R[k][l] = R[k][l] - f*R[i][l]
                    end
                end
            end
        else
            local s = {}
            s[j] = self:onec()
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
                    s[l] = self:zeroc()
                end
            end
            S[#S+1] = PolynomialRing(s, self.symbol)
        end
    end
    return S
end

-- Uses the auxilary basis to find the irreirrducible factors of the polynomial.
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
            while j <= p:asnumber() - 1 do
                local g = PolynomialRing.gcd(b-IntegerModN(Integer(j), p), w)
                if g == Integer.one() then
                    j = j + 1
                elseif g == w then
                    j = p:asnumber()
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