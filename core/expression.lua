--- @class Expression
--- Interface for an arbitrary mathematical expression.
Expression = {}

----------------------
-- Required methods --
----------------------

--- Evaluates the current expression recursively by evaluating each sub-expression.
--- @return Expression
function Expression:evaluate()
    error("Called unimplemented method : evaluate()")
end

--- Performs automatic simplification of an expression. Called on every expression before being output from the CAS.
--- @return Expression
function Expression:autosimplify()
    error("Called unimplemented method : autosimplify()")
end

--- Returns a list of all subexpressions of an expression.
--- @return table<number, Expression>
function Expression:subexpressions()
    error("Called unimplemented method : subexpressions()")
end

--- Returns a copy of the original expression with each subexpression substituted with a new one.
--- @param subexpressions table<number, Expression>
--- @return Expression
function Expression:setsubexpressions(subexpressions)
    error("Called unimplemented method : setsubexpressions()")
end

--- Determines whether or not an expression contains a particular symbol.
--- @param symbol SymbolExpression
--- @return boolean
function Expression:freeof(symbol)
    error("Called unimplemented method : freeof()")
end

--- Substitutes occurances of specified sub-expressions with other sub-expressions.
--- @param map table<Expression, Expression>
--- @return Expression
function Expression:substitute(map)
    error("Called unimplemented method : substitute()")
end

--- Algebraically expands an expression by turning products of sums into sums of products and expanding powers.
--- @return Expression
function Expression:expand()
    return self
end

--- Attempts to factor an expression by turning sums of products into products of sums, and identical terms multiplied together into factors.
--- @return Expression
function Expression:factor()
    return self
end

--- Returns all non-constant subexpressions of this expression - helper method for factor.
--- @return table<number, Expression>
function Expression:getsubexpressionsrec()
    local result = {}

    for _, expression in ipairs(self:subexpressions()) do
        if not expression:isconstant() then
            result[#result+1] = expression
        end
        result = JoinArrays(result, expression:getsubexpressionsrec())
    end

    return result
end

--- Determines whether an expression is atomic.
--- Atomic expressions are not necessarily constant, since polynomial rings, for instance, are atomic parts that contain symbols.
--- @return boolean
function Expression:isatomic()
    error("Called unimplemented method: isatomic()")
end

--- Determines whether an expression is a constant, i.e., is free of every variable.
--- @return boolean
function Expression:isconstant()
    error("Called unimplemented method: isconstant()")
end

-- A total order on autosimplified expressions. Returns true if self < other.
--- @param other Expression
--- @return boolean
function Expression:order(other)
    error("Called unimplemented method: order()")
end

--- Converts this expression to LaTeX code.
--- @return string
function Expression:tolatex()
    error("Called Unimplemented method: tolatex()")
end

----------------------
-- Instance methods --
----------------------

--- Returns the type of the expression, i.e., the table used to create objects of that type.
--- @return table
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

__ExpressionOperations.__div = function(a, b)
    return BinaryOperation.DIVEXP({a, b})
end

__ExpressionOperations.__pow = function(a, b)
    return BinaryOperation.POWEXP({a, b})
end

-- For iterating over the subexpressions of a easily.
__ExpressionOperations.__call = function(a, ...)
    if a:type() == SymbolExpression then
        return FunctionExpression(a, table.pack(...))
    end
    return BinaryOperation.MULEXP({a, table.pack(...)[1]})
end