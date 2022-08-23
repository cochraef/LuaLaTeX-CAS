-- Loads core files in the correct order.

require("core.expression")
require("core.atomicexpression")
require("core.compoundexpression")
require("core.constantexpression")
require("core.symbolexpression")
require("core.binaryoperation")
require("core.functionexpression")


require("core.binaryoperation.power")
require("core.binaryoperation.product")
require("core.binaryoperation.sum")
require("core.binaryoperation.quotient")
require("core.binaryoperation.difference")