-- Seperates the various binary operations into their own files for readability

-- Automatic simplification of quotient expressions
function BinaryOperation:simplifyquotient()
    local numerator = self.expressions[1]
    local denominator = self.expressions[2]

    if numerator:isevaluatable() and denominator:isevaluatable() then
        return self:evaluate()
    end

    return BinaryOperation(BinaryOperation.MUL, {numerator, BinaryOperation(BinaryOperation.POW, {denominator, Integer(-1)}):autosimplify()}):autosimplify()
end