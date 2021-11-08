-- Given an array, removes the first occurance of that element from the array
require("_lib.table.copy")

function Remove(a, e)
    local r = Copy(a)
    local found = false
    for index, value in ipairs(r) do
        if e == value then
            found = true
        end
        if found then
            r[index] = r[index + 1]
        end
    end
    return r
end