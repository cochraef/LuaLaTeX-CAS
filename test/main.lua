---@diagnostic disable: lowercase-global
-- Runs test code from test files.

require("algebra._init")

-- Stuff required for the basic parser.
local constants = {e="E", pi = "PI", ln = "LN", log = "LOG", Integer = "Integer", DD = "DD", int = "INT"}

local function parser(s)
    if string.find(s, "[0-9]+") then
        return "Integer('" .. s .. "')"
    end

    if s.find(s, "[%^%\\%[%]]") then
        return string.gsub(s, "[^%^%\\%[%]]+", parser)
    end

    for string, replace in pairs(constants) do
        if s == string then
            return replace
        end
    end

    return "SymbolExpression('" .. s .. "')"
end

function parse(input)
    local parsed = string.gsub(input, "[0-9]+", parser)
    parsed = string.gsub(parsed, "[A-z]+", parser)
    local exe, err = load("return " .. parsed)
    if exe then
        return exe():autosimplify()
    else
        print(err)
    end
end

function dparse(input)
    local parsed = string.gsub(input, "[0-9]+", parser)
    parsed = string.gsub(parsed, "[A-z]+", parser)
    local exe, err = load("return " .. parsed)
    if exe then
        return exe()
    else
        print(err)
    end
end

-- Stuff required for test code.
local tests
local failures
local totaltests = 0
local totalfailures = 0
function starttest(name)
    print("Testing " .. name .. "...")
    print()
    tests = 0
    failures = 0
end

function test(actual, expected, initial)
    if initial then
        if tostring(expected) == tostring(actual) then
            print(tostring(initial) .. " -> " .. tostring(actual))
        else
            print(tostring(initial) .. " -> " .. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
            failures = failures + 1
        end
    else
        if tostring(expected) == tostring(actual) then
            print("Result: " .. tostring(actual))
        else
            print("Result: ".. tostring(actual) .. " (Expected: " .. tostring(expected) .. ")")
            failures = failures + 1
        end
    end
    tests = tests + 1
end

function endtest()
    print()
    print("Finished test without errors.")
    print()
    totaltests = totaltests + tests
    totalfailures = totalfailures + failures
    if failures == 0 then
        print("Performed " .. tests .. " tests, all of which passed!")
    else
        print("Performed tests, " .. failures .. "/" .. tests .. " failed.")
    end
    print("=====================================================================================================================")
end

function endall()
    if totalfailures == 0 then
        print("Performed " .. totaltests .. " tests in total, all of which passed!")
    else
        print("Performed tests, " .. totalfailures .. "/" .. totaltests .. " failed.")
    end
end


-- TODO: Add profiling option.
-- Comment out these lines to only run certain test code.
-- require("test.calculus.derrivatives")
-- require("test.calculus.integrals")

-- require("test.expressions.autosimplify")
-- require("test.expressions.expand")
-- require("test.expressions.functions")
-- require("test.expressions.rationalexponent")
-- require("test.expressions.substitute")

-- require("test.polynomials.polynomial")
require("test.polynomials.partialfractions")
-- require("test.polynomials.polynomialmod")
-- require("test.polynomials.roots")

-- require("test.rings.modulararithmetic")
-- require("test.rings.number")
endall()