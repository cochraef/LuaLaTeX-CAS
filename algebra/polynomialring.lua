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
    local child = construction["child"]
    local subrings = {child}

    for i, subring in ipairs(child.subrings()) do
        local new = PolynomialRing({}, construction["symbol"])
        new.ring = subring
        subrings[i + 1] = new:getRing()
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
            o.ring = coefficient.getRing()
        else
            local newring = coefficient.getRing()
            if o.ring.subringof(o.ring, newring) then
                o.ring = newring
            elseif not newring.subringof(newring, o.ring) then
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

-- Returns the type of this object
-- has a field for the type of ring used to construct this ring, like type parameterization in Java only worse
function PolynomialRing:getRing()
    local t = {child=self.ring, symbol=self.symbol}
    return setmetatable(t, {__index = PolynomialRing, __eq = function(a, b)
        return a["child"] == b["child"] and a["symbol"] == b["symbol"]
    end})
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

function PolynomialRing:zero()
    return self.ring.zero()
end

function PolynomialRing:one()
    return self.ring.one()
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
    local reduced = self // self:lc()
    local terms = {}
    terms[0] = PolynomialRing.gcd(reduced, reduced:derrivative())
    local b = reduced // terms[0]
    local c = reduced:derrivative() // terms[0]
    local d = c - b:derrivative()
    local i = 1
    while b.degree ~= Integer(0) or b.coefficients[0] ~= Integer(1) do
        terms[i] = PolynomialRing.gcd(b, d)
        b, c = b // terms[i], d // terms[i]
        i = i + 1
        d = c - b:derrivative()
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

-----------------
-- Inheritance --
-----------------

__PolynomialRing.__index = Ring
__PolynomialRing.__call = PolynomialRing.new
PolynomialRing = setmetatable(PolynomialRing, __PolynomialRing)