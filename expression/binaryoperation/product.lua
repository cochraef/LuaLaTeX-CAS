-- Seperates the various binary operations into their own files for readability

-- Automatic simplification of multiplication expressions
function BinaryOperation:simplifyproduct()
    if not self.expressions[1] then
        error("Execution error: attempted to simplify empty product")
    end

    if not self.expressions[2] then
        return self.expressions[1]
    end

    -- Uses the property that x*0=0
    for index, expression in ipairs(self.expressions) do
        if expression:isEvaluatable() and expression == expression:zero() then
            return expression:zero()
        end
    end

    local result = self:simplifyproductrec()

    -- We don't really know what ring we are working in here, so just assume the integer ring
    if not result.expressions[1] then
        return Integer(1)
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
        if (term1:isEvaluatable() or not (term1.operation == BinaryOperation.MUL)) and
            (term2:isEvaluatable() or not (term2.operation == BinaryOperation.MUL)) then

            if term1:isEvaluatable() and term2:isEvaluatable() then
                return BinaryOperation(BinaryOperation.MUL, {self:evaluate()})
            end

            -- Uses the property that x*1 = x
            if term1:isEvaluatable() and term1 == term1:one() then
                return BinaryOperation(BinaryOperation.MUL, {term2})
            end

            if term2:isEvaluatable() and term2 == term2:one() then
                return BinaryOperation(BinaryOperation.MUL, {term1})
            end

            -- Uses the property that x^a*x^b=x^(a+b)
            local revertterm1 = false
            local revertterm2 = false
            if term1.operation ~= BinaryOperation.POW then
                term1 = BinaryOperation(BinaryOperation.POW, {term1, Integer(1)})
                revertterm1 = true
            end
            if term2.operation ~= BinaryOperation.POW then
                term2 = BinaryOperation(BinaryOperation.POW, {term2, Integer(1)})
                revertterm2 = true
            end
            if term1.expressions[1] == term2.expressions[1]
                    and term1.expressions[2].getRing() ~= Rational and term2.expressions[2].getRing() ~= Rational then
                local result = BinaryOperation(BinaryOperation.POW,
                                    {term1.expressions[1],
                                    BinaryOperation(BinaryOperation.ADD,
                                        {term1.expressions[2], term2.expressions[2]}):autosimplify()}):autosimplify()
                if result.isEvaluatable() and result == result:one() then
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

    if first.isEvaluatable() and first == first.one() then
        return BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
    end

    if first.operation ~= BinaryOperation.MUL or not first.expressions[2] then
        local result = BinaryOperation(self.operation, selfrest):mergeproducts(BinaryOperation(other.operation, otherrest))
        if first.operation ~= BinaryOperation.MUL then
            table.insert(result.expressions, 1, first)
        else
            table.insert(result.expressions, 1, first.expressions[1])
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

    return result
end