-- Rudimentary parser for making the CAS easier to use. Essentially just wraps SymbolExpression() around symbols and Integer() around integers.



require("calculus.luacas-calculus_init")

-- Splits a string on a seperator.
function split(str, sep)
    local t={}
    for match in string.gmatch(str, "([^".. sep .."]+)") do
            t[#t+1] = match
    end
    return t
end

-- Displays an expression. For use in the parser.
function disp(expression, inline, simple)
    if type(expression) ~= "table" then
        tex.print(tostring(expression))
    elseif expression.autosimplify then
        if inline then
            if simple then
                tex.print('$' .. expression:autosimplify():tolatex() .. '$')
            else
                tex.print('$' .. expression:tolatex() .. '$')
            end
        else
            if simple then
                tex.print('\\[' .. expression:autosimplify():tolatex() .. '\\]')
            else
                tex.print('\\[' .. expression:tolatex() .. '\\]')
            end
        end
    else
        tex.print(tostring(expression))
    end
end

-- Displays an expression. For use in the parser.
function displua(expression)
    if type(expression) ~= "table" then
        print(tostring(expression))
    elseif expression.autosimplify then
        print(expression:autosimplify():tolatex())
    else
        print(tostring(expression))
    end
end

function vars(...)
    for _, string in ipairs(table.pack(...)) do
        if string ~= "_" then
            _G[string] = SymbolExpression(string)
        end
    end
end

function clearvars()
    for index, value in pairs(_G) do
        if type(value) == "table" and value.type and value:type() == SymbolExpression then
            _G[index] = nil
        end
    end
end

function range(a, b, step)
    if not b then
      b = a
      a = Integer.one()
    end
    step = step or Integer.one()
    local f =
      step > Integer.zero() and
        function(_, lastvalue)
          local nextvalue = lastvalue + step
          if nextvalue <= b then return nextvalue end
        end or
      step < Integer.zero() and
        function(_, lastvalue)
          local nextvalue = lastvalue + step
          if nextvalue >= b then return nextvalue end
        end or
        function(_, lastvalue) return lastvalue end
    return f, nil, a - step
  end

function factor(exp,squarefrei)
    if exp:type() == Integer then
        return exp:primefactorization()
    end
    if exp:type() == PolynomialRing then
        if not squarefrei then
            return exp:factor()
        else
            if exp.ring == Integer.getring() or Rational.getring() then
                return exp:squarefreefactorization()
            end
            if exp.ring == IntegerModN.getring() then
                return exp:modularsquarefreefactorization()
            end
            return exp:factor()
        end
    end
    return exp:autosimplify():factor()
end

function expand(exp)
    return exp:autosimplify():expand()
end

function simplify(exp)
    return exp:simplify()
end

function exp(x)
    return e^x
end

function substitute(tbl,expr)
    return expr:substitute(tbl)
end

function roots(expression)
    poly,ispoly = topoly(expression)
    if ispoly then
        return poly:roots()
    end
    return RootExpression(expression)
end

function combine(expr)
    return expr:combine()
end

function Mod(f,n)
    if f:type() == Integer then
        return IntegerModN(f,n)
    end
    if f:type() == PolynomialRing and f.ring == Integer.getring() then
        local coeffs = {}
        for i=0,f.degree:asnumber() do
            coeffs[i] = IntegerModN(f.coefficients[i],n)
        end
        return PolynomialRing(coeffs,f.symbol,f.degree)
    end
end

function Poly(coefficients,symbol,degree)
    local variable = symbol or 'x'
    return PolynomialRing:new(coefficients,variable,degree)
end

function topoly(a)
    a = a:expand():autosimplify()
    return a:topolynomial()
end

function gcd(a,b)
    if a:type() == Integer and b:type() == Integer then
        return Integer.gcd(a,b)
    end
    if a:type() == PolynomialRing and b:type() == PolynomialRing then
        return PolynomialRing.gcd(a,b)
    end
end

function gcdext(a,b)
    if a:type() == Integer and b:type() == Integer then
        return Integer.extendedgcd(a,b)
    end
    A, ATF = topoly(a)
    B, BTF = topoly(b)
    if ATF and BTF then
        return PolynomialRing.extendedgcd(A,B)
    end
    return nil,nil,nil
end

function parfrac(f,g,ffactor)
    local f,check1 = topoly(f)
    local g,check2 = topoly(g)
    if check1 and check2 then
        if f.degree >= g.degree then
            local q,r
            q,r = f:divremainder(g)
            return q + PolynomialRing.partialfractions(r,g,ffactor)
        else
            return PolynomialRing.partialfractions(f,g,ffactor)
        end
    else
        return f/g
    end
end

function factorial(a)
    return FactorialExpression(a)
end

-- Constants for the CAS. We may not want these in Lua itself, but in the latex end the user probably expects them.
e = E
pi = PI
-- sqrt = SQRT
ln = LN
log = LOG
int = INT
sin = SIN
cos = COS
tan = TAN
csc = CSC
sec = SEC
cot = COT
arcsin = ARCSIN
arccos = ARCCOS
arctan = ARCTAN
arccsc = ARCCSC
arcsec = ARCSEC
arccot = ARCCOT
abs = ABS

function ZTable(t)
    t = t or {}
    return setmetatable(t, JoinTables(getmetatable(t),
            {__index = function (t, k)
                    if type(k) == "table" and k.type and k:type() == Integer then
                        return rawget(t, k:asnumber())
                    else
                        return rawget(t, k)
                    end
                end,
             __newindex = function (t, k, v)
                    if type(k) == "table" and k.type and k:type() == Integer then
                        rawset(t, k:asnumber(), v)
                    else
                        rawset(t, k, v)
                    end
                end}))
end

function RR(n)
    if type(n) == "number" then
        return n
    end

    if type(n) == "string" then
        return tonumber(n)
    end

    if type(n) == "table" and n.asnumber then
        return n:asnumber()
    end

    error("Could not convert to a real number.")
end

function ZZ(n)
    if type(n) == "table" and n.type and n:type() == Rational then
        return n.numerator // n.denominator
    end
    return Integer(n)
end

function QQ(n)
    if type(n) == "table" then
        return n
    end

    if type(n) == "number" then
        n = tostring(n)
    end

    if type(n) == "string" then
        local parts = split(n, "%.")
        if #parts == 1 then
            return Integer(parts[1])
        else
            return Integer(parts[1])..Integer(parts[2])
        end
    end

    error("Could not convert to a rational number.")
end

--- Parses raw input into Lua code and executes it.
--- @param input string
function CASparse(input)

    -- First, we replace any occurance of a number with an integer or rational version of itself.
    local str = string.gsub(input, ".?[0-9]+", function (s)
        -- Here, we are part of an identifier, so we don't replace anything
        if string.match(string.sub(s, 1, 1), "[A-Z]") or string.match(string.sub(s, 1, 1), "[a-z]") or string.match(string.sub(s, 1, 1), "_") then
            return
        end

        if string.match(string.sub(s, 1, 1), "[0-9]") then
            return "Integer('" .. s .. "')"
        end

        return string.sub(s, 1, 1) .. "Integer('" .. string.sub(s, 2, #s) .. "')"
    end)

    --------------------------
    -- HERE COMES THE JANK. --
    --------------------------

    -- Replaces each instance of a decimal with .., so we can use integer metatables to convert it into a rational properly.
    str = string.gsub(str, "Integer%('[0-9]+'%)%.Integer%('[0-9]+'%)", function (s)
        local ints = split(s, "%.")
        return ints[1] .. ".." .. ints[2]
    end)
    str = string.gsub(str, ".?%.Integer%('[0-9]+'%)", function (s)
        if string.sub(s, 1, 2) == ".." then
            return
        end
        return string.sub(s, 1, 1) .. "Integer('0')." .. string.sub(s, 2, #s)
    end)

    local exe, err = load(str .. "\n return true")
    if exe then
        exe()
    else
        print(err)
    end
end