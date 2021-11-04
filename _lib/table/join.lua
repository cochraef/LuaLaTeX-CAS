-- Generic functions for joining lists and arrays in Lua.
require("_lib.table.copy")

function JoinArrays(a1, a2)
    a = Copy(a1)
    for index, value in ipairs(a2) do
        a[index + #a1] = value
    end
    return a
end