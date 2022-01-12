-- Loads algebra files in the correct order.
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

require("algebra.polynomialring.berlekampfactoring")
require("algebra.polynomialring.zassenhausfactoring")
require("algebra.polynomialring.decomposition")