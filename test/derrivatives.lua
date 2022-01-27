require("algebra._init")

local function test(actual, expected, initial)
    if initial then
        if tostring(expected) == tostring(actual) then
            print(tostring(initial) .. " -> " .. tostring(actual))
        else
            print(tostring(initial) .. " -> " .. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
        end
    else
        if tostring(expected) == tostring(actual) then
            print("Result: " .. tostring(actual))
        else
            print("Result: ".. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
        end
    end
end

local a = DD(SymbolExpression("x"), SymbolExpression("x") * SymbolExpression("y"))
local b = DD(SymbolExpression("x"), Integer(3) * SymbolExpression("x") ^ Integer(2) + Integer(2) * SymbolExpression("x") + Integer(6))
local c = DD(SymbolExpression("x"), E ^ SymbolExpression("x"))
local d = DD(SymbolExpression("x"), FunctionExpression("f", {SymbolExpression("x") ^ Integer(2)}))
local e = DD(SymbolExpression("x"), SymbolExpression("x") ^ SymbolExpression("x"))
local f = DD(SymbolExpression("x"), PolynomialRing({Integer(3), Integer(4), Integer(5)}, "x"))
local g = DD(SymbolExpression("y"), LN(SymbolExpression("y")))
local h = DD(SymbolExpression("x"), SymbolExpression("x") ^ SymbolExpression("n"))

local i = DD(SymbolExpression("x"), SIN((SymbolExpression("x"))));
local j = DD(SymbolExpression("x"), SIN(Integer(2) * COS(SymbolExpression("x"))));
local k = DD(SymbolExpression("x"), ARCTAN(SymbolExpression("x") ^ (Integer(1) / Integer(2))))
local l = DD(SymbolExpression("x"), ARCSEC(SymbolExpression("x")))

print("Testing Differentiation...")
test(a, "(d/dx (x * y))")
test(a:autosimplify(), "y", a)
test(b:autosimplify(), "(2 + (6 * x))", b)
test(c:autosimplify(), "(e ^ x)", c)
test(d:autosimplify(), "(2 * x * f'((x ^ 2)))", d)
test(e:autosimplify(), "((x ^ x) * (1 + log(e, x)))", e)
test(f:autosimplify(), "(4 + (10 * x))", f)
test(g:autosimplify(), "(y ^ -1)", g)
test(h:autosimplify(), "(n * (x ^ (-1 + n)))", h)
test(i:autosimplify(), "cos(x)", i)
test(j:autosimplify(), "(-2 * sin(x) * cos((2 * cos(x))))", j)
test(k:autosimplify(), "(1/2 * (x ^ -1/2) * ((1 + x) ^ -1))", k)
test(l:autosimplify(), "((|x| ^ -1) * ((1 + (-1 * (x ^ 2))) ^ -1/2))", l)