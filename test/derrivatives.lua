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

print("Testing Differentiation...")
test(a, "(d/dx (x * y))")
test(a:autosimplify(), "y", a)
test(b:autosimplify(), "(2 + (6 * x))", b)
test(c:autosimplify(), "(e ^ x)", c)