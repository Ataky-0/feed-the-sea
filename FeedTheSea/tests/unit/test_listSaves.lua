-- Ajusta caminho para libs internas
package.path = "../../src/?.lua;" .. package.path
package.path = "../../src/lib/?.lua;" .. package.path
package.path = "../../?.lua;" .. package.path

-- Mock básico do LÖVE para testes fora do engine
local fake_fs = {}
_G.love = {
    filesystem = {
        createDirectory = function(_) end,
        getInfo = function(path) return fake_fs[path] and { type = "file" } or nil end,
        write = function(path, data)
            fake_fs[path] = data
            return true
        end,
        read = function(path) return fake_fs[path] end,
        getSaveDirectory = function() return "." end
    }
}

-- Importa módulos
local luaunit = require("luaunit")
local saves = require("savesManager")

-- Define testes
TestListSaves = {}

function TestListSaves:testListSaves()
    local savesList = saves.listSaves()
    luaunit.assertIsTable(savesList)
end

-- Roda os testes
os.exit(luaunit.LuaUnit.run())
