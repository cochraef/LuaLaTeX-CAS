require(table)

--- Constructs a new interface object. This is a type that cannot be instantiated, however, it may still have implemented methods
--- like an abstract class in Java added after the table is constructed.
--- @param requiredmethods table<number, string>
--- @param superinterfaces table<number, table>|nil
--- @return table
function INTERFACE(requiredmethods, superinterfaces)
    local interface = {}

    for _, name in ipairs(requiredmethods) do
        interface[name] = function(self)
            error("Called unimplemeted method: " .. name .. "()")
        end
    end

    if superinterfaces then
        setmetatable(interface, {__index = function(t, k)
            for _, super in ipairs(superinterfaces) do
                local v = super[k]
                if type(v) == "function" then
                    t[k] = v
                    return v
                end
            end
        end})
    end

    return interface
end

--- Constructs a new class object. This can be instantiated with the :new() method passed in the parameter constructor. The metatable
--- is assigned to each new object that is instantiated from the class, not the class itself.
--- @param superclasses table<number, table> | nil
--- @param metatable table
--- @return table
function CLASS(constructor, superclasses, metatable)
    local class = {}
    local __o = Copy(metatable)
    __o.__index = class
    class.new = function(...)
        local o = constructor(...)
        setmetatable(o, __o)
        return o
    end
    local __class = {__call = class.new}
    if superclasses then
        __class.__index = function(t, k)
            for _, super in ipairs(superclasses) do
                local v = super[k]
                if type(v) == "function" then
                    t[k] = v
                    return v
                end
            end
        end
    end
    setmetatable(class, __class)
    return __class
end
