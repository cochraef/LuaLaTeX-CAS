local a = IntegerModN(Integer(5), Integer(3))
local b = IntegerModN(Integer(1), Integer(3))
local c = IntegerModN(Integer(-12), Integer(3))
local f = IntegerModN(Integer(100), Integer(62501))
local d = IntegerModN(Integer(16), Integer(36))
local e = IntegerModN(Integer(27), Integer(36))

starttest("modular arithmetic")
test(a, "2")
test(b, "1")
test(c, "0")
test(a + b, "0")
test(a - b, "1")
test(a * b, "2")
test(a:inv(), "2")
test(b:inv(), "1")
test(f:inv(), "61876")
test(d * e, "0")
test(a * d, "2")
endtest()