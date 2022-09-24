-- Seperates the various binary operations into their own files for readability

-- Automatic simplification of addition expressions.
--- @return BinaryOperation
function BinaryOperation:simplifysum()
    if not self.expressions[1] then
        error("Execution error: Attempted to simplify empty sum")
    end

    if not self.expressions[2] then
        return self.expressions[1]
    end

    local result = self:simplifysumrec()

    -- We don't really know what ring we are working in here, so just assume the integer ring
    if not result.expressions[1] then
        return Integer.zero()
    end

    -- Simplifies single sums to their operands
    if not result.expressions[2] then
        return result.expressions[1]
    end

    return result
end

function BinaryOperation:simplifysumrec()
    local term1 = self.expressions[1]
    local term2 = self.expressions[2]

    if self.expressions[1] and self.expressions[2] and not self.expressions[3] then
        if (term1:isconstant() or not (term1.operation == BinaryOperation.ADD)) and
            (term2:isconstant() or not (term2.operation == BinaryOperation.ADD)) then

            if term1:isconstant() and term2:isconstant() then
                return BinaryOperation(BinaryOperation.ADD, {self:evaluate()})
            end

            -- Uses the property that x + 0 = x
            if term1:isconstant() and term1 == term1:zero() then
                return BinaryOperation(BinaryOperation.ADD, {term2})
            end

            if term2:isconstant() and term2 == term2:zero() then
                return BinaryOperation(BinaryOperation.ADD, {term1})
            end

            local revertterm1 = false
            local revertterm2 = false
            -- Uses the property that a*x+b*x= (a+b)*x
            -- This is only done if a and b are constant, since otherwise this could be counterproductive
            -- We SHOULD be okay to only check left distributivity, since constants always come first when ordered
            if term1.operation == BinaryOperation.MUL and term2.operation == BinaryOperation.MUL then
                local findex = 2
                local sindex = 2
                if not term1.expressions[1]:isconstant() then
                    revertterm1 = true
                    findex = 1
                end
                if not term2.expressions[1]:isconstant() then
                    revertterm2 = true
                    sindex = 1
                end
                if FancyArrayEqual(term1.expressions,term2.expressions,findex,sindex) then
                    local result
                    if not revertterm1 and not revertterm2 then
                        result = BinaryOperation(
                            BinaryOperation.ADD,
                            {term1.expressions[1],term2.expressions[1]}
                        )
                    end
                    if revertterm1 and not revertterm2 then
                        result = BinaryOperation(
                            BinaryOperation.ADD,
                            {Integer.one(),term2.expressions[1]}
                        )
                    end
                    if not revertterm1 and revertterm2 then
                        result = BinaryOperation(
                            BinaryOperation.ADD,
                            {term1.expressions[1],Integer.one()}
                        )
                    end
                    if revertterm1 and revertterm2 then
                        result = Integer(2)
                    end
                    result = result:autosimplify()
                    for i=findex,#term1.expressions do
                        result = BinaryOperation(
                            BinaryOperation.MUL,
                            {result,term1.expressions[i]}
                        )
                    end
                    result = result:autosimplify()
                    if result:isconstant() and result == result:zero() then
                        return BinaryOperation(BinaryOperation.ADD, {})
                    end
                    return BinaryOperation(BinaryOperation.ADD, {result})
                end
            end

            if term1.operation ~= BinaryOperation.MUL or not term1.expressions[1]:isconstant() then
                term1 = BinaryOperation(BinaryOperation.MUL,{Integer.one(), term1})
                revertterm1 = true
            end
            if term2.operation ~= BinaryOperation.MUL or not term2.expressions[1]:isconstant() then
                term2 = BinaryOperation(BinaryOperation.MUL, {Integer.one(), term2})
                revertterm2 = true
            end
            if ArrayEqual(term1.expressions, term2.expressions, 2) then
                local result = BinaryOperation(
                    BinaryOperation.ADD,
                    {term1.expressions[1],term2.expressions[1]}
                )
                result = result:autosimplify()
                for i=2,#term1.expressions do
                    result = BinaryOperation(
                        BinaryOperation.MUL,
                        {result,term1.expressions[i]}
                )
                end
                result = result:autosimplify()
                --local result = BinaryOperation(BinaryOperation.MUL,
                --                    {BinaryOperation(BinaryOperation.ADD,
                --                        {term1.expressions[1],
                --                        term2.expressions[1]}):autosimplify(),
                --                    term1.expressions[2]}):autosimplify()
                if result:isconstant() and result == result:zero() then
                    return BinaryOperation(BinaryOperation.ADD, {})
                end
                return BinaryOperation(BinaryOperation.ADD, {result})
            end

            if revertterm1 then
                term1 = term1.expressions[2]
            end
            if revertterm2 then
                term2 = term2.expressions[2]
            end

            if term2:order(term1) then
                return BinaryOperation(BinaryOperation.ADD, {term2, term1})
            end

            return self
        end

        if term1.operation == BinaryOperation.ADD and not (term2.operation == BinaryOperation.ADD) then
            return term1:mergesums(BinaryOperation(BinaryOperation.ADD, {term2}))
        end

        if not (term1.operation == BinaryOperation.ADD) and term2.operation == BinaryOperation.ADD then
            return BinaryOperation(BinaryOperation.ADD, {term1}):mergesums(term2)
        end

        return term1:mergesums(term2)
    end

    local rest = {}
    for index, expression in ipairs(self.expressions) do
        if index > 1 then
            rest[index - 1] = expression
        end
    end

    local result = BinaryOperation(BinaryOperation.ADD, rest):simplifysumrec()

    if term1.operation ~= BinaryOperation.ADD then
        term1 = BinaryOperation(BinaryOperation.ADD, {term1})
    end
    if result.operation ~= BinaryOperation.ADD then
        result = BinaryOperation(BinaryOperation.ADD, {result})
    end
    return term1:mergesums(result)
end

-- Merges two lists of sums
function BinaryOperation:mergesums(other)
    if not self.expressions[1] then
        return other
    end

    if not other.expressions[1] then
        return self
    end

    local first = BinaryOperation(BinaryOperation.ADD, {self.expressions[1], other.expressions[1]}):simplifysumrec()

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

    if first.operation ~= BinaryOperation.ADD or not first.expressions[2] then
        local result = BinaryOperation(self.operation, selfrest):mergesums(BinaryOperation(other.operation, otherrest))
        if not first.expressions[1] then
            return result
        end
        if first.expressions[1] ~= Integer.zero(0) then
            table.insert(result.expressions, 1, first.expressions[1])
        end
        return result
    end

    local result
    if first.expressions[1] == self.expressions[1] then
        result = BinaryOperation(self.operation, selfrest):mergesums(other)
    else
        result = self:mergesums(BinaryOperation(other.operation, otherrest))
    end

    table.insert(result.expressions, 1, first.expressions[1])

    return result
end
