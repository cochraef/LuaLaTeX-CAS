require("algebra._init")

-- Read-eval-print loop for the CAS. Very basic right now, cannot handle arbitary functions, method calls like gcd, etc.

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

local input
while input ~= "break" do
    io.write("> ")
    input = io.read()
    local parsed = string.gsub(input, "[0-9]+", parser)
    parsed = string.gsub(parsed, "[A-z]+", parser)
    -- print(parsed)
    local exe, err = load("return " .. parsed)
    if exe then
        print(exe():autosimplify())
    else
        print(err)
    end
end