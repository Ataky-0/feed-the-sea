local luaunit = require("luaunit")
local calc = require("src.calc")

TestCalc = {}

function TestCalc:testAdd()
    luaunit.assertEquals(calc.add(2, 3), 5)
end

function TestCalc:testSub()
    luaunit.assertEquals(calc.sub(10, 4), 6)
end

os.exit(luaunit.LuaUnit.run())
