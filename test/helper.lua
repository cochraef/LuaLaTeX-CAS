-- helper functions


 function whatis(a)
    if a == nil then 
        return nil
    end
    if a:type() == SymbolExpression then 
        return "SymbExp"
    end 
    if a:type() == BinaryOperation then 
        return "BinOp"
    end 
    if a:type() == FunctionExpression then 
        return "FnExp"
    end 
    if a:type() == TrigExpression then 
        return "TrigExp"
    end 
    if a:type() == Integer then 
        return "Int"
    end 
    if a:type() == Rational then 
        return "Ratl"
    end
    if a:type() == DerivativeExpression then 
        return "DervExp"
    end
    if a:type() == DiffExpression then 
        return "DiffExp" 
    end
    return "No Clue"
end 

function nameof(sym)
    if sym == nil then
        return nil
    end
    if sym:type() == BinaryOperation then 
        local binops = {BinaryOperation.ADD,
            BinaryOperation.MUL,
            BinaryOperation.SUB,
            BinaryOperation.DIV,
            BinaryOperation.POW,
            BinaryOperation.IDIV,
            BinaryOperation.MOD}
        local obslab = {"ADD",
            "MUL",
            "SUB",
            "DIV",
            "POW",
            "IDIV",
            "MOD"}
        for i,j in pairs(binops) do 
            if sym.operation == j then 
                return obslab[i]
            end
        end
    end
    if sym:type() == FunctionExpression or sym:type() == TrigExpression then 
        return tostring(sym.name)
    end
    if sym:type() == SymbolExpression or sym:type() == Integer then 
        return tostring(sym)
    end
    if sym:type() == Rational then 
        return tostring(sym.numerator).."/"..tostring(sym.denominator)
    end
    if sym:type() == DerivativeExpression then 
        return "D"
    end
    if sym:type() == DiffExpression then 
        return "Diff" 
    end
    return "No Clue"
end

function Expression:getfullsubexpressionsrec()
    local result = {}
    for _, expression in ipairs(self:subexpressions()) do
        result[#result+1] = expression
        result = JoinArrays(result, expression:getfullsubexpressionsrec())
    end
    return result
end

function Expression:gettheshrub()
    local string = ""
    for _, expression in ipairs(self:subexpressions()) do
        string = string.."child {node [label=-90:{"..whatis(expression).."}] {$\\mathtt{"..expression:tolatex().."}$}}"
    end
    return string
end

function Expression:getthetree()
    local string = ""
    for _, expression in ipairs(self:subexpressions()) do
        if expression:isatomic() then 
            string = string.."child {node{"..nameof(expression).."}}"
        else
            string = string.."child {node{"..nameof(expression).."}"..expression:getthetree().."}"
        end
    end
    return string
end

function Expression:gettheforest()
    local string = ""
    for _, expression in ipairs(self:subexpressions()) do
        if expression:isatomic() then 
            string = string.." [ "..nameof(expression).." ] "
        else
            string = string.." [ "..nameof(expression)..expression:gettheforest().." ] "
        end
    end
    return string
end

