-- Methods related to polynomial decomposition.

-- Returns a list of polynomials that form a complete decomposition of a polynomial.
function PolynomialRing:decompose()
    local U = self - self.coefficients[0]
    local S = U:divisors()
    local decomposition = {}
    local C = PolynomialRing({Integer.zero(), Integer.one()}, self.symbol)
    local finalcomponent

    while S[1] do
        local w = S[1]
        for _, poly in ipairs(S) do
            if poly.degree < w.degree then
                w = poly
            end
        end
        S = Remove(S, w)
        if C.degree < w.degree and w.degree < self.degree and self.degree % w.degree == Integer.zero() then
            local g = w:polyexpand(C, self.symbol)
            local R = self:polyexpand(w, self.symbol)
            if g.degree == Integer.zero() and R.degree == Integer.zero() then
                g.symbol = self.symbol
                decomposition[#decomposition+1] = g.coefficients[0]
                decomposition[#decomposition].symbol = self.symbol
                C = w
                finalcomponent = R.coefficients[0]
            end
        end
    end

    if not decomposition[1] then
        return {self}
    end

    finalcomponent.symbol = self.symbol
    decomposition[#decomposition+1] = finalcomponent
    return decomposition
end

-- Returns a list of all monic divisors of positive degree of the polynomial, assuming the polynomial ring is a Euclidean Domain.
function PolynomialRing:divisors()
    local factors = self:factor()
    -- Converts each factor to a monic factor (we don't need to worry updating the constant term)
    for i, factor in ipairs(factors.expressions) do
        if i > 1 then
            factor.expressions[1] = factor.expressions[1] / factor.expressions[1]:lc()
        end
    end

    local terms = {}
    for i, _ in ipairs(factors.expressions) do
        if i > 1 then
            terms[i] = Integer.zero()
        end
    end

    local divisors = {}
    local divisor = PolynomialRing({self:onec()}, self.symbol)
    while true do
        for i, factor in ipairs(factors.expressions) do
            if i > 1 then
                local base = factor.expressions[1]
                local power = factor.expressions[2]
                if terms[i] < power then
                    terms[i] = terms[i] + Integer.one()
                    divisor = divisor * base
                    break
                else
                    terms[i] = Integer.zero()
                    divisor = divisor // (base ^ power)
                end
            end
        end
        if divisor == Integer.one() then
            break
        end
        divisors[#divisors+1] = divisor
    end

    return divisors

end

-- Polynomial expansion as a subroutine of decomposition.
function PolynomialRing:polyexpand(v, x)
    local u = self
    if u == Integer.zero() then
        return Integer.zero()
    end
    local q,r = u:divremainder(v)
    return PolynomialRing({PolynomialRing({Integer.zero(), Integer.one()}, "_")}, x) * q:polyexpand(v, x) + r
end