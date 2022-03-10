-- Loads core files in the correct order.

require("core.expression")
require("core.atomicexpression")
require("core.symbolexpression")
require("core.compoundexpression")
require("core.binaryoperation")
require("core.functionexpression")

require("core.constant")

require("core.binaryoperation.power")
require("core.binaryoperation.product")
require("core.binaryoperation.sum")
require("core.binaryoperation.quotient")
require("core.binaryoperation.difference")