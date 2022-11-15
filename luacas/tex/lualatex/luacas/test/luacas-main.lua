---@diagnostic disable: lowercase-global
-- Runs test code from test files.

require("calculus.luacas-calculus_init")
require("_lib.luacas-pepperfish")

-- Stuff required for the basic parser.
local constants = {e="E", pi = "PI", ln = "LN", log = "LOG", Integer = "Integer", DD = "DD", int = "INT", abs = "ABS", fact="FACT"}

local function parser(s)
    if string.find(s, "[0-9]+") then
        return "Integer(\"" .. s .. "\")"
    end

    if s.find(s, "[%^%\\%[%]]") then
        return string.gsub(s, "[^%^%\\%[%]]+", parser)
    end

    for string, replace in pairs(constants) do
        if s == string then
            return replace
        end
    end

    return "SymbolExpression(\"" .. s .. "\")"
end

function parse(input)
    local parsed = string.gsub(input, "[0-9]+", parser)
    parsed = string.gsub(parsed, "[A-z']+", parser)
    local exe, err = load("return " .. parsed)
    if exe then
        return exe():autosimplify()
    else
        print(err)
    end
end

function dparse(input)
    local parsed = string.gsub(input, "[0-9]+", parser)
    parsed = string.gsub(parsed, "[A-z']+", parser)
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

-- Tests two objects for equality, irrespective of order. If the object is a table or expression, the objects may be sorted to ensure the correct order.
function testeq(actual, expected, initial, sort)
    if sort and type(actual) == "table" and not actual.type then
        table.sort(actual, function (a, b)
            return a:order(b)
        end)
    elseif sort and type(actual) == "table" and actual.type and actual:type() == BinaryOperation and actual:iscommutative() then
        table.sort(actual.expressions, function (a, b)
            return a:order(b)
        end)
    end

    if initial then
        if ToStringArray(expected) == ToStringArray(actual) then
            print(ToStringArray(initial) .. " -> " .. ToStringArray(actual))
        else
            print(ToStringArray(initial) .. " -> " .. ToStringArray(actual) .. " (Expected: " .. ToStringArray(expected) .. ")")
            failures = failures + 1
        end
    else
        if ToStringArray(expected) == ToStringArray(actual) then
            print("Result: " .. ToStringArray(actual))
        else
            print("Result: ".. ToStringArray(actual) .. " (Expected: " .. ToStringArray(expected) .. ")")
            failures = failures + 1
        end
    end
    tests = tests + 1
end

-- Tests whether converting an element to a different ring produces the expected object in the expected ring
function testringconvert(expression, toring, expected, expectedring)
    testeq(expression:inring(toring), expected, expression)
    testeq(expression:inring(toring):getring(), expectedring)
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


-- TODO: Add profiling and error catching options.
-- Comment out these lines to only run certain test code.

-- profiler = newProfiler()
-- profiler:start()

require("test.calculus.luacas-derivatives")
require("test.calculus.luacas-integrals")

require("test.expressions.luacas-autosimplify")
require("test.expressions.luacas-collect")
require("test.expressions.luacas-equations")
require("test.expressions.luacas-simplify")
require("test.expressions.luacas-functions")
require("test.expressions.luacas-logarithms")
-- require("test.expressions.luacas-rationalexponent")
require("test.expressions.luacas-substitute")

require("test.polynomials.luacas-polynomial")
require("test.polynomials.luacas-partialfractions")
require("test.polynomials.luacas-polynomialmod")
require("test.polynomials.luacas-roots")

require("test.rings.luacas-conversion")
require("test.rings.luacas-modulararithmetic")
require("test.rings.luacas-number")

endall()

-- profiler:stop()

-- local outfile = io.open( "profile.txt", "w+" )
-- profiler:report( outfile )
-- outfile:close()