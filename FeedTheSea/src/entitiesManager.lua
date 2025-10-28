-- entitiesManager.lua
local json = require("src.lib.lunajson")

local entitiesManager = {}

function entitiesManager.loadEntities()
	local fileContent = love.filesystem.read("data/entities.json")
	if not fileContent then
		error("Não foi possível carregar entities.json")
	end

	local data = json.decode(fileContent)
	return data
end

function entitiesManager.getFishList()
	local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
	local fishList = {}

	-- Iterar sobre os peixes na estrutura existente
	for fishId, fishData in pairs(entities.fish or {}) do
		fishData.id = fishId -- Adicionar o ID ao objeto
		table.insert(fishList, fishData)
	end

	return fishList
end

function entitiesManager.getPlantList()
	local entities = assert(entitiesManager.loadEntities(), "Erro ao obter entidades")
	local plantList = {}

	-- Iterar sobre as plantas na estrutura existente
	for plantId, plantData in pairs(entities.plant or {}) do
		plantData.id = plantId -- Adicionar o ID ao objeto
		table.insert(plantList, plantData)
	end

	return plantList
end

return entitiesManager
