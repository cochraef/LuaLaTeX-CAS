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

--- Performs more rigorous simplification of an expression. Checks different equivalent forms and determines the 'smallest' expresion.
--- @return Expression
function Expression:simplify()
    local me = self:unlock():autosimplify()
    local results = {}
    for index, expression in ipairs(me:subexpressions()) do
        results[index] = expression:simplify()
    end
    me = me:setsubexpressions(results)

    local out = me
    local minsize = self:size()

    local test = me:expand()
    if test:size() < minsize then
        out = test
        minsize = test:size()
    end

    test = me:factor()
    if test:size() < minsize then
        out = test
        minsize = test:size()
    end

    return out
end

--- Changes the autosimplify behavior of an expression depending on its parameters.
--- THIS METHOD MUTATES THE OBJECT IT ACTS ON.
--- @param mode number
--- @param permanent boolean
--- @param recursive boolean
--- @return Expression
function Expression:lock(mode, permanent, recursive)
    function self:autosimplify()
        if not permanent then
            self.autosimplify = nil
        end

        if mode == Expression.NIL then
            return self
        elseif mode == Expression.SUBS then
            local results = {}
            for index, expression in ipairs(self:subexpressions()) do
                results[index] = expression:autosimplify()
            end
            self = self:setsubexpressions(results, true) -- TODO: Add mutate setsubexpressions
            return self
        end
    end
    if recursive then
        for _, expression in ipairs(self:subexpressions()) do
            expression:lock(mode, permanent, recursive)
        end
    end
    return self
end

--- Frees any locks on expressions.
--- THIS METHOD MUTATES THE OBJECT IT ACTS ON.
--- @param recursive boolean
--- @return Expression
function Expression:unlock(recursive)
    self.autosimplify = nil
    if recursive then
        for _, expression in ipairs(self:subexpressions()) do
            expression:unlock(recursive)
        end
    end
    return self
end

--- Returns a list of all subexpressions of an expression.
--- @return table<number, Expression>
function Expression:subexpressions()
    error("Called unimplemented method : subexpressions()")
end

--- Returns the total number of atomic and compound expressions that make up an expression, or the number of nodes in the expression tree.
--- @return Integer
function Expression:size()
    local out = Integer.one()
    for _, expression in ipairs(self:subexpressions()) do
        out = out + expression:size()
    end
    return out
end

--- Returns a copy of the original expression with each subexpression substituted with a new one, or a mutated version if mutate is true.
--- @param subexpressions table<number, Expression>
--- @param mutate boolean
--- @return Expression
function Expression:setsubexpressions(subexpressions, mutate)
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

--- Attempts to combine an expression by collapsing sums of expressions together into a single factor, e.g. common denominator
--- @return Expression
function Expression:combine()
    return self
end

--- Attempts to collect all occurances of an expression in this expression.
--- @param collect Expression
--- @return Expression
function Expression:collect(collect)
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

--- Determines whether an expression is a constant, i.e., an atomic expression that is not a varaible and cannot be converted into an equivalent compound expression.
--- @return boolean
function Expression:isconstant()
    error("Called unimplemented method: isconstant()")
end

--- Determines whether an expression is a 'proper' real constant, i.e., is free of every varaible.
function Expression:isrealconstant()
    if self:isconstant() or self == PI or self == E then
        return true
    end

    for _, expression in ipairs(self:subexpressions()) do
        if not expression:isrealconstant() then
            return false
        end
    end

    return self:type() ~= SymbolExpression
end

--- Determines whether an expression is a 'proper' complex constant, i.e., is free of every varaible and is of the form a + bI for nonzero a and b.
--- @return boolean
function Expression:iscomplexconstant()
    return self:isrealconstant() or (self.operation == BinaryOperation.ADD and #self.expressions == 2 and self.expressions[1]:isrealconstant()
            and ((self.expressions[2].operation == BinaryOperation.MUL and #self.expressions[2].expressions == 2 and self.expressions[2].expressions[1]:isrealconstant() and self.expressions[2].expressions[2] == I)
            or self.expressions[2] == I)) or (self.operation == BinaryOperation.MUL and #self.expressions == 2 and self.expressions[1]:isrealconstant() and self.expressions[2] == I)
end

--- A total order on autosimplified expressions. Returns true if self < other.
--- @param other Expression
--- @return boolean
function Expression:order(other)
    error("Called unimplemented method: order()")
end

--- Returns an autosimplified expression as a single-variable polynomial in a ring, if it can be converted. Returns itself otherwise.
--- @return PolynomialRing, boolean
function Expression:topolynomial()
    return self, false
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

----------------------
-- Static constants --
----------------------

Expression.NIL = 0
Expression.SUBS = 1