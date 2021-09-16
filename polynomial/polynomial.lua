require("number.init")

-- Represents an arbitrary polynomial ring in Lua.
Polynomial = {}
__Polynomial = {}

function __Polynomial.__unm(a)
    local new = {}
    for e = 0, a.degree.internal:asnumber() do
        new[e] = -a.array[e]
    end
    return Polynomial(new, a.degree)
end

function __Polynomial.__add(a, b)
    local larger
    if a.degree > b.degree then
        larger = a
    else
        larger = b
    end

    local new = {}
    for e in pairs(larger.array) do
        new[e] = a.array[e] + b.array[e]
    end

    return Polynomial(new)
end

function __Polynomial.__sub(a, b)
    return a + (-b)
end

-- uses Karatsuba multiplication
function __Polynomial.__mul(a, b)

    -- print("Multiplying " .. tostring(a) .. " with degree " .. tostring(a.degree) .. " and " .. tostring(b) .. " with degree " .. tostring(b.degree))

    if a.degree == Integer(1) and b.degree == Integer(1) then
        return Polynomial({a.array[0] * b.array[0]}, Integer(1))
    end

    local k = Integer.ceillog(Integer.max(a.degree, b.degree), Integer(2))
    local n = Integer(2) ^ k
    local m = n / Integer(2)

    local a0, a1, b0, b1 = {}, {}, {}, {}

    for e = 0, m.internal:asnumber() - 1 do
        a0[e] = a.array[e]
        a1[e] = a.array[e + m.internal:asnumber()]
        b0[e] = b.array[e]
        b1[e] = b.array[e + m.internal:asnumber()]
    end

    local p1 = Polynomial(a1, m) * Polynomial(b1, m)
    local p2 = Polynomial(a0, m) * Polynomial(b0, m)
    local p3 = (Polynomial(a0, m) + Polynomial(a1, m)) * (Polynomial(b0, m) + Polynomial(b1, m)) - p1 - p2

    local p = p1:multiplyDegree(n.internal:asnumber()) + p3:multiplyDegree(m.internal:asnumber()) + p2
    p.degree = a.degree + b.degree - Integer(1)
    return p
end

function __Polynomial.__tostring(a)
    local out = "("
    for i = 0, a.degree.internal:asnumber() - 1 do
        out = out .. tostring(a.array[i]) .. ", "
    end
    return string.sub(out, 0, string.len(out) - 2) .. ")"
end

--  Constructor for a new polynomial.
--  Parameter - array of ring elements, starting with the lowest ring element.
--  Parameter - degree of the polynomial, defaults to calculating if not provided
function Polynomial:new(a, d)
    local o = {}
    __Polynomial.__index = Polynomial
    o = setmetatable(o, __Polynomial)

    local a_new = {}
    if not a[0] then
        for e, c in ipairs(a) do
            a_new[e - 1] = c
        end
    else
        a_new = a
    end

    o.array = a_new
    o.ring = a_new[0]:type()
    if d then
        o.degree = d
    else
        o:calculateDegree()
    end

    -- Each value of the polynomial greater than its degree is implicitly zero
    o.array = setmetatable(o.array, {__index = function (table, key)
        return o.ring.ZERO
    end})

    return o
end

-- Updates the degree of a polynomial the long way
function Polynomial:calculateDegree()
    local count = Integer(0)
    for _ in pairs(self.array) do
        count = count + Integer(1)
    end
    for e = count.internal:asnumber(), 0 do
        if(self.array[count] ~= self.ring.ZERO) then
            break
        end
        count = count - Integer(1)
    end
   self.degree = count
end

-- Gets the degree of a polynomial
function Polynomial:getDegree()
    return self.degree - Integer(1)
end

-- Multiplies this polynomial by x^n
function Polynomial:multiplyDegree(n)
    local new = {}
    for e = 0, n-1 do
        new[e] = self.ring.ZERO
    end
    for e = 0, self.degree.internal:asnumber() do
        new[e + n] = self.array[e]
    end
    return Polynomial(new, self.degree + Integer(n))
end

-- Divides this polynomial by another
function Polynomial:divide(b)
    local n, m = self.degree - Integer(1), b.degree - Integer(1)
    local r, u = Polynomial(self.array), Integer(1) / b.array[m.internal:asnumber()]

    local q = {}
    -- print("r:" .. tostring(r))
    for i = (n-m).internal:asnumber(), 0,-1 do
        q[i] = r.array[(r.degree - Integer(1)).internal:asnumber()] * u
        r = r - Polynomial({q[i]}):multiplyDegree(i) * b
        -- print(Polynomial({q[i]}):multiplyDegree(i))
        -- print(Polynomial({q[i]}):multiplyDegree(i) * b)
        -- print("q:" .. tostring(q[i]))
        -- print("r:" .. tostring(r))
    end

    return Polynomial(q), r
end


-- Creates construction method
Polynomial = setmetatable(Polynomial, { __call = Polynomial.new, __index = nil})
