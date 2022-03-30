-- Seperates the various binary operations into their own files for readability

--- Automatic simplification of difference expressions.
--- @return BinaryOperation
function BinaryOperation:simplifydifference()
    local term1 = self.expressions[1]
    local term2 = self.expressions[2]

    if not term2 then
        return BinaryOperation(BinaryOperation.MUL, {Integer(-1), term1}):autosimplify()
    end

    return BinaryOperation(BinaryOperation.ADD, {term1, BinaryOperation(BinaryOperation.MUL, {Integer(-1), term2}):autosimplify()}):autosimplify()
end