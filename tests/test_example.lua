-- Ajusta caminhos do LuaRocks local
package.path  = os.getenv("HOME").."/.luarocks/share/lua/5.1/?.lua;" .. package.path
package.cpath = os.getenv("HOME").."/.luarocks/lib/lua/5.1/?.so;" .. package.cpath

-- Ajusta caminho para o módulo src
package.path = "./src/?.lua;" .. package.path

-- Importa módulos
local luaunit = require("luaunit")
local calc = require("calc")

-- Define testes
TestCalc = {}

function TestCalc:testAdd()
    luaunit.assertEquals(calc.add(2, 3), 5)
end

function TestCalc:testSub()
    luaunit.assertEquals(calc.sub(10, 4), 6)
end

-- Roda os testes
os.exit(luaunit.LuaUnit.run())
