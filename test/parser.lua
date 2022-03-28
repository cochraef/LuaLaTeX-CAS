-- Rudimentary parser for making the CAS easier to use. Essentially just wraps SymbolExpression() around symbols and Integer() around integers.


require("calculus._init")

-- A list of symbols and functions that have special meaning and aren't converted to symbol expressions.
local constants = {e="E", pi = "PI", ln = "LN", log = "LOG", DD = "DD", int = "INT"}

-- Lua keywords that also aren't converted into syntax.
local keywords = {"and","break","do","else","elseif","end","false","for","function","goto","if","in","local","nil","not","or","repeat","return","then","true","until","while"}



-- Splits a string on a seperator.
function split(str, sep)
    local t={}
    for match in string.gmatch(str, "([^".. sep .."]+)") do
            t[#t+1] = match
    end
    return t
end

-- Displays an expression. For use in the parser.
function disp(expression)
    tex.print(expression:autosimplify():tolatex())
end

-- Parses raw input into Lua code and executes it.
function CASparse(input)

    -- First, we replace any occurrence of a number with an integer or rational version of itself.
    local str = string.gsub(input, ".?[0-9]+", function (s)
        -- Here, we are part of an identifier, so we don't replace anything
        if string.match(string.sub(s, 1, 1), "[A-Z]") or string.match(string.sub(s, 1, 1), "[a-z]") or string.match(string.sub(s, 1, 1), "_") then
            return;
        end

        if string.match(string.sub(s, 1, 1), "[0-9]") then
            return "Integer('" .. s .. "')"
        end

        return string.sub(s, 1, 1) .. "Integer('" .. string.sub(s, 2, #s) .. "')"
    end)

    --------------------------
    -- HERE COMES THE JANK. --
    --------------------------

    -- Replaces each instance of a decimal with .., so we can use integer metatables to convert it into a rational properly.
    str = string.gsub(str, "Integer%('[0-9]+'%)%.Integer%('[0-9]+'%)", function (s)
        local ints = split(s, "%.")
        return ints[1] .. ".." .. ints[2]
    end)
    str = string.gsub(str, ".?%.Integer%('[0-9]+'%)", function (s)
        if string.sub(s, 1, 2) == ".." then
            return;
        end
        return string.sub(s, 1, 1) .. "Integer('0')." .. string.sub(s, 2, #s)
    end)

    -- Next, we break the input into separate lines. This means we can't put multiple assignments on one line without a semicolon, but I AM NOT DOING CFGS TO DETERMINE WHEN EXPRESSIONS END YOU CAN'T MAKE ME YOU"LL NEVER TAKE ME ALIVE CHOMSKY.
    local lines = split(str, "\n;")
    for _, line in ipairs(lines) do
        -- On each line, we replace variables, but only if they aren't assigned or a keyword, or being assigned
        local parts = split(line, "=")
        local run = ""
        if #parts == 2 then
            line = parts[2]
            run = parts[1] .. "="
        end
        run = run .. string.gsub(line, ".?%a%w*", function (s)

            -- Ignores method calls.
            local first = ""
            if string.sub(s, 1, 1) == "." or string.sub(s, 1, 1) == ":" then
                return
            elseif not string.match(string.sub(s, 1, 1), "%a") then
                first = string.sub(s, 1, 1)
                s = string.sub(s, 2, #s)
            end
            -- LUA keyword check
            for _, keyword in ipairs(keywords) do
                if s == keyword then
                    return
                end
            end

            -- assigned variable check
            local exe, err = load("return " .. s .." == nil")
            if exe() == nil then
                print(err)
            end

            if not exe() then
                return;
            end

            -- CAS symbol check
            for word, replace in pairs(constants) do
                if s == word then
                    return first .. replace
                end
            end

            return first .. "SymbolExpression('" .. s .. "')"

        end)

        print(run)
        local exe, err = load(run .. "\n return true")
        if exe then
            exe()
        else
            print(err)
        end
    end
end


parse("x = 2; y = x + z; disp(y)")