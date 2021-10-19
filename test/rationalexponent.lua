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

local a = BinaryOperation.POWEXP({Integer(8), Integer(1) / Integer(2)})
local b = BinaryOperation.POWEXP({Integer(27), Integer(1) / Integer(3)})
local c = BinaryOperation.POWEXP({Integer(36), Integer(1) / Integer(2)})
local d = BinaryOperation.POWEXP({Integer(36264691), Integer(1) / Integer(2)})
local e = BinaryOperation.POWEXP({Integer(357911), Integer(1) / Integer(2)})
local f = BinaryOperation.ADDEXP({BinaryOperation.POWEXP({Integer(8), Integer(1) / Integer(2)}), BinaryOperation.POWEXP({Integer(32), Integer(1) / Integer(2)})})

print("Testing rational power simplification ... ")
test(a:autosimplify(), "(2 * (2 ^ 1/2))", a)
test(b:autosimplify(), "3", b)
test(c:autosimplify(), "6", c)
test(d:autosimplify(), "(331 * (331 ^ 1/2))", d)
test(e:autosimplify(), "(71 * (71 ^ 1/2))", e)
test(f:autosimplify(), "(6 * (2 ^ 1/2))", f)