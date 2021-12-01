-- Interface for an arbitrary mathematical expression
Expression = {}

-----------------------
-- Required methods --
----------------------

-- Evaluates the current expression recursively by evaluating each sub-expression
function Expression:evaluate()
    error("Called unimplemented method : evaluate()")
end

-- Given a table mapping variables to expressions, replaces each variable with a new expressions
function Expression:substitute(variables)
    error("Called unimplemented method : substitute()")
end

-- Performs automatic simplification of an expression
function Expression:autosimplify()
    error("Called unimplemented method : autosimplify()")
end

-- Returns whether the expression is atomic or not
function Expression:isAtomic()
    error("Called unimplemented method: isAtomic()")
end

-- Returns whether the expression can be evaluated in compound expressions or not
function Expression:isEvaluatable()
    error("Called unimplemented method: isEvaluatable()")
end

-- Returns true if this expression comes before the other expressions in commutative binary operations, false otherwise
function Expression:order(other)
    error("Called unimplemented method: order()")
end

-- Converts this expression to LaTeX code - returns a sting with the code
-- Should probably only be used on autosimplified expressions - otherwise it could look weird
function Expression:tolatex()
    error("Called Unimplemented method: tolatex()")
end
----------------------
-- Instance methods --
----------------------

-- Returns the type of the expression - may not be accurate
function Expression:type()
    return getmetatable(self).__index
end

--------------------------
-- Instance metamethods --
--------------------------
__ExpressionOperations = {}

__ExpressionOperations.__unm = function(a)
    return BinaryOperation.SUBEXP({a})
end

__ExpressionOperations.__add = function(a, b)
    return BinaryOperation.ADDEXP({a, b})
end

__ExpressionOperations.__sub = function(a, b)
    return BinaryOperation.SUBEXP({a, b})
end

__ExpressionOperations.__mul = function(a, b)
    return BinaryOperation.MULEXP({a, b})
end

__ExpressionOperations.__call = function(a, b)
    return BinaryOperation.MULEXP({a, b})
end

__ExpressionOperations.__div = function(a, b)
    return BinaryOperation.DIVEXP({a, b})
end

__ExpressionOperations.__pow = function(a, b)
    return BinaryOperation.POWEXP({a, b})
end