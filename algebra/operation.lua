-- Represents an arbitrary n-ary operation with a single output
-- Operations have the following static variables:
--      operation - a function that applys the operation to each argument
--      operands - a nonnegative Integer representing the number of operands the operation is applied to
--      domain - an array of sets of possible input values for each argument
--      codomain - a set of possible output values for the domain
Operation = {}

----------------------------
-- Instance functionality --
----------------------------

-- Returns the type of an object
function Operation:getType()
    return "Operation"
end