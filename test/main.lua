---@diagnostic disable: lowercase-global
-- Runs test code from test files.

require("calculus._init")
require("_lib.pepperfish")

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

function test(actual, expected, initial, sort)
    if sort and type(actual) == "table" and not actual.type then
        table.sort(actual, function (a, b)
            return a:order(b)
        end)
    elseif sort and type(actual) == "table" and actual.type and actual:type() == BinaryOperation and (actual.operation == BinaryOperation.MUL or actual.operation == BinaryOperation.ADD) then
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

require("test.calculus.derivatives")
require("test.calculus.integrals")

require("test.expressions.autosimplify")
require("test.expressions.simplify")
require("test.expressions.functions")
-- require("test.expressions.rationalexponent")
require("test.expressions.substitute")

require("test.polynomials.polynomial")
require("test.polynomials.partialfractions")
require("test.polynomials.polynomialmod")
require("test.polynomials.roots")

require("test.rings.modulararithmetic")
require("test.rings.number")

endall()

-- profiler:stop()

-- local outfile = io.open( "profile.txt", "w+" )
-- profiler:report( outfile )
-- outfile:close()