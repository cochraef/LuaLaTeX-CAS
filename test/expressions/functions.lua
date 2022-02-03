local a = FunctionExpression("f",
            {SymbolExpression("x"),
            BinaryOperation.MULEXP
                ({SymbolExpression("x"),
                Integer(2)})})

local b = BinaryOperation.ADDEXP
            ({FunctionExpression("g",
                {SymbolExpression("x")}),
            FunctionExpression("f",
                {SymbolExpression("x")}),
                Integer(4)})

starttest("function expressions")
test(a:autosimplify(), "f(x, (2 * x))", a)
test(b:autosimplify(), "(4 + f(x) + g(x))", b)
endtest()