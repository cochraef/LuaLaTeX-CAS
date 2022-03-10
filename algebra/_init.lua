-- Loads algebra files in the correct order.
require("_lib.table")

require("core._init")

require("algebra.ring")
require("algebra.euclideandomain")
require("algebra.field")
require("algebra.polynomialring")
require("algebra.integer")
require("algebra.rational")
require("algebra.integerquotientring")

require("algebra.absexpression")
require("algebra.logarithm")
require("algebra.rootexpression")
require("algebra.trigexpression")

require("algebra.polynomialring.berlekampfactoring")
require("algebra.polynomialring.zassenhausfactoring")
require("algebra.polynomialring.decomposition")