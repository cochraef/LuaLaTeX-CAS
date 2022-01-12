-- Methods related to the Zassenhaus factorization algorithm.


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

-- Uses Zassenhaus's Algorithm to factor sqaure-free polynomials over the intergers
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
    local S = V:inring(PolynomialRing.R("y", p)):berlekampfactor()

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
            w[j] = factor.coefficients[j]:inring(Integer.getRing()) * l ^ Integer(j)
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
        local s = self:inring(P:getRing())
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
        local Vp = V[1]:inring(PolynomialRing.R("y"))
        for i = 2, #V do
            Vp = Vp * V[i]:inring(PolynomialRing.R("y"))
        end
        local E = self - Vp:inring(PolynomialRing.R("y"))
        if E == Integer(0) then
            return V
        end
        E = E:inring(PolynomialRing.R("y", p ^ Integer(j))):inring(PolynomialRing.R("y"))
        F = E / p ^ (Integer(j) - Integer(1))
        R = self:genextendR(V, G, F)
        local Vnew = {}
        for i, v in ipairs(V) do
            local vnew = v:inring(PolynomialRing.R("y", p ^ Integer(j)))
            local rnew = R[i]:inring(PolynomialRing.R("y", p ^ Integer(j)))
            Vnew[i] = vnew + (p) ^ (Integer(j) - Integer(1)) * rnew
        end
        V = Vnew;
    end
    return self:truefactors(V, k)
end

-- Gets a list of sigma polynomials for use in hensel lifting
function PolynomialRing:genextendsigma(S)
    local v = S[1] * S[2]
    local _, A, B = PolynomialRing.extendedgcd(S[2], S[1])
    local SIGMA = {A, B}
    for i, _ in ipairs(S) do
        if i >= 3 then
            v = v * S[i]
            local sum = SIGMA[1] * (v // S[1])
            for j = 2, i-1 do
                sum = sum + SIGMA[j] * (v // S[j])
            end
            _, A, B = PolynomialRing.extendedgcd(sum, v // S[i])
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
        R[i] = F:inring(pring) * G[i] % v:inring(pring)
    end
    return R
end

-- Updates factors of the polynomial to the correct ones in the integer ring
function PolynomialRing:truefactors(l, k)
    local U = self
    local L = l
    local factors = {}
    local m = 1
    local p = L[1].coefficients[0].modulus
    while m <= #L / 2 do
        local C = Subarrays(L, m)
        while #C > 0 do
            local t = C[1]
            local prod = t[1]
            for i = 2, #t do
                prod = prod * t[i]
            end
            local T = prod:inring(PolynomialRing.R("y", p ^ k)):inring(PolynomialRing.R("y"))
            -- Convert to symmetric representation - this is the only place it actually matters
            for i = 0, T.degree:asNumber() do
                if T.coefficients[i] > p ^ k / Integer(2) then
                    T.coefficients[i] = T.coefficients[i] - p^k
                end
            end
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