-- Interface for an 'atomic' mathematical expression, i.e., an element of a set
-- AtomicExpressions have the following relation to other classes:
--      AtomicExpresssions extend Expressions
AtomicExpression = {}
__AtomicExpression = {}

----------------------
-- Instance methods --
----------------------

-- Evaluates the current expression to itself
function AtomicExpression:evaluate()
    return self
end

-- Default substitution behavior, can be overwritten for more complicated atomic expressions
function AtomicExpression:substitute(map)
    for expression, replacement in pairs(map) do
        if self == expression then
            return replacement
        end
    end
    return self
end

-- Performs automatic simplification of an expression
function AtomicExpression:autosimplify()
    return self
end

-- If an atomic expression has an alternate representation as a compound expression, this converts it into that alternate representation.
-- Normally, though, atomic expressions are properly atomic and this will just return itself.
function AtomicExpression:tocompoundexpression()
    return self
end

-- Atomic expressions are atomic, suprisingly
function AtomicExpression:isatomic()
    return true
end

-- Most atomic expressions can be evaluated
function AtomicExpression:isevaluatable()
    return true
end

-- Atomic expressions should come before all other expressions except themselves
function AtomicExpression:order(other)
    if self:isevaluatable() and other:isevaluatable() then
        return self < other
    end

    if self == E or self == PI or self == I then
        return false
    end

    return true
end

-- Most atomic expressions should have the same __tostring as LaTeX's output
function AtomicExpression:tolatex()
    return tostring(self)
end

-----------------
-- Inheritance --
-----------------

__AtomicExpression.__index = Expression
AtomicExpression = setmetatable(AtomicExpression, __AtomicExpression)