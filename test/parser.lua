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
function disp(expression)
    if expression.autosimplify then
        tex.print(expression:autosimplify():tolatex())
    else
        tex.print(tostring(expression))
    end
end

-- Displays an expression. For use in the parser.
function displua(expression)
    if expression.autosimplify then
        print(expression:autosimplify():tolatex())
    else
        print(tostring(expression))
    end
end

function vars(...)
    for _, string in ipairs(table.pack(...)) do
        _G[string] = SymbolExpression(string)
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

--- Parses raw input into Lua code and executes it.
--- @param input string
function CASparse(input)

    print(input)

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

    print(str)

    -- Now, we convert back to boring Lua numbers if we are using numeric for loops.
    -- str = str.gsub(str, "%sfor%s+%a%w*%s*=.+,.+do", function (s)
    --     local out = " for "
    --     s = string.sub(s, 5, #s)
    --     local parts = split(str, "[%s|,|=]")

    --     out = out .. parts[1] .. "=(" .. parts[2] .. "):asnumber(),(" .. parts[3] .. "):asnumber()"

    --     if parts[4] then
    --         out = out .. ",(" .. parts[4] .. "):asnumber() do"
    --     else
    --         out = out .. " do"
    --     end

    --     return out
    -- end)

    print(str)

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

    print(str)

    local exe, err = load(str .. "\n return true")
    if exe then
        exe()
    else
        print(err)
    end
end

CASparse([[
    vars("x", "y", "z")
    for i in range(-5, 5) do
        displua(i / x)
    end
]])