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
        local new = PolynomialRing({}, "x")
        new.ring = subring
        subrings[i + 1] = new.getType()
    end

    return subrings
end


----------------------------
-- Instance functionality --
----------------------------

-- Creates a new polynomial ring given an array of coefficients and a symbol
function PolynomialRing:new(coefficients, symbol, degree)
    local o = {}
    local __o = Copy(__RingOperations)
    __o.__index = PolynomialRing
    __o.__tostring = function(a)
        local out = ""
        local loc = a.degree:asNumber()
        while loc >= 0 do
            out = out .. tostring(a.coefficients[loc]) .. a.symbol .. "^" .. tostring(loc) .. "+"
            loc = loc - 1
        end
        return string.sub(out, 0, string.len(out) - 1)
    end
    o = setmetatable(o, __o)

    if type(coefficients) ~= "table" then
        error("Coefficients must be in an array")
    end
    o.coefficients = {}
    o.degree = Integer(-1)

    local properstart = coefficients[0]
    for index, coefficient in ipairs(coefficients) do
        if type(index) ~= "number" then
            error("Coefficients must be in an array")
        end
        if not coefficient.getRing() then
            error("Coefficients must be part of a ring")
        end
        if not o.ring then
            o.ring = coefficient.getRing()
        end

        if properstart then
            o.coefficients[index] = coefficient
        else
            o.coefficients[index - 1] = coefficient
        end

        if degree and o.degree == degree then
            break
        end
        o.degree = o.degree + Integer(1)
    end

    if type(symbol) ~= "string" then
        error("Symbol must be a string")
    end
    o.symbol = symbol

    -- Each value of the polynomial greater than its degree is implicitly zero
    o.coefficients = setmetatable(o.coefficients, {__index = function (table, key)
        return o.ring:zero()
    end})

    return o
end

-- Returns the type of this object
-- has a field for the type of ring used to construct this ring, like type parameterization in Java only worse
function PolynomialRing:getRing()
    local t = {child=self.ring}
    return setmetatable(t, {__index = PolynomialRing, __eq = function(a, b)
        return a["child"] == b["child"]
    end})
end


-- Returns whether the ring is commutative
function PolynomialRing:isCommutative()
    return true
end

function PolynomialRing:add(b)
    local larger

    if(self.symbol ~= b.symbol) then
        error("Attempted to add two polynomial rings with different symbols")
    end

    if self.degree > b.degree then
        larger = self
    else
        larger = b
    end

    local new = {}
    local loc = Integer(0)
    while loc <= larger.degree do
        new[loc] = self.coefficients[loc] + b.coefficients[loc]
    end

    return PolynomialRing(new, self.symbol)
end

function PolynomialRing:neg()
    local new = {}
    local loc = Integer(0)
    while loc <= self.degree do
        new[loc] = -self.coefficients[loc]
    end
    return PolynomialRing(new, self.symbol)
end


function PolynomialRing:mul(b)
    if self.degree == Integer(1) and b.degree == Integer(1) then
        return PolynomialRing({self.coefficients[0] * b.coefficients[0]}, Integer(1))
    end

    local k = Integer.ceillog(Integer.max(self.degree, b.degree), Integer(2))
    local n = Integer(2) ^ k
    local m = n / Integer(2)

    local a0, a1, b0, b1 = {}, {}, {}, {}

    for e = 0, m.internal:asnumber() - 1 do
        a0[e] = self.coefficients[e]
        a1[e] = self.coefficients[e + m.internal:asnumber()]
        b0[e] = b.coefficients[e]
        b1[e] = b.coefficients[e + m.internal:asnumber()]
    end

    local p1 = PolynomialRing(a1, m) * PolynomialRing(b1, m)
    local p2 = PolynomialRing(a0, m) * PolynomialRing(b0, m)
    local p3 = (PolynomialRing(a0, m) + PolynomialRing(a1, m)) * (PolynomialRing(b0, m) + PolynomialRing(b1, m)) - p1 - p2

    local p = p1:multiplyDegree(n.internal:asnumber()) + p3:multiplyDegree(m.internal:asnumber()) + p2
    p.degree = self.degree + b.degree - Integer(1)
    return p
end

function PolynomialRing:divremainder(b)
    local n, m = self.degree - Integer(1), b.degree - Integer(1)
    local r, u = PolynomialRing(self.coefficients), Integer(1) / b.coefficients[m.internal:asnumber()]

    local q = {}
    for i = (n-m).internal:asnumber(), 0,-1 do
        q[i] = r.coefficients[(r.degree - Integer(1)).internal:asnumber()] * u
        r = r - PolynomialRing({q[i]}):multiplyDegree(i) * b
    end

    return PolynomialRing(q), r
end

function PolynomialRing:zero()
    return self.ring.zero()
end

function PolynomialRing:one()
    return self.ring.one()
end

-- Given a table mapping variables to expressions, replaces each variable with a new expressions
function PolynomialRing:substitute(variables)
    if type(variables) ~= "table" then
        error("Sent parameter of wrong type: variables must be a table")
    end

    for index, expression in ipairs(variables) do
        if type(index) ~= "string" then
            error("Sent parameter of wrong type: variables must have strings as indicies")
        end
        if index == self.symbol then
            return self:toCompoundExpression():substitute(variables)
        end
    end

    return self
end

-- Transforms from array format to an expression format
function PolynomialRing:toCompoundExpression()
    local terms = {}
    for exponent, coefficient in ipairs(self.coefficients) do
        terms[exponent:asNumber() - 1] = BinaryOperation(BinaryOperation.MUL, {coefficient,
                                                BinaryOperation(BinaryOperation.POW, {SymbolExpression(self.symbol), exponent})})
    end
    return BinaryOperation(BinaryOperation.ADD, terms)
end

-- Multiplies this polynomial by x^n
function PolynomialRing:multiplyDegree(n)
    local new = {}
    for e = 0, n-1 do
        new[e] = self.ring.ZERO
    end
    for e = 0, self.degree.internal:asnumber() do
        new[e + n] = self.coefficients[e]
    end
    return PolynomialRing(new, self.degree + Integer(n))
end

-----------------
-- Inheritance --
-----------------

__PolynomialRing.__index = Ring
__PolynomialRing.__call = PolynomialRing.new
PolynomialRing = setmetatable(PolynomialRing, __PolynomialRing)