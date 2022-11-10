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
    if a:type() == PolynomialRing then
        return "Poly"
    end
    if a:type() == AbsExpression then
        return "ABS"
    end
    if a:type() == Logarithm then
        return "LOG"
    end
    if a:type() == RootExpression then
        return "RootOf"
    end
    if a:type() == Equation then
        return "="
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
    if a:type() == PolynomialRing then
        return "PolynomialRing"
    end
    if a:type() == AbsExpression then
        return "AbsExpression"
    end
    if a:type() == Logarithm then
        return "Logarithm"
    end
    if a:type() == RootExpression then
        return "RootExpression"
    end
    if a:type() == Equation then
        return "Equation"
    end
    return "No Clue"
end

function whatring(a)
    if a:getring() == Rational.makering() then
        return "Rational"
    end
    if a:getring() == PolynomialRing.makering() then
        return "PolynomialRing"
    end
    if a:getring() == Integer.makering() then
        return "Integer"
    end
    if a:getring() == IntegerModN.makering() then
        return "IntegerModN"
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
        return "DD"
    end
    if sym:type() == DiffExpression then
        return "diff"
    end
    if sym:type() == IntegralExpression then
        return "$\\mathtt{\\int}$"
    end
    if sym:type() == SqrtExpression then
        return "$\\mathtt{\\sqrt{\\phantom{x}}}$"
    end
    if sym:type() == PolynomialRing then
        return "Poly"
    end
    if sym:type() == AbsExpression then
        return "abs"
    end
    if sym:type() == Logarithm then
        return "log"
    end
    if sym:type() == RootExpression then
        return "RootOf"
    end
    if sym:type() == Equation then 
        return "$\\mathtt{=}$" 
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
    if self:type() == PolynomialRing then
        string = string .. " [ $\\mathtt{\\{"
        for index=0, self.degree:asnumber() do
            string = string .. tostring(self.coefficients[index])
            if index < self.degree:asnumber() then
                string = string .. ","
            end
        end
        string = string .. "\\} }$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.coefficients}; \\node[anchor=south west, font=\\ttfamily\\footnotesize,gray] at (.north west) {.ring "..whatring(self).."};} ]"
        string = string .. " [ $\\mathtt{"..self.symbol.. "}$, tikz+={\\node[anchor=north, font=\\ttfamily\\footnotesize,gray] at (.south) {.symbol};} ]"
        return string
    end
    if self:type() == SqrtExpression then
        string = string .. " [ $\\mathtt{"..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ]"
        string = string .. "[ $\\mathtt{"..self.root:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.root};} ]"
        return string
    end
    if self:type() == TrigExpression then
        string = string .. " [ $\\mathtt{"..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ]"
        return string
    end
    if self:type() == AbsExpression then
        string = string .. " [ $\\mathtt{"..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ] "
        return string
    end
    if self:type() == Logarithm then
        string = string .. " [$\\mathtt{" ..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ]"
        string = string .. " [$\\mathtt{" ..self.base:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray]  at (.south) {.base};} ]"
        return string
    end
    if self:type() == RootExpression then
        string = string .. "[$\\mathtt{" ..self.expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression};} ]"
        return string
    end
    if self:type() == FunctionExpression then
        local string1 = ''
        local string2 = ''
        local string3 = ''
        for index=1, #self.variables do
            string1 = string1 .. tostring(self.expressions[index])
            if index < #self.variables then
                string1 = string1 .. ","
            end
            string2 = string2 .. tostring(self.variables[index])
            if index < #self.variables then
                string2 = string2 .. ","
            end
            string3 = string3 .. tostring(self.derivatives[index])
            if index < #self.variables then
                string3 = string3 .. ","
            end
        end
        string = string .. "[$\\mathtt{ \\{" .. string1 .. "\\}}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expressions};} ]"
        string = string .. "[$\\mathtt{ \\{" .. string2 .. "\\}}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.variables};} ]"
        string = string .. "[$\\mathtt{ \\{" .. string3 .. "\\}}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.derivatives};} ]"
        return string
    end
    if self:type() == Equation then 
        string = string .. " [$\\mathtt{" ..self.lhs:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.lhs};} ]"
        string = string .. " [$\\mathtt{" ..self.rhs:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray]  at (.south) {.rhs};} ]"
        return string
    end
    for index, expression in ipairs(self:subexpressions()) do
        string = string.." [ $\\mathtt{"..expression:tolatex().."}$, tikz+={\\node[anchor=north,font=\\ttfamily\\footnotesize,gray] at (.south) {.expression["..index.."]};} ] "
    end
    return string
end

