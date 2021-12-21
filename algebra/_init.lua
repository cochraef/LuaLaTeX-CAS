-- Loads algebra files in the correct order.
bn = require("_lib.nums.bn")
require("_lib.table.copy")
require("_lib.table.join")
require("_lib.table.remove")
require("_lib.table.subarrays")

require("expression._init")

require("algebra.ring")
require("algebra.euclideandomain")
require("algebra.field")
require("algebra.polynomialring")
require("algebra.integer")
require("algebra.rational")
require("algebra.integerquotientring")