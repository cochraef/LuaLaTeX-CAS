-- Loads algebra files in the correct order.
require("_lib.luacas-table")

require("core.luacas-core_init")

require("algebra.luacas-ring")
require("algebra.luacas-euclideandomain")
require("algebra.luacas-field")
require("algebra.luacas-polynomialring")
require("algebra.luacas-integer")
require("algebra.luacas-rational")
require("algebra.luacas-integerquotientring")
require("algebra.luacas-sqrtexpression")

require("algebra.luacas-absexpression")
require("algebra.luacas-equation")
require("algebra.luacas-factorialexpression")
require("algebra.luacas-logarithm")
require("algebra.luacas-rootexpression")
require("algebra.luacas-trigexpression")

require("algebra.polynomialring.luacas-berlekampfactoring")
require("algebra.polynomialring.luacas-zassenhausfactoring")
require("algebra.polynomialring.luacas-decomposition")