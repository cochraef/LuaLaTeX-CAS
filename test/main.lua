require("algebra._init")


local constants = {e="E", pi = "PI", ln = "LN", log = "LOG", Integer = "Integer", DD = "DD"}

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


print(parse("(x-1)*(x-2)*(x-3)*(x-4)*(x-5)/-120"):autosimplify():tolatex())