-- Automatically handles conversion between different integer types.

-- This will work for now, but eventually we will want to specify what argument we want to convert
-- i.e., rational + integer should convert the second, but rational + real should convert the first
function convert_type(object, type)
    if Rational.is(type) then
        return object:torational()
    end
end