-- Represents various specific real number constants
-- Constants have the following relation to other classes:
--      Constants implement Atomic Expressions

-- The constant pi.
Pi = {}
__Pi = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new pi expresssion
function Pi:new()
    local o = {}
    local __o = Copy(__ExpressionOperations)

    __o.__index = Pi
    __o.__tostring = function(a)
        return 'pi'
    end
    __o.__eq = function(a, b)
        return a:type() == b:type()
    end
    o = setmetatable(o, __o)

    return o
end

-- approximates pi as a rational number
function Pi:approx()
    return Integer(62831853) / Integer(20000000)
end

function Pi:isEvaluatable()
    return false
end

-----------------
-- Inheritance --
-----------------

__Pi.__index = AtomicExpression
__Pi.__call = Pi.new
Pi = setmetatable(Pi, __Pi)


-- The constant e.
E = {}
__E = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new e expresssion
function E:new()
    local o = {}
    local __o = Copy(__ExpressionOperations)

    __o.__index = E
    __o.__tostring = function(a)
        return 'e'
    end
    __o.__eq = function(a, b)
        return a:type() == b:type()
    end
    o = setmetatable(o, __o)

    return o
end

-- approximates e as a rational number
function E:approx()
    return Integer(679570457) / Integer(250000000)
end

function E:isEvaluatable()
    return false
end

-----------------
-- Inheritance --
-----------------

__E.__index = AtomicExpression
__E.__call = E.new
E = setmetatable(E, __E)

-- The (complex) constant I.
I = {}
__I = {}

----------------------------
-- Instance functionality --
----------------------------

-- Creates a new e expresssion
function I:new()
    local o = {}
    local __o = Copy(__ExpressionOperations)

    __o.__index = E
    __o.__tostring = function(a)
        return 'i'
    end
    __o.__eq = function(a, b)
        return a:type() == b:type()
    end
    o = setmetatable(o, __o)

    return o
end

function I:isEvaluatable()
    return false
end

-----------------
-- Inheritance --
-----------------

__I.__index = AtomicExpression
__I.__call = I.new
I = setmetatable(I, __I)

----------------------
-- Static constants --
----------------------
PI = Pi()
E = E()
I = I()