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

-- Returns whether the expression can be evaluated by compound expressions or not
function Expression:isEvaluatable()
    error("Called unimplemented method: isEvaluatable()")
end