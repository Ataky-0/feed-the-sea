-- savesManager.lua
local json = require("src.lib.lunajson")

local savesManager = {}
local saveDir = "saves/"
local indexFile = "index.json"
local nextSaveOrder = 1
local saveIndex = {} -- array de metadados

-- Garante que diretório de saves existe
local function ensureSaveDir()
	if not love.filesystem.getInfo(saveDir, "directory") then
		love.filesystem.createDirectory(saveDir)
	end
end

-- Obtém a data atual formatada
local function getCurrentDate()
	return os.date("%Y-%m-%d %H:%M:%S")
end

-- Carrega o arquivo de indexação (index.json)
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

-- Salva o arquivo de indexação
local function saveIndexFile()
	love.filesystem.write(indexFile, json.encode(saveIndex))
end

-- Estrutura padrão de save
local function defaultSave()
	return {
		oxygen = 5,
		food = { herbivore = 0, carnivore = 0 },
		fish = {},
		producers = {},
		waste = {},
		organic_matter = 10
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

-- Cria e retorna a estrutura padrão do save, para manter as chamadas de funções semânticas
function savesManager.createSaveStruct()
	return defaultSave()
end

-- Cria um novo save com o nome dado
function savesManager.createSave(name)
	loadIndex()

	assert(type(name) == "string" and not name:match("^%s*$"), "Nome do save não pode estar vazio.")

	local save = savesManager.createSaveStruct()
	local filename = os.time() .. ".json"

	assert(love.filesystem.write(saveDir .. filename, json.encode(save)),
		"Erro durante criação de save, arquivo não gerado.")
	print(string.format("Novo save, %s, criado com sucesso.", filename))

	local meta = {
		order = nextSaveOrder,
		name = name,
		created_at = getCurrentDate(),
		last_played = getCurrentDate(),
		file = filename,
	}
	nextSaveOrder = nextSaveOrder + 1
	table.insert(saveIndex, meta)
	saveIndexFile()

	return save, meta
end

-- Salva um save já existente
function savesManager.saveGame(save, filename)
	ensureSaveDir()
	love.filesystem.write(saveDir .. filename, json.encode(save))
	savesManager.updateLastPlayed(filename)
end

-- Carrega um save
function savesManager.loadGame(filename)
	if love.filesystem.getInfo(saveDir .. filename) then
		local contents = love.filesystem.read(saveDir .. filename)
		local loaded = json.decode(contents)
		return normalizeSave(loaded)
	else
		return nil
	end
end

-- Lista os saves existentes
function savesManager.listSaves()
	loadIndex()
	table.sort(saveIndex, function(a, b) return a.order < b.order end)
	return saveIndex
end

-- Atualiza a data de último acesso do save
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

-- Apaga um save
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
