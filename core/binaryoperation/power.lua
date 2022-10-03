-- Seperates the various binary operations into their own files for readability

--- Automatic simplification of power expressions.
--- @return BinaryOperation
function BinaryOperation:simplifypower()
    local base = self.expressions[1]
    local exponent = self.expressions[2]

    if base:isconstant() and exponent:isconstant() and exponent:getring() ~= Rational:getring() then
        return self:evaluate()
    end

    -- Simplifies i^x for x integer.
    if base == I and exponent:isconstant() and exponent:getring() == Integer:getring() then
        if exponent % Integer(4) == Integer(0) then
            return Integer(1)
        end
        if exponent % Integer(4) == Integer(1) then
            return I
        end
        if exponent % Integer(4) == Integer(2) then
            return Integer(-1)
        end
        if exponent % Integer(4) == Integer(3) then
            return -I
        end
    end

    -- Simplifies complex numbers raised to negative integer powers
    if not base:isrealconstant() and base:iscomplexconstant() and exponent:isconstant() and exponent:getring() == Integer:getring() and exponent < Integer.zero() then
        local a
        local b
        if base.operation == BinaryOperation.MUL then
            a = Integer.zero()
            b = base.expressions[1]
        elseif base.operation == BinaryOperation.ADD and base.expressions[2] == I then
            a = base.expressions[1]
            b = Integer.one()
        else
            a = base.expressions[1]
            b = base.expressions[2].expressions[1]
        end
        return (((a-b*I)/(a^Integer(2)+b^Integer(2)))^(-exponent)):expand():autosimplify()
    end

    -- Uses the property that 0^x = 0 if x does not equal 0
    if base:isconstant() and base == base:zero() then
        return Integer.zero()
    end

    -- Uses the property that 1^x = 1
    if base:isconstant() and base == base:one() then
        return base:one()
    end

    -- Uses the property that x^0 = 1
    if exponent:isconstant() and exponent == exponent:zero() then
        return exponent:one()
    end

    -- Uses the property that x^1 = x
    if exponent:isconstant() and exponent == exponent:one() then
        return base
    end

    -- Uses the property that b ^ (log(b, x)) == x
    if exponent:type() == Logarithm and exponent.base == base then
        return exponent.expression
    end

    -- Uses the property that b ^ (a * log(b, x)) == x ^ a
    if exponent.operation == BinaryOperation.MUL then
        local x
        local rest = Integer.one()
        for _, expression in ipairs(exponent.expressions) do
            if expression:type() == Logarithm and expression.base == base and not log then
                x = expression.expression
            else
                rest = rest * expression
            end
        end
        if x then
            return (x ^ rest):autosimplify()
        end
    end

    -- Uses the property that (x^a)^b = x^(a*b)
    if not base:isatomic() and base.operation == BinaryOperation.POW and exponent:isconstant() then
        base, exponent = base.expressions[1], BinaryOperation(BinaryOperation.MUL, {exponent, base.expressions[2]}):autosimplify()
        return BinaryOperation(BinaryOperation.POW, {base, exponent}):autosimplify()
    end

    -- Uses the property that (x_1*x_2*...*x_n)^a = x_1^a*x_2^a*..x_n^a if a is an integer
    if base.operation == BinaryOperation.MUL and exponent:type() == Integer then
        local results = {}
        for index, expression in ipairs(base.expressions) do
            results[index] = BinaryOperation(BinaryOperation.POW, {expression, exponent}):autosimplify()
        end
        return BinaryOperation(BinaryOperation.MUL, results):autosimplify()
    end

    -- Uses the property that sqrt(x,r)^d == sqrt(x,r/d)
    if base:type() == SqrtExpression and exponent:type() == Integer and exponent > Integer.zero() then
        local root = base.root
        local expr = base.expression
        local comm = Integer.gcd(root,exponent)
        root = root / comm
        local expo = exponent / comm
        expr = expr ^ expo
        return SqrtExpression(expr,root):autosimplify()
    end

    -- Rationalizing SqrtExpressions
    if base:type() == SqrtExpression and exponent:type() == Integer and base.expression:type() == Integer and exponent < Integer.zero() then
        local root = base.root
        local expr = base.expression
        local result =  (SqrtExpression(expr ^ (root - Integer.one()),root) / expr) ^ exponent:neg()
        return result:autosimplify()
    end

    if base:isconstant() and exponent:isconstant() and exponent:getring() == Rational.getring() then
        return self --:simplifyrationalpower()
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

    if base == Integer(-1) then
        if exponent == Integer(1) / Integer(2) then
            return I
        end

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

    return BinaryOperation(BinaryOperation.POW, {primes:autosimplify(), exponent})
end