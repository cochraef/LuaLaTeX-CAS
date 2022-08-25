-- helper functions


 function whatis(a)
    if a == nil then
        return nil
    end
    if a:type() == SymbolExpression then
        return "Sym"
    end
    if a:type() == BinaryOperation then
        return "BinOp"
    end
    if a:type() == FunctionExpression then
        return "FncExp"
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
    if a:type() == IntegralExpression then 
        return "Intgrl"
    end
    if a:type() == SqrtExpression then 
        return "Sqrt"
    end
    return "No Clue"
end

function longwhatis(a)
    if a == nil then
        return nil
    end
    if a:type() == SymbolExpression then
        return "SymbolExpression"
    end
    if a:type() == BinaryOperation then
        return "BinaryOperation"
    end
    if a:type() == FunctionExpression then
        return "FunctionExpression"
    end
    if a:type() == TrigExpression then
        return "TrigExpression"
    end
    if a:type() == Integer then
        return "Integer"
    end
    if a:type() == Rational then
        return "Rational"
    end
    if a:type() == DerivativeExpression then
        return "DerivativeExpression"
    end
    if a:type() == DiffExpression then
        return "DiffExpression"
    end
    if a:type() == IntegralExpression then 
        return "IntegralExpression" 
    end
    if a:type() == SqrtExpression then 
        return "SqrtExpression" 
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
        return "Derv"
    end
    if sym:type() == DiffExpression then
        return "Diff"
    end
    if sym:type() == IntegralExpression then 
        return "$\\mathtt{\\int}$" 
    end
    if sym:type() == SqrtExpression then 
        return "$\\mathtt{\\sqrt{\\phantom{x}}}$"
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
    for index, expression in ipairs(self:subexpressions()) do
        string = string.."child {node [label=-90:{expr["..tostring(index).."]}] {$\\mathtt{"..expression:tolatex().."}$}}"
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

function Expression:getthefancyshrub()
    local string = ""
    if self:type() == DiffExpression then 
        for _, expression in ipairs(self:subexpressions()) do
            string = string.." [ $\\mathtt{"..expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ] "
        end
        string = string.." [ $\\mathtt{\\{"
        for _,symbol in ipairs(self.symbols) do 
            if next(self.symbols,_) == nil then 
                string = string .. symbol:tolatex().."\\}}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.symbols};} ] "
            else
                string = string .. symbol:tolatex() .. "," 
            end
        end
        return string
    end
    if self:type() == IntegralExpression then 
        string = string .. " [ $\\mathtt{"..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ] "
        string = string .. "[ $\\mathtt{"..self.symbol:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.symbol};} ]"
        if self:isdefinite() then 
            string = string .. "[ $\\mathtt{"..self.lower:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.lower};} ] "
            string = string .. "[ $\\mathtt{"..self.upper:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.upper};} ] "
            return string 
        end 
        return string
    end
    if self:type() == SqrtExpression then 
        string = string .. " [ $\\mathtt{"..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ]"
        string = string .. "[ $\\mathtt{"..self.root:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.root};} ]"
        return string
    end
    for index, expression in ipairs(self:subexpressions()) do
        string = string.." [ $\\mathtt{"..expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression["..index.."]};} ] "
    end
    return string
end

