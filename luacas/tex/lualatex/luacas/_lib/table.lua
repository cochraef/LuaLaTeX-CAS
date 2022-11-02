-- Checks if two arrays are equal, starting at index i
function ArrayEqual(a1, a2, i)
    i = i or 1
    while i <= math.max(#a1, #a2) do
        if a1[i] ~= a2[i] then
            return false
        end
        i = i + 1
    end
    return true
end

-- Checks if two arrays are equal, the first starting at index i, the second starting at index j
function FancyArrayEqual(a1, a2, i, j)
    i = i or 1
    j = j or 1
    while i <= math.max(#a1, #a2) or j <= math.max(#a1, #a2) do
        if a1[i] ~= a2[j] then
            return false
        end
        i = i + 1
        j = j + 1
    end
    return true
end

-- Creates a copy of a table
function Copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
        copy = setmetatable(copy, getmetatable(orig))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Joins two arrays
function JoinArrays(a1, a2)
    local a = Copy(a1)
    for index, value in ipairs(a2) do
        a[index + #a1] = value
    end
    return a
end

-- Joins two arrays indexed from zero
function JoinZeroArrays(a1, a2)
    local a = Copy(a1)
    a[#a1 + 1] = a2[0]
    for index, value in ipairs(a2) do
        a[index + #a1 + 1] = value
    end
    return a
end

-- Join two tables, using the second entry if a key appears in both tables
function JoinTables(t1, t2)
    local t = Copy(t1) or {}
    for key, value in pairs(t2) do
        t[key] = value
    end
    return t
end

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

-- Converts an array to a string recursively
function ToStringArray(t)
    if string.sub(tostring(t), 1, 6) == "table:" then
        local out = "{"
        for index, value in ipairs(t) do
            out = out .. ToStringArray(value)
            if t[index + 1] then
                out = out .. ", "
            end
        end
        return out .. "}"
    end
    return tostring(t)
end

-- Converts a table to a string recursively
function ToStringTable(t)
    if string.sub(tostring(t), 1, 6) == "table:" then
        local out = "{"
        for index, value in pairs(t) do
            out = out .. ToStringTable(index) .. " : " .. ToStringTable(value)
            if t[index + 1] then
                out = out .. ", "
            end
        end
        return out .. "}"
    end
    return tostring(t)
end

-- Check if a table contains an element, and returns the index of that element if it does
function Contains(t, e)
    for index, value in pairs(t) do
        if value == e then
            return index
        end
    end
    return false
end

-- Given an array a of unique elements, returns an array of the n-element subarrays of a
function Subarrays(a, m)
    local aout = {}
    local l = 1
    local newmax = {}

    if(m <= 0) then
        return {{}}, {0}
    end

    local rec, max = Subarrays(a, m - 1)

    for recindex, set in pairs(rec) do
        for index, element in pairs(a) do
            if not set[element] and index > max[recindex] then
                local new = Copy(set)
                new[#new+1] = element
                aout[l] = new
                if not newmax[l] or index > newmax[l] then
                    newmax[l] = index
                end
                l = l + 1
            end
        end
    end

    return aout, newmax
end