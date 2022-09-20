--- @class Rational
--- Represents an element of the field of rational numbers or rational functions.
--- @field numerator Ring
--- @field denominator Ring
--- @field ring RingIdentifier
Rational = {}
__Rational = {}


--------------------------
-- Static functionality --
--------------------------

-- Metatable for ring objects.
local __obj = {__index = Rational, __eq = function(a, b)
    return a["ring"] == b["ring"] and
            (a["child"] == b["child"] or a["child"] == nil or b["child"] == nil) and
            (a["symbol"] == b["symbol"] or a["child"] == nil or b["child"] == nil)
end, __tostring = function(a)
        if a.child and a.symbol then
            return tostring(a.child.child) .. "(" .. a.symbol .. ")"
        end
        return "QQ"
    end}

--- @param symbol SymbolExpression
--- @param child RingIdentifier
--- @return RingIdentifier
function Rational.makering(symbol, child)
    local t = {ring = Rational}
    t.symbol = symbol
    t.child = child
    t = setmetatable(t, __obj)
    return t
end


----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the field operations each time.
local __o = Copy(__FieldOperations)
__o.__index = Rational
__o.__tostring = function(a)
    return tostring(a.numerator).."/"..tostring(a.denominator)
end

--- Creates a new rational given an integer numerator and denominator.
--- Rational numbers are represented uniquely.
--- @param n Ring
--- @param d Ring
--- @param keep boolean
function Rational:new(n, d, keep)
    local o = {}
    o = setmetatable(o, __o)

    if n:getring() == PolynomialRing.getring() then
        o.symbol = n.symbol
        o.ring = n:getring()
    end

    if d:getring() == PolynomialRing.getring() then
        o.symbol = d.symbol
        o.ring = d:getring()
    end

    n = n or Integer.zero()
    d = d or Integer.one()
    o.numerator = n
    o.denominator = d
    if not o.ring then
        o:reduce()
    end

    if (not keep) and o.denominator == Integer.one() or (not keep) and o.numerator == Integer.zero() then
        return o.numerator
    end

    return o
end

--- Reduces a rational expression to standard form.
function Rational:reduce()
    if self.denominator < Integer.zero() then
        self.denominator = -self.denominator
        self.numerator = -self.numerator
    end
    local gcd = Integer.gcd(self.numerator, self.denominator)
    self.numerator = self.numerator//gcd
    self.denominator = self.denominator//gcd
end


--- @return RingIdentifier
function Rational:getring()
    local t = {ring=Rational}
    if self then
        t.child = self.ring
        t.symbol = self.symbol
    end
    t = setmetatable(t, __obj)
    return t
end

--- @param ring RingIdentifier
--- @return Ring
function Rational:inring(ring)
    if ring == self:getring() then
        return self
    end

    if ring == PolynomialRing:getring() then
        return PolynomialRing({self:inring(ring.child)}, ring.symbol)
    end

    error("Unable to convert element to proper ring.")
end

--- @return boolean
function Rational:isconstant()
    if self.ring then
        return false
    end
    return true
end

--- @return Expression
function Rational:tocompoundexpression()
    return BinaryOperation(BinaryOperation.DIV, {self.numerator:tocompoundexpression(), self.denominator:tocompoundexpression()})
end

--- Returns this rational as a floating point number. Can only approximate the value of most rationals.
--- @return number
function Rational:asnumber()
    return self.numerator:asnumber() / self.denominator:asnumber()
end

function Rational:add(b)
    return Rational(self.numerator * b.denominator + self.denominator * b.numerator, self.denominator * b.denominator)
end

function Rational:neg()
    return Rational(-self.numerator, self.denominator, true)
end

function Rational:mul(b)
    return Rational(self.numerator * b.numerator, self.denominator * b.denominator)
end

-- function Rational:inv(b)
--     return Rational(self.numerator * b.numerator, self.denominator * b.denominator)
-- end

function Rational:pow(b)
    return (self.numerator ^ b) / (self.denominator ^ b)
end

function Rational:div(b)
    return Rational(self.numerator * b.denominator, self.denominator * b.numerator)
end

function Rational:eq(b)
    return self.numerator == b.numerator and self.denominator == b.denominator
end

function Rational:lt(b)
    if self.numerator < Integer.zero() and b.numerator > Integer.zero() then
        return true
    end
    if self.numerator > Integer.zero() and b.numerator < Integer.zero() then
        return false
    end

    if (self.numerator >= Integer.zero() and b.numerator >= Integer.zero()) or (self.numerator <= Integer.zero() and b.numerator <= Integer.zero()) then
        return self.numerator * b.denominator < self.denominator * b.numerator
    end
    return self.numerator * b.denominator > self.denominator * b.numerator
end

function Rational:le(b)
    return self:eq(b) or self:lt(b)
end

function Rational:zero()
    return Integer.zero()
end

function Rational:one()
    return Integer.one()
end

function Rational:tolatex()
    if string.sub(self.numerator:tolatex(),1,1) == '-' then
        return "- \\frac{" .. string.sub(self.numerator:tolatex(),2,-1) .. "}{" .. self.denominator:tolatex() .. "}"
    end
    return "\\frac{" .. self.numerator:tolatex() .."}{".. self.denominator:tolatex().. "}"
end

-----------------
-- Inheritance --
-----------------

__Rational.__index = Field
__Rational.__call = Rational.new
Rational = setmetatable(Rational, __Rational)