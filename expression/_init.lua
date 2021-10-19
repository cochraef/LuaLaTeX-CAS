-- Loads expression files in the correct order.

require("expression.expression")
require("expression.atomicexpression")
require("expression.symbolexpression")
require("expression.compoundexpression")
require("expression.binaryoperation")
require("expression.functionexpression")
require("expression.logarithm")
require("expression.derrivativeexpression")
require("expression.constant")

require("expression.binaryoperation.power")
require("expression.binaryoperation.product")
require("expression.binaryoperation.sum")
require("expression.binaryoperation.quotient")
require("expression.binaryoperation.difference")