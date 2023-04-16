--- @class ConstantExpression
--- @alias Constant ConstantExpression
--- Interface for a mathematical expression without any symbols.
--- ConstantExpressions are AtomicExpressions by default, but individual classes may overwrite that inheritance.
ConstantExpression = {}
local __ConstantExpression = {}

----------------------
-- Instance methods --
----------------------


--- @param symbol SymbolExpression
--- @return boolean
function ConstantExpression:freeof(symbol)
    return true
end

--- @return boolean
function ConstantExpression:isconstant()
    return true
end

--- @param other Expression
--- @return boolean
function ConstantExpression:order(other)

    -- Constants come before non-constants.
    if not other:isconstant() then
        return true
    end

    if self ~= E and self ~= PI and self ~= I then
        if other ~= E and other ~= PI and other ~= I then
            -- If both self and other are ring elements, we use the total order on the ring to sort.
            return self < other
        end
        -- Special constants come after ring elements.
        return true
    end

    -- Special constants come after ring elements.
    if other ~= E and other ~= PI and other ~= I then
        return false
    end

    -- Ensures E < PI < I.

    if self == E then return true end

    if self == I then return false end

    return other == I
end

-----------------
-- Inheritance --
-----------------

__ConstantExpression.__index = AtomicExpression
ConstantExpression = setmetatable(ConstantExpression, __ConstantExpression)

