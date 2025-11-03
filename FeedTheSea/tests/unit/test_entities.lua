-- Ajusta caminho para a lib de testes
package.path = "../lib/?.lua;" .. package.path

-- Ajusta caminho para o código-fonte do projeto
package.path = "../../src/?.lua;" .. package.path

-- Ajusta caminho para libs internas chamadas com 'src.lib.*'
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
        remove = function(path) fake_fs[path] = nil end,
        getSaveDirectory = function() return "." end
    }
}

-- Mock do arquivo entities.json
fake_fs["data/entities.json"] = [[
    {
        "fish": {
            "fish001": {
                "name": "Sardinha",
                "sprite": "sardine.png",
                "diet": "herbivore",
                "size": 0.5,
                "oxygen_cost": 0.35,
                "nutrient_cost": 0.1,
                "biomass_production": 0.025
            }
        },
        "plant": {
            "plant001": {
                "name": "Alga",
                "sprite": "seaweed.png",
                "oxygen_production": 1,
                "nutrient_value": 0.5,
                "biomass_cost": 2.5,
                "size": 0.35,
                "w": 380,
                "h": 387
            }
        }
    }]]

-- Importa módulos
local luaunit = require("luaunit")     -- framework de testes
local entities = require("entitiesManager")  -- módulo local em src/entitiesManager.lua

-- Define testes
TestEntities = {}

-- Carregamento das entidades
function TestEntities:testLoadEntities()
    local data = entities.loadEntities()

    -- verifica se os dados foram carregados corretamente
    luaunit.assertIsTable(data)

    -- verifica se os dados dos peixes estão corretos
    luaunit.assertNotNil(data.fish, "Os dados dos peixes devem estar presentes.")
    luaunit.assertEquals(data.fish['fish001'].name, "Sardinha")

    -- verifica se os dados das plantas estão corretos
    luaunit.assertIsTable(data)
    luaunit.assertNotNil(data.plant, "Os dados dos peixes devem estar presentes.")
    luaunit.assertEquals(data.plant['plant001'].name, "Alga")

end

-- obtenção de planta por ID
function TestEntities:testGetFishById()
    -- obtém peixe pelo ID
    local fish = entities.getFishById("fish001")

    -- verifica se os dados do peixe estão corretos
    luaunit.assertIsTable(fish)
    luaunit.assertEquals(fish.name, "Sardinha")
    luaunit.assertEquals(fish.size, 0.5)

    -- verifica retorno para ID inexistente
    luaunit.assertIsNil(entities.getFishById("nonexistent_id"))
end

-- obtenção de planta por ID
function TestEntities:testGetPlantById()
    -- obtém planta pelo ID
    local plant = entities.getPlantById("plant001")

    -- verifica se os dados da planta estão corretos
    luaunit.assertIsTable(plant)
    luaunit.assertEquals(plant.name, "Alga")
    luaunit.assertEquals(plant.size, 0.35)

    -- verifica retorno para ID inexistente
    luaunit.assertIsNil(entities.getPlantById("nonexistent_id"))
end

-- Roda os testes
os.exit(luaunit.LuaUnit.run())