require("polynomial.polynomial")

local a = Polynomial({
    Integer(1),
    Integer(2),
    Integer(3),
    Integer(4),
    Integer(5)
})

local b = Polynomial({
    Integer(1) / Integer(3),
    Integer(1) / Integer(12),
    Integer(6) / Integer(3),
})

local c = Polynomial({
    Integer(12),
    Integer(4)
})

print("Testing polynomial addition and subtraction...")
print(b)
print(a + a)
print(a + b)
print(b + a)
print(a - b)
print(b:multiplyDegree(4))
print(a:multiplyDegree(12))
print()

print("Testing polynomial degrees...")
print(a:getDegree())
print(b:getDegree())
print(b:multiplyDegree(4):getDegree())
print()

print("Testing polynomial multiplication...")
print(c * c)
print(a * c)
print(c * a)
print(b * c)

-- Unfortunately operator overloading can only return one value, and we need to return two - the quotient and the remainder
print("Testing polynomial division...")
print(a:divide(c))
print(a:divide(b))
print(b:divide(c))
