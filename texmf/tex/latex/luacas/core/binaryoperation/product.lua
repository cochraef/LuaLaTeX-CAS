-- Seperates the various binary operations into their own files for readability

--- Automatic simplification of multiplication expressions.
--- @return BinaryOperation
function BinaryOperation:simplifyproduct()
    if not self.expressions[1] then
        error("Execution error: attempted to simplify empty product")
    end

    if not self.expressions[2] then
        return self.expressions[1]
    end

    -- Uses the property that x*0=0
    for _, expression in ipairs(self.expressions) do
        if expression:isconstant() and expression == expression:zero() then
            return expression:zero()
        end
    end

    local result = self:simplifyproductrec()

    -- We don't really know what ring we are working in here, so just assume the integer ring
    if not result.expressions[1] then
        return Integer.one()
    end

    if not result.expressions[2] then
        return result.expressions[1]
    end

    return result
end

function BinaryOperation:simplifyproductrec()
    local term1 = self.expressions[1]
    local term2 = self.expressions[2]

    if not self.expressions[3] then
        if (term1:isconstant() or not (term1.operation == BinaryOperation.MUL)) and
            (term2:isconstant() or not (term2.operation == BinaryOperation.MUL)) then

            if term1:isconstant() and term2:isconstant() then
                local result = self:evaluate()
                if result == result:one() then
                    return BinaryOperation(BinaryOperation.MUL, {})
                end
                return BinaryOperation(BinaryOperation.MUL, {result})
            end

            -- Uses the property that x*1 = x
            if term1:isconstant() and term1 == term1:one() then
                return BinaryOperation(BinaryOperation.MUL, {term2})
            end

            if term2:isconstant() and term2 == term2:one() then
                return BinaryOperation(BinaryOperation.MUL, {term1})
            end

            -- Distributes constants if the other term is a sum expression.
            if term1:isconstant() and term2.operation == BinaryOperation.ADD then
                local distributed = BinaryOperation(BinaryOperation.ADD, {})
                for i, exp in ipairs(term2:subexpressions()) do
                    distributed.expressions[i] = term1 * exp
                end
                return BinaryOperation(BinaryOperation.MUL, {distributed:autosimplify()})
            end

            if term2:isconstant() and term1.operation == BinaryOperation.ADD then
                local distributed = BinaryOperation(BinaryOperation.ADD, {})
                for i, exp in ipairs(term1:subexpressions()) do
                    distributed.expressions[i] = term2 * exp
                end
                return BinaryOperation(BinaryOperation.MUL, {distributed:autosimplify()})
            end

            -- Uses the property that sqrt(a,r)*sqrt(b,r) = sqrt(a*b,r) if a,r are positive integers
            if term1:type() == SqrtExpression and term2:type() == SqrtExpression and term1.expression:isconstant() and term2.expression:isconstant() and term1.root:type() == Integer then
                if term1.root == term2.root and term1.expression > Integer.zero() then
                    local expression = term1.expression*term2.expression
                    local result = SqrtExpression(expression,term1.root):autosimplify()
                    if result == Integer.one() then
                        return BinaryOperation(BinaryOperation.MUL,{})
                    else
                        return BinaryOperation(BinaryOperation.MUL,{result})
                    end
                end
            end

            --if term1.operation == BinaryOperation.POW and term2.operation == BinaryOperation.POW and term1.expressions[1]:type() == SqrtExpression and term2.expressions[1]:type() == SqrtExpression and term1.expressions[2]:type() == Integer and term2.expressions[2]:type() == Integer and term1.expressions[2] < Integer.zero() and term2.expressions[2] < Integer.zero() and term1.expressions[1].root == term2.expressions[1].root then
            --    local expo1 = term1.expressions[2]:neg()
            --    local expo2 = term2.expressions[2]:neg()
            --    local root = term1.expressions[1].root
            --    local expr1 = term1.expressions[1].expression
            --    local expr2 = term2.expressions[1].expression
            --    local result1 = BinaryOperation(BinaryOperation.POW,{SqrtExpression(expr1,root),expo1}):simplifypower()
            --    local result2 = BinaryOperation(BinaryOperation.POW,{SqrtExpression(expr2,root),expo2}):simplifypower()
            --    local result = BinaryOperation(BinaryOperation.MUL,{result1,result2}):autosimplify()
            --    if result == Integer.one() then
            --        return BinaryOperation(BinaryOperation.MUL,{})
            --    end
            --    if result:type() == Integer then
            --        return BinaryOperation(BinaryOperation.MUL,{Rational(Integer.one(),result)})
            --    end
            --    return BinaryOperation(BinaryOperation.MUL,{BinaryOperation(BinaryOperation.POW, {result,Integer(-1)})}):autosimplify()
            --end

            -- Uses the property that x^a*x^b=x^(a+b)
            local revertterm1 = false
            local revertterm2 = false
            if term1.operation ~= BinaryOperation.POW then
                term1 = BinaryOperation(BinaryOperation.POW, {term1, Integer.one()})
                revertterm1 = true
            end
            if term2.operation ~= BinaryOperation.POW then
                term2 = BinaryOperation(BinaryOperation.POW, {term2, Integer.one()})
                revertterm2 = true
            end
            if term1.expressions[1] == term2.expressions[1]
                --and not
                --        (term1.expressions[1]:type() == Integer and
                --        term1.expressions[2]:type() ~= term2.--expressions[2]:type())
            then
                local result = BinaryOperation(BinaryOperation.POW,
                                    {term1.expressions[1],
                                    BinaryOperation(BinaryOperation.ADD,
                                        {term1.expressions[2], term2.expressions[2]}):autosimplify()}):autosimplify()
                if result:isconstant() and result == result:one() then
                    return BinaryOperation(BinaryOperation.MUL, {})
                end
                return BinaryOperation(BinaryOperation.MUL, {result})
            end

            if revertterm1 then
                term1 = term1.expressions[1]
            end
            if revertterm2 then
                term2 = term2.expressions[1]
            end

            if term2:order(term1) then
                return BinaryOperation(BinaryOperation.MUL, {term2, term1})
            end

            return self
        end

        if term1.operation == BinaryOperation.MUL and not (term2.operation == BinaryOperation.MUL) then
            return term1:mergeproducts(BinaryOperation(BinaryOperation.MUL, {term2}))
        end

        if not (term1.operation == BinaryOperation.MUL) and term2.operation == BinaryOperation.MUL then
            return BinaryOperation(BinaryOperation.MUL, {term1}):mergeproducts(term2)
        end

        return term1:mergeproducts(term2)
    end

    local rest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            rest[index - 1] = expression
        end
    end

    local result = BinaryOperation(BinaryOperation.MUL, rest):simplifyproductrec()

    if term1.operation ~= BinaryOperation.MUL then
        term1 = BinaryOperation(BinaryOperation.MUL, {term1})
    end
    if result.operation ~= BinaryOperation.MUL then
        result = BinaryOperation(BinaryOperation.MUL, {result})
    end
    return term1:mergeproducts(result)
end

-- Merges two lists of products
function BinaryOperation:mergeproducts(other)
    if not self.expressions[1] then
        return other
    end

    if not other.expressions[1] then
        return self
    end

    local first = BinaryOperation(BinaryOperation.MUL, {self.expressions[1], other.expressions[1]}):simplifyproductrec()

    local selfrest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            selfrest[index - 1] = expression
        end
    end

    local otherrest = {}
    for index, expression in ipairs(other.expressions) do
        if index > 1 then
            otherrest[index - 1] = expression
        end
    end

    if first.operation ~= BinaryOperation.MUL or not first.expressions[2] then
        local result = BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
        if not first.expressions[1] then
            return result
        end
        table.insert(result.expressions, 1, first.expressions[1])

        if result.operation == BinaryOperation.MUL and not result.expressions[3] and result.expressions[1] and result.expressions[2] then
            if result.expressions[1]:isconstant() and result.expressions[2]:isconstant() then
                return result:simplifyproductrec()
            end
        end
        return result
    end

    local result
    if first.expressions[1] == self.expressions[1] then
        result = BinaryOperation(self.operation, selfrest):mergeproducts(other)
    else
        result = self:mergeproducts(BinaryOperation(other.operation, otherrest))
    end
    table.insert(result.expressions, 1, first.expressions[1])
    if result.operation == BinaryOperation.MUL and not result.expressions[3] and result.expressions[1] and result.expressions[2] then
        if result.expressions[1]:isconstant() and result.expressions[2]:isconstant() then
            return result:simplifyproductrec()
        end
    end
    return result
end