-- Represents an arbitrary real number in Lua. Just a dummy class right now.
Real = {}
__Real = {}

function Real:new()
    local o = {}
    __Real.index = Real
    setmetatable(o, {__Real})

    return o
end