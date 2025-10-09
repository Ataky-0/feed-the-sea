-- Ajusta caminho para a lib de testes
package.path = "../lib/?.lua;" .. package.path

-- Ajusta caminho para o código-fonte do projeto
package.path = "../../src/?.lua;" .. package.path

-- Importa módulos
local luaunit = require("luaunit")  -- framework de testes
local calc = require("calc")        -- módulo local em src/calc.lua

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
