-- Loads algebra files in the correct order.
bn = require("lib.nums.bn")
require("lib.table.copy")

require("algebra.operation")
require("algebra.binaryoperation")
require("algebra.group")
require("algebra.ring")
require("algebra.field")
require("algebra.polynomialring")
require("algebra.integer")
require("algebra.rational")