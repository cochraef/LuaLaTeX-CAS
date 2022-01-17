-- Seperates the various binary operations into their own files for readability

-- Automatic simplification of power expressions
function BinaryOperation:simplifypower()
    local base = self.expressions[1]
    local exponent = self.expressions[2]

    if base:isEvaluatable() and exponent:isEvaluatable() and exponent:getring() == Rational.getring() then
        return self:simplifyrationalpower()
    end

    if base:isEvaluatable() and exponent:isEvaluatable() then
        return self:evaluate()
    end

    -- Uses the property that 0^x = 0 if x does not equal 0
    if base:isEvaluatable() and base == base:zero() then
        return Integer.zero()
    end

    -- Uses the property that 1^x = 1
    if base:isEvaluatable() and base == base:one() then
        return base:one()
    end

    -- Uses the property that x^0 = 1
    if exponent:isEvaluatable() and exponent == exponent:zero() then
        return exponent:one()
    end

    -- Uses the property that x^1 = x
    if exponent:isEvaluatable() and exponent == exponent:one() then
        return base
    end

    -- Uses the property that b^(log(b, x)) == x
    if exponent:type() == Logarithm and exponent.base == base then
        return exponent.expression
    end

    -- Uses the property that (x^a)^b = x^(a*b)
    if not base:isAtomic() and base.operation == BinaryOperation.POW then
        base, exponent = base.expressions[1], BinaryOperation(BinaryOperation.MUL, {exponent, base.expressions[2]}):autosimplify()
        return BinaryOperation(BinaryOperation.POW, {base, exponent})
    end

    -- Uses the property that (x_1*x_2*...*x_n)^a = x_1^a*x_2^a*..x_n^a
    if base.operation == BinaryOperation.MUL then
        local results = {}
        for index, expression in ipairs(base.expressions) do
            results[index] = BinaryOperation(BinaryOperation.POW, {expression, exponent}):autosimplify()
        end
        return BinaryOperation(BinaryOperation.MUL, results):autosimplify()
    end

    -- Our expression cannot be simplified
    return self
end

-- Automatic simplification of rational power expressions
function BinaryOperation:simplifyrationalpower()
    local base = self.expressions[1]
    local exponent = self.expressions[2]
    if base:getring() == Rational.getring() then
        return (BinaryOperation(BinaryOperation.POW, {base.numerator, exponent}):simplifyrationalpower()) /
                (BinaryOperation(BinaryOperation.POW, {base.denominator, exponent}):simplifyrationalpower())
    end

    -- Limit for attempting simplification of rational powers automatically
    if not BinaryOperation.RATIONALPOWERSIMPLIFICATIONLIMIT then
        BinaryOperation.RATIONALPOWERSIMPLIFICATIONLIMIT = Integer(Integer.DIGITSIZE)
    end

    -- Limit for attempting simplification of rational powers automatically
    if base > BinaryOperation.RATIONALPOWERSIMPLIFICATIONLIMIT then
        return self
    end

    local primes = base:primefactorization()

    if primes.expressions[1] and not primes.expressions[2] then
        local primeexponent = primes.expressions[1].expressions[2]
        local primebase = primes.expressions[1].expressions[1]
        local newexponent = primeexponent * exponent
        local integerpart
        if newexponent.getring() == Rational.getring() then
            integerpart = newexponent.numerator // newexponent.denominator
        else
            integerpart = newexponent
        end

        if integerpart == Integer.zero() then
            return BinaryOperation(BinaryOperation.POW, {primebase, newexponent})
        end
        return BinaryOperation(BinaryOperation.MUL,
                    {BinaryOperation(BinaryOperation.POW, {primebase, integerpart}),
                    BinaryOperation(BinaryOperation.POW, {primebase, newexponent - integerpart})}):autosimplify()
    end

    return BinaryOperation(BinaryOperation.POW, {primes, exponent}):simplifypower()
end