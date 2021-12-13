require("_lib.table.copy")

-- Given an array a of unique elements, returns an array of the n-element subarrays of a
function Subarrays(a, m)
    local aout = {}
    local l = 1;
    local newmax = {};

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
                l = l + 1;
            end
        end
    end

    return aout, newmax
end