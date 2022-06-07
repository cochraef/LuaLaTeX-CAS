-- Rudimentary parser for making the CAS easier to use. Essentially just wraps SymbolExpression() around symbols and Integer() around integers.



require("calculus._init")

-- Splits a string on a seperator.
function split(str, sep)
    local t={}
    for match in string.gmatch(str, "([^".. sep .."]+)") do
            t[#t+1] = match
    end
    return t
end

-- Displays an expression. For use in the parser.
function disp(expression, inline)
    if type(expression) ~= "table" then
        tex.print(tostring(expression))
    elseif expression.autosimplify then
        if inline then
            tex.print('$' .. expression:autosimplify():tolatex() .. '$')
        else
            tex.print('\\[' .. expression:autosimplify():tolatex() .. '\\]')
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

function factor(exp)
    if exp:type() == Integer then
        return exp:primefactorization()
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

-- Constants for the CAS. We may not want these in Lua itself, but in the latex end the user probably expects them.
e = E
pi = PI
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

function ZTable(t)
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
            return;
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
            return;
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


CASparse([[
    vars("x", "y", "z")
    a = ((6 + ((1 + (2 * x)) * (-1 + (3 * x)))) * ((6 * y) + (-1 * z)))
    displua(a)
    displua(simplify(a))
]])