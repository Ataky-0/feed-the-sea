local json = require("src.lib.lunajson")

local savesManager = {}
local saveDir = "saves/"
local indexFile = "index.json"
local nextSaveOrder = 1
local saveIndex = {} -- array de metadados

-- Helpers -----------------------------------------------------------------

local function ensureSaveDir()
	if not love.filesystem.getInfo(saveDir, "directory") then
		love.filesystem.createDirectory(saveDir)
	end
end

local function getCurrentDate()
	return os.date("%Y-%m-%d %H:%M:%S")
end

local function loadIndex()
	ensureSaveDir()
	if love.filesystem.getInfo(indexFile) then
		local contents = love.filesystem.read(indexFile)
		saveIndex = json.decode(contents)
		for _, entry in ipairs(saveIndex) do
			if entry.order >= nextSaveOrder then
				nextSaveOrder = entry.order + 1
			end
		end
	else
		saveIndex = {}
	end
end

local function saveIndexFile()
	love.filesystem.write(indexFile, json.encode(saveIndex))
end

-- Estrutura padrão de save ------------------------------------------------
local function defaultSave()
	return {
		oxygen = 5,
		food = { herbivore = 0, carnivore = 0 },
		fish = {},
		producers = {},
		biomass = 10,
	}
end

-- Normaliza um save carregado para garantir campos novos
local function normalizeSave(save)
	local def = defaultSave()
	for k, v in pairs(def) do
		if save[k] == nil then
			save[k] = v
		end
	end
	return save
end

-- Operações ---------------------------------------------------------------

function savesManager.createSaveStruct()
	return defaultSave()
end

function savesManager.createSave(name)
	loadIndex()

	local save = savesManager.createSaveStruct()
	local filename = os.time() .. ".json"

	assert(love.filesystem.write(saveDir .. filename, json.encode(save)),
		"Erro durante criação de save, arquivo não gerado.")
	print(string.format("Novo save, %s, criado com sucesso.", filename))

	local meta = {
		order = nextSaveOrder,
		name = name or "nil",
		created_at = getCurrentDate(),
		last_played = getCurrentDate(),
		file = filename,
	}
	nextSaveOrder = nextSaveOrder + 1
	table.insert(saveIndex, meta)
	saveIndexFile()

	return save, meta
end

function savesManager.saveGame(save, filename)
	ensureSaveDir()
	love.filesystem.write(saveDir .. filename, json.encode(save))
	savesManager.updateLastPlayed(filename)
end

function savesManager.loadGame(filename)
	if love.filesystem.getInfo(saveDir .. filename) then
		local contents = love.filesystem.read(saveDir .. filename)
		local loaded = json.decode(contents)
		return normalizeSave(loaded)
	else
		return nil
	end
end

function savesManager.listSaves()
	loadIndex()
	table.sort(saveIndex, function(a, b) return a.order < b.order end)
	return saveIndex
end

function savesManager.updateLastPlayed(filename)
	loadIndex()
	for _, entry in ipairs(saveIndex) do
		if entry.file == filename then
			entry.last_played = getCurrentDate()
			saveIndexFile()
			break
		end
	end
end

function savesManager.deleteSave(filename)
	loadIndex()
	if love.filesystem.getInfo(saveDir .. filename) then
		love.filesystem.remove(saveDir .. filename)
	end
	for i, entry in ipairs(saveIndex) do
		if entry.file == filename then
			table.remove(saveIndex, i)
			break
		end
	end
	saveIndexFile()
end

return savesManager
