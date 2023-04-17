--- @class LuaCAS
--- @class Module
--- A table that initalizes and stores luacas modules.
--- @field moduleinfo table<string, table>
--- @field core Module
--- @field algebra Module
--- @field calculus Module
local luacas = {}


-- a table containing a list of module names, descriptions, class names, variables, required files, and dependent modules
luacas.moduleinfo = {
    ["core"]=
    {
        "Classes needed for creating basic expressions such as symbols, binary operations, and functions.",
        {
            "Expression",
            "AtomicExpression",
            "CompoundExpression",
            "ConstantExpression",
            "SymbolExpression",
            "BinaryOperation",
            "FunctionExpression",

            "__ExpressionOperations"
        },
        {"E", "I", "PI"},
        {
            "_lib.luacas-table",
            "core.luacas-expression",
            "core.luacas-atomicexpression",
            "core.luacas-compoundexpression",
            "core.luacas-constantexpression",
            "core.luacas-symbolexpression",
            "core.luacas-binaryoperation",
            "core.luacas-functionexpression",
            "core.binaryoperation.luacas-power",
            "core.binaryoperation.luacas-product",
            "core.binaryoperation.luacas-sum",
            "core.binaryoperation.luacas-quotient",
            "core.binaryoperation.luacas-difference",
        },
        {}
    },

    ["algebra"]=
    {
        "Classes for elements of rings (integers, rationals, polynomials, etc., and operations on those elements (polynomial factoring). Also includes some elementary functions like logs and trig functions.",
        {
            "Ring",
            "EuclideanDomain",
            "Field",
            "PolynomialRing",
            "Integer",
            "Rational",
            "IntegerModN",
            "SqrtExpression",
            "AbsExpression",
            "Equation",
            "FactorialExpression",
            "Logarithm",
            "RootExpression",
            "TrigExpression",

            "__RingOperations", -- Not classes, but we need to set the environment for this
            "__EuclideanOperations",
            "__FieldOperations",
            "__PolynomialOperations",
            "__IntegerOperations",
            "__IntegerModNOperations",
            "__RationalOperations"
        },
        {"ABS", "ARCCOS", "ARCCOT", "ARCCSC", "ARCSEC", "ARCSIN", "ARCTAN", "COS", "COT", "CSC", "FACT", "LN", "LOG", "SEC", "SIN", "TAN"},
        {
            "algebra.luacas-ring",
            "algebra.luacas-euclideandomain",
            "algebra.luacas-field",
            "algebra.luacas-polynomialring",
            "algebra.luacas-integer",
            "algebra.luacas-rational",
            "algebra.luacas-integerquotientring",
            "algebra.luacas-sqrtexpression",
            "algebra.luacas-absexpression",
            "algebra.luacas-equation",
            "algebra.luacas-factorialexpression",
            "algebra.luacas-logarithm",
            "algebra.luacas-rootexpression",
            "algebra.luacas-trigexpression",
            "algebra.polynomialring.luacas-berlekampfactoring",
            "algebra.polynomialring.luacas-zassenhausfactoring",
            "algebra.polynomialring.luacas-decomposition"
        },
        {"core"}
    },

    ["calculus"]=
    {
        "Classes for symbolic differentation and integration.",
        {
            "DerivativeExpression",
            "IntegralExpression",
            "DiffExpression"
        },
        {"DD", "INT"},
        {
            "calculus.luacas-derivativeexpression",
            "calculus.luacas-integralexpression",
            "calculus.luacas-diffexpression"
        },
        {"algebra"}
    }
}

--- Retrieves a short description for a module.
--- @param mod string
--- @return string
function luacas:moduledesc(mod)
    if self.moduleinfo[mod] then
        return self.moduleinfo[mod][1]
    end
    return "Module not found."
end

--- Retrieves a list of class names included in a module.
--- @param mod string
--- @return table<number,string>
function luacas:moduleclasses(mod)
    if self.moduleinfo[mod] then
        return self.moduleinfo[mod][2]
    end
    return {}
end

--- Retrieves a list of fields included in a module.
--- @param mod string
--- @return table<number,string>
function luacas:modulefields(mod)
    if self.moduleinfo[mod] then
        return self.moduleinfo[mod][3]
    end
    return {}
end

--- Retrieves a list of files included in a module.
--- @param mod string
--- @return table<number,string>
function luacas:modulefiles(mod)
    if self.moduleinfo[mod] then
        return self.moduleinfo[mod][4]
    end
    return {}
end

--- Retrieves a list of a module's immediate dependencies.
--- @param mod string
--- @return table<number,string>
function luacas:moduledependencies(mod)
    if self.moduleinfo[mod] then
        return self.moduleinfo[mod][5]
    end
    return {}
end

--- Initalizes a LuaCAS module and returns it.
--- Since this creates temporary global variables, it should be treated as atomic to avoid collisions.
--- @param mod string
--- @return Module|nil
function luacas:initmodule(mod)
    if not self.moduleinfo[mod] then
        return nil
    end

    -- TODO: This is a special case, since the algebra module is dependent on the core module and vice versa,
    -- but our initialization scheme does not allow for circular dependencies.
    if mod == "core" then
        self:initmodule("algebra")
    end

    -- Since other modules require globals from their dependencies, we only remove global variables after all modules have been initalized
    local G = self:saveglobalstate()
    self:_initmodulerec(mod)
    self:restoreglobalstate(G)

    return self[mod]
end

--- Recursive part of initalizing modules.
--- @param mod string
function luacas:_initmodulerec(mod)

    for _, dep in ipairs(self:moduledependencies(mod)) do
        self:_initmodulerec(dep)
    end

    if self[mod] then
        -- Since globals from a dependency might be needed to initialize a module, we create globals even if a module has already been initalized.
        for class, _ in self[mod] do
            _G[class] = self[mod][class]
        end
    else
        -- Creates globals needed for modules dependent on this one.
        self:initglobalmodule(mod)

        -- Adds classes to module table.
        self[mod] = {}
        for _, class in ipairs(self:moduleclasses(mod)) do
            self[mod][class] = _G[class]
        end

        -- Sets the environment for each method of each class to include all dependent classes of this class.
        self:setmoduleenvironment(mod)
        -- TODO: This is a special case, since the algebra module is dependent on the core module and vice versa,
        -- but our initialization scheme does not allow for circular dependencies.
        if mod == "algebra" then
            self:setmoduleenvironment("core")
        end

        -- Adds fields to module tables
        for _, class in ipairs(self:modulefields(mod)) do
            self[mod][class] = _G[class]
        end
    end
end

--- Sets the environment for each method of each class in a module to the current global environment, so it can keep using global variables when reset.
--- @param mod string
function luacas:setmoduleenvironment(mod)
    local realenv = self:saveglobalstate()
    for _, class in pairs(self[mod]) do
        -- print(_)
        for _, func in pairs(class) do
            -- print("    ", _)
            if type(func) == "function" then
                --- Functions only have an _ENV upvalue if they have a global variable, so this should work
                local _envloc = debug.findupvalue(func, "_ENV")
                if _envloc then
                    debug.upvaluejoin(func, debug.findupvalue(func, "_ENV"), function () return realenv end, 1)
                end
            end
        end

        -- local meta = getmetatable(class)
        -- if meta then
        --     for _, func in pairs(meta) do
        --         print("    ", _)
        --         if type(func) == "function" then
        --             --- Functions only have an _ENV upvalue if they have a global variable, so this should work
        --             local _envloc = debug.findupvalue(func, "_ENV")
        --             if _envloc then
        --                 debug.upvaluejoin(func, debug.findupvalue(func, "_ENV"), function () return realenv end, 1)
        --             end
        --         end
        --     end
        -- end
    end
end

--- Saves the current global state as a table and returns it.
--- @return table
function luacas:saveglobalstate()
    local G = {}
    for key, value in pairs(_G) do
        G[key] = value
    end
    return G
end

--- Saves the current global state as a table and returns it.
--- @param G table
function luacas:restoreglobalstate(G)
    for key, _ in pairs(_G) do
        if key ~= "_G" and key ~= "pairs" then
            _G[key] = nil
        end
    end
    for key, value in pairs(G) do
        _G[key] = value
    end
end

--- Initalizes a LuaCAS module and creates global variables for all classes in that module.
--- DOES NOT HANDLE DEPENDENCIES, so dependent modules must be globally initalized first.
--- @param mod string
--- @return Module|nil
function luacas:initglobalmodule(mod)
    for _, filename in ipairs(self:modulefiles(mod)) do
        require(filename)
    end
end

--- Why is Lua like this?
function debug.findupvalue(fn, search_name)
    local i = 1
    while true do
      local name, val = debug.getupvalue(fn, i)
      if not name then break end
      if name == search_name then
        return i, val
      end
      i = i + 1
    end
end

return luacas