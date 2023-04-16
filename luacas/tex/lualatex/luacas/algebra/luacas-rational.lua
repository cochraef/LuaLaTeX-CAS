--- @class Rational
--- Represents an element of the field of rational numbers or rational functions.
--- @field numerator Ring
--- @field denominator Ring
--- @field ring RingIdentifier
Rational = {}
local __Rational = {}


--------------------------
-- Static functionality --
--------------------------

-- Metatable for ring objects.
local __obj = {__index = Rational, __eq = function(a, b)
    return a["ring"] == b["ring"] and
            (a["child"] == b["child"] or a["child"] == nil or b["child"] == nil) and
            (a["symbol"] == b["symbol"] or a["child"] == nil or b["child"] == nil)
end, __tostring = function(a)
        if a.symbol then
            return tostring(a.child.child) .. "(" .. a.symbol .. ")"
        end
        if a.child then
            return "QQ"
        end
        return "(Generic Fraction Field)"
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

--- Converts a string of the form -?[0-9]+ or -?[0-9]+\/[0-9]+ to a rational number.
--- @param str string
--- @return Rational|Integer
function Rational.fromstring(str)
    local divloc = string.find(str, "/");
    if not divloc then
        return Integer(str)
    end
    return Rational(Integer(string.sub(str, 1, divloc - 1)), Integer(string.sub(str, divloc + 1, #str)))
end


----------------------------
-- Instance functionality --
----------------------------

-- So we don't have to copy the field operations each time.
__RationalOperations = Copy(__FieldOperations)
__RationalOperations.__index = Rational
__RationalOperations.__tostring = function(a)
    if a.ring.symbol then
        return "(" .. tostring(a.numerator)..")/("..tostring(a.denominator) .. ")"
    end
    return tostring(a.numerator).."/"..tostring(a.denominator)
end

--- Creates a new rational given a numerator and denominator that are part of the same ring.
--- Rational numbers are represented uniquely.
--- @param n Ring
--- @param d Ring
--- @param keep boolean
function Rational:new(n, d, keep)
    local o = {}
    o = setmetatable(o, __RationalOperations)

    if n:getring() == PolynomialRing.getring() then
        o.symbol = n.symbol
    end

    if d:getring() == PolynomialRing.getring() then
        o.symbol = d.symbol
    end

    if d == Integer(0) then
        error("Arithmetic error: division by zero")
    end

    n = n or Integer.zero()
    d = d or Integer.one()
    o.numerator = n
    o.denominator = d
    if not keep then
        o:reduce()
    end

    if o.numerator:getring() == Integer.getring() then
        o.ring = Integer.getring()
    elseif o.numerator:getring() == PolynomialRing.getring() then
        o.ring = Ring.resultantring(o.numerator:getring(), o.denominator:getring())
    end

    if (not keep) and o.denominator == Integer.one() or (not keep) and o.numerator == Integer.zero() then
        return o.numerator
    end

    return o
end

--- Reduces a rational expression to standard form. This method mutates its object.
function Rational:reduce()
    if self.numerator:getring() == Integer.getring() then
        if self.denominator < Integer.zero() then
            self.denominator = -self.denominator
            self.numerator = -self.numerator
        end
        local gcd = Integer.gcd(self.numerator, self.denominator)
        self.numerator = self.numerator//gcd
        self.denominator = self.denominator//gcd
    elseif self.numerator:getring() == PolynomialRing.getring() then
        local lc = self.denominator:lc()
        self.denominator = self.denominator/lc
        self.numerator = self.numerator/lc
        local gcd = PolynomialRing.gcd(self.numerator, self.denominator)
        self.numerator = self.numerator//gcd
        self.denominator = self.denominator//gcd
    end
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

    if ring == Rational:getring() and ring.symbol then
        if not self:getring().symbol then
            return Rational(self:inring(ring.child), self:inring(ring.child):one(), true)
        end
        return Rational(self.numerator:inring(ring.child), self.denominator:inring(ring.child), true)
    end

    if ring == PolynomialRing:getring() then
        return PolynomialRing({self:inring(ring.child)}, ring.symbol)
    end

    error("Unable to convert element to proper ring.")
end

--- @return boolean
function Rational:isconstant()
    if self.symbol then
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