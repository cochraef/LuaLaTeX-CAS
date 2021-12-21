require("_lib.table.copy")

-- Given an array, removes all occurances of that element from the array
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

-- Given an array, removes all elements in the second array from the first
function RemoveAll(a1, a2)
    local r = Copy(a1)
    local removed = 0
    for index, value in ipairs(r) do
        if a2[value] then
            removed = removed + 1
        end
        if removed then
            r[index] = r[index + removed]
        end
    end
    return r
end

-- Given an array of arrays, returns only the arrays that have no elements in common with the second array
function RemoveAny(aa, a)
    local toremove = {}
    for _, v in ipairs(aa) do
        for _, v1 in ipairs(v) do
            for _, v2 in ipairs(a) do
                if v1 == v2 then
                    toremove[#toremove+1] = v
                    goto endcheck
                end
            end
        end
        ::endcheck::
    end
    return RemoveAll(aa, toremove)
end