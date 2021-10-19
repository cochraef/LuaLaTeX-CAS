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

local a = LN(SymbolExpression("x"))
local b = LN(BinaryOperation.POWEXP({E, SymbolExpression("x")}))
local c = BinaryOperation.POWEXP({Integer(2), LOG(Integer(2), SymbolExpression("y"))})


print("Testing logarithm expressions..." )
test(a, "log(e, x)")
test(a:autosimplify(), "log(e, x)", a)
test(b:autosimplify(), "x", b)
test(c:autosimplify(), "y", c)