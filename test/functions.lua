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

local a = FunctionExpression("f",
            {SymbolExpression("x"),
            BinaryOperation.MULEXP
                ({SymbolExpression("x"),
                Integer(2)})})

local b = BinaryOperation.ADDEXP
            ({FunctionExpression("g",
                {SymbolExpression("x")}),
            FunctionExpression("f",
                {SymbolExpression("x")}),
                Integer(4)})

print("Testing function expressions...")
test(a:autosimplify(), "f(x, (2 * x))", a)
test(b:autosimplify(), "(4 + f(x) + g(x))", b)