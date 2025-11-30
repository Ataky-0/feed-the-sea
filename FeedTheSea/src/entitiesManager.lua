-- entitiesManager.lua
local json = require("src.lib.lunajson")

local entitiesManager = {}

-- Obtém os dados de um lixo pelo seu ID
function entitiesManager.getWasteById(id)
    local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
    local waste = entities.waste and entities.waste[id]
    if waste then
			waste.id = id
			return waste
    end
    return nil
end

-- Obtém os dados de um peixe pelo seu ID
function entitiesManager.getFishById(id)
    local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
    local fish = entities.fish and entities.fish[id]
    if fish then
			fish.id = id
			return fish
    end
    return nil
end

-- Obtém os dados de uma planta pelo seu ID
function entitiesManager.getPlantById(id)
    local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
    local plant = entities.plant and entities.plant[id]
    if plant then
			plant.id = id
			return plant
    end
    return nil
end

-- Carrega o arquivo entities.json e retorna a tabela de dados
function entitiesManager.loadEntities()
	local fileContent = love.filesystem.read("data/entities.json")
	if not fileContent then
		error("Não foi possível carregar entities.json")
	end

	local data = json.decode(fileContent)
	return data
end

-- Retorna a lista completa de peixes existentes
function entitiesManager.getFishList()
	local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
	local fishList = {}

	-- Iterar sobre os peixes na estrutura existente
	for fishId, fishData in pairs(entities.fish or {}) do
		fishData.id = fishId -- Adicionar o ID ao objeto
		table.insert(fishList, fishData)
	end

	table.sort(fishList, function(a, b)
		return a.id < b.id
	end)

	return fishList
end

-- Retorna a lista completa de plantas existentes
function entitiesManager.getPlantList()
	local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
	local plantList = {}

	-- Iterar sobre as plantas na estrutura existente
	for plantId, plantData in pairs(entities.plant or {}) do
		plantData.id = plantId -- Adicionar o ID ao objeto
		table.insert(plantList, plantData)
	end

	table.sort(plantList, function(a, b)
		return a.id < b.id
	end)

	return plantList
end

-- Retorna a lista completa de lixos existentes
function entitiesManager.getWasteList()
	local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
	local wasteList = {}

	-- Iterar sobre os lixos na estrutura existente
	for wasteId, wasteData in pairs(entities.waste or {}) do
		wasteData.id = wasteId -- Adicionar o ID ao objeto
		table.insert(wasteList, wasteData)
	end

	return wasteList
end

return entitiesManager
