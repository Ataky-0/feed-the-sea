-- world.lua
local UI               = require("src.ui")
local sceneManager     = require("src.sceneManager")
local savesManager     = require("src.savesManager")
local entitiesManager  = require("src.entitiesManager")

local world            = {}

local ww, wh           = UI.getDimensions()

-- Tabelas para armazenar as entidades no mundo
world.fishList         = {}
world.plantList        = {}
world.shoalList        = {}
world.wasteList        = {}

world.draggedPlant     = nil
world.dragPlantOffsetX = 0
world.dragPlantOffsetY = 0

local function round3(v)                  -- Esta função auxiliar irá arredondar as porcentagens para termos alta precisão
	return math.floor(v * 1000 + 0.5) / 1000 -- 0.5 para arredondar corretamente
end

function world:load(saveMeta)
	-- Renova dimensões
	ww, wh = UI.getDimensions()
	-- Carrega o conteúdo do save
	self.saveMeta = saveMeta
	self.saveData = savesManager.loadGame(saveMeta.file)
	if not self.saveData then
		error("Erro: save não pôde ser carregado.")
	end

	--#region Converter save
	-- Esta seção tem como objetivo converter saves antigos para novos formatos (aliado ao savesManager.normalizeSave)
	-- É temporário e não deve ser realizado fora do world.lua (mesmo que faça mais sentido estar em savesManager.lua)

	-- Biomass -> Organic Matter
	if self.saveData.biomass then
		self.saveData.organic_matter = self.saveData.biomass
		self.saveData.biomass = nil
		print("Elemento de save convertido: biomass -> organic_matter")
	end
	--#endregion

	-- Variáveis usadas pelo acréscimo temporizado de Matéria orgânica
	self.fishOrganicMatterCurrentRate = 0
	self.fishOrganicMatterWasteImpact = 0.025
	self.fishOrganicMatterMultiplier = 1.0
	self.fishOrganicMatterTimer = 0
	self.fishOrganicMatterInterval = 10 -- segundos

	-- Variáveis usadas pelo evento temporizado de Lixo marítimo
	self.wasteEventTimer = 0
	self.wasteEventInterval = 90 -- 1 minuto e meio
	self.wasteEventMaxAmount = (1 / self.fishOrganicMatterWasteImpact) * 2

	-- Imagem de fundo
	self.background = love.graphics.newImage("assets/background.png")
	self.backgroundW, self.backgroundH = self.background:getDimensions()

	-- Fonts e layout
	self.titleFont = love.graphics.newFont("assets/fonts/DejaVuSans.ttf", 32)
	self.uiFont = love.graphics.newFont("assets/fonts/DejaVuSans.ttf", 18)
	self.messageFont = love.graphics.newFont("assets/fonts/DejaVuSans.ttf", 24)
	self.topBarHeight = 80

	--#region Invocar peixes, plantas e lixos do save
	for id, qty in pairs(self.saveData.fish or {}) do
		local ent = assert(entitiesManager.getFishById(id), "Peixe inexistente.") -- assume que existe
		for _ = 1, qty do
			self:spawnFish(ent)
		end
	end

	self:refreshFishOrganicRate()

	for _, plant in ipairs(self.saveData.producers or {}) do
		local ent = entitiesManager.getPlantById(plant.id)
		if ent then
			self:spawnPlant(ent)                   -- cria a planta com coordenadas “aleatórias” temporárias
			local p = self.plantList[#self.plantList] -- última inserida
			-- recalcula a posição real a partir dos percentuais salvos
			if plant.normX and plant.normY then
				p.normX = plant.normX
				p.normY = plant.normY
				p.x = round3(p.normX * ww)
				p.y = round3(p.normY * wh)
			else
				-- fallback para saves antigos que ainda tenham x/y
				-- TODO: Remover após primeira release 👍👍👍
				p.x = plant.x or p.x
				p.y = plant.y or p.y
				p.normX = round3(p.x / ww)
				p.normY = round3(p.y / wh)
			end
		end
	end

	self:bringPlantsBack()

	for _, waste in ipairs(self.saveData.waste or {}) do
		local ent = entitiesManager.getWasteById(waste.id)
		if ent then
			self:spawnWaste(ent)                   -- cria o lixo com coordenadas “aleatórias” temporárias
			local w = self.wasteList[#self.wasteList] -- última inserida
			-- recalcula a posição real a partir dos percentuais salvos
			if waste.normX and waste.normY then
				w.normX = waste.normX
				w.normY = waste.normY
				w.x = round3(w.normX * ww)
				w.y = round3(w.normY * wh)
				w.targetY = waste.targetY or w.y
				w.removing = waste.removing or false
			else
				-- fallback para saves antigos que ainda tenham x/y
				-- TODO: Remover após primeira release 👍👍👍
				w.x = waste.x or w.x
				w.y = waste.y or w.y
				w.normX = round3(w.x / ww)
				w.normY = round3(w.y / wh)
				w.targetY = waste.targetY or w.y
				w.removing = waste.removing or false
			end
		end
	end
	--#endregion

	--#region Janela de Entidades
	self.spawnWindowTooltipDictionary = {
		oxygen_cost        = "Custa %.2f de Oxigênio para invocar esta entidade.",
		nutrient_cost      = "Custa %.2f de Nutrientes para invocar esta entidade.",
		organic_cost       = "Custa %.2f de Matéria Orgânica para invocar esta entidade.",
		organic_production = "Esta entidade produz %.2f de Matéria Orgânica.",
		oxygen_production  = "Esta entidade produz %.2f de Oxigênio.",
		nutrient_value     = "Esta entidade produz %.2f de Nutrientes.",
	}
	-- Janela
	self.spawnWindow = {
		visible = false,
		x = ww / 2 - 250,
		y = wh / 2 - 200,
		w = 500,
		h = 400,
		scrollY = 0,
		maxScroll = 0,
		closeButton = nil,
		tabs = { "Peixes", "Plantas", "Cardumes" },
		currentTab = 1,
		entityList = {},   -- Para armazenar as entidades carregadas
		selectedEntity = nil -- Entidade selecionada para spawn
	}

	self.spawnWindow.infoWindow = {
		visible = false,
		scrollY = 0,
		maxScroll = 0,
		text = "",
		x = 0,
		y = 0,
		w = 0,
		h = 0
	}

	-- Carregar entidades iniciais para a primeira aba
	self:loadEntitiesForTab(1)

	-- Array para os botões das abas da janela de entidades
	self.spawnWindow.tabButtons = {}
	local tabW = (self.spawnWindow.w - 20) / #self.spawnWindow.tabs
	for i, name in ipairs(self.spawnWindow.tabs) do
		local btn = UI.newButton(
			name,
			self.spawnWindow.x + 10 + (i - 1) * tabW,
			self.spawnWindow.y + 50,
			tabW - 5,
			30,
			function()
				self.spawnWindow.currentTab = i
				self:loadEntitiesForTab(i) -- Carregar entidades quando mudar de aba
			end
		)
		table.insert(self.spawnWindow.tabButtons, btn)
	end

	-- Botão para abrir janela de invocar entidades
	self.spawnButton = UI.newButton(
		"+",
		ww - 165, 20, 40, 40,
		function()
			self.spawnWindow.infoButtons = {} -- Necessário para resetar os botões de info
			self.spawnWindow.visible = not self.spawnWindow.visible
		end
	)

	-- Botão de fechar a janela de entidades
	self.spawnWindow.closeButton = UI.newButton(
		"x",
		self.spawnWindow.x + self.spawnWindow.w - 35,
		self.spawnWindow.y + 10,
		25,
		25,
		function()
			self.spawnWindow.visible = false
			self.spawnWindow.closeButton.hovered = false
			for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
				tabBtn.hovered = false
			end
		end,
		love.graphics.newFont(14)
	)

	-- Botão para spawnar entidade
	self.spawnWindow.spawnEntityButton = UI.newButton(
		"Invocar",
		self.spawnWindow.x + self.spawnWindow.w / 2 - 50,
		self.spawnWindow.y + self.spawnWindow.h - 50,
		100,
		30,
		function()
			local ent = self.spawnWindow.selectedEntity
			if not ent then return end

			if self:canAffordAndConsume(ent) then
				if self.spawnWindow.currentTab == 1 then
					self:spawnFish(ent) -- Peixes
				elseif self.spawnWindow.currentTab == 2 then
					self:spawnPlant(ent) -- Plantas  ←  NEW
				end
			else
				self.canAffordFeedback = UI.newMessage("Recursos insuficientes para invocar " .. ent.name, self.messageFont)
			end
		end
	)
	--#endregion

	-- Botão para sair/voltar
	self.backButton = UI.newButton(
		"Voltar",
		ww - 120, 20, 100, 40,
		function()
			sceneManager:changeScene("mainmenu")
		end
	)

	-- Tooltip geral
	self.tooltip = UI.newTooltip(
		"",
		self.uiFont,
		250
	)

	-- Mensagens de UI
	self.uiLabels = {
		oxygen = { label = "Oxigênio", color = { 0.5, 0.8, 1.0 } },
		organic = { label = "Mat. Orgânica", color = { 0.9, 0.9, 0.3 } },
		herb = { label = "Dieta Herb.", color = { 0.4, 1.0, 0.4 } },
		carn = { label = "Dieta Carn.", color = { 1.0, 0.4, 0.4 } },
	}
end

-- Descarregar mundo e salvar mudanças no save
function world:unload()
	-- fechar janela de spawn
	if self.spawnWindow then
		self.spawnWindow.visible = false
		self.spawnWindow.selectedEntity = nil
	end

	-- montar dados que serão gravados
	if self.saveMeta and self.saveData then
		-- peixes
		local fishCount = {}
		for _, f in ipairs(self.fishList) do
			fishCount[f.id] = (fishCount[f.id] or 0) + 1
		end
		self.saveData.fish = fishCount

		-- plantas (produtores)
		local prod = {}
		for _, p in ipairs(self.plantList) do
			table.insert(prod, {
				id    = p.id,
				-- grava os percentuais já arredondados (já estão em 3 decimais)
				normX = p.normX,
				normY = p.normY,
				size  = p.size
			})
		end
		self.saveData.producers = prod

		-- lixos
		local waste = {}
		for _, w in ipairs(self.wasteList) do
			table.insert(waste, {
				id       = w.id,
				-- grava os percentuais já arredondados (já estão em 3 decimais)
				normX    = w.normX,
				normY    = w.normY,
				targetY  = w.targetY,
				removing = w.removing,
				size     = w.size
			})
		end
		self.saveData.waste = waste

		-- gravar no disco
		local ok, err = pcall(function()
			savesManager.saveGame(self.saveData, self.saveMeta.file)
		end)
		if not ok then
			print("[world] erro ao salvar:", err)
		end
	end

	-- limpar listas de objetos
	self.fishList = {}
	self.plantList = {}
	self.shoalList = {}
	self.wasteList = {}

	-- Limpar feedbacks (mensagens)
	self.canAffordFeedback = nil
end

-- Função para carregar entidades de acordo com a aba selecionada
function world:loadEntitiesForTab(tabIndex)
	self.spawnWindow.currentTab = tabIndex
	if tabIndex == 1 then            -- Aba "Peixes"
		self.spawnWindow.entityList = entitiesManager.getFishList()
	elseif tabIndex == 2 then        -- Aba "Plantas"
		self.spawnWindow.entityList = entitiesManager.getPlantList()
	elseif tabIndex == 3 then        -- Aba "Cardumes"
		self.spawnWindow.entityList = {} -- Implementar quando tiver
	end
end

-- Função para verificar e também deduzir/acrescentar recursos por entidade
function world:canAffordAndConsume(entity)
	local data = assert(self.saveData, "Save data não carregado.")

	if entity.diet then
		if not entity.oxygen_cost or not entity.nutrient_cost then
			return false
		end

		if data.oxygen < entity.oxygen_cost then
			return false
		end

		if entity.diet == "herbivore" then
			if data.food.herbivore < entity.nutrient_cost then return false end
		elseif entity.diet == "carnivore" then
			if data.food.carnivore < entity.nutrient_cost then return false end
		else
			return false
		end

		data.oxygen = data.oxygen - entity.oxygen_cost

		if entity.diet == "herbivore" then
			data.food.herbivore = data.food.herbivore - entity.nutrient_cost
		else
			data.food.carnivore = data.food.carnivore - entity.nutrient_cost
		end

		if entity.organic_cost then
			if data.organic_matter < entity.organic_cost then return false end
			data.organic_matter = data.organic_matter - entity.organic_cost
		end

		return true
	end

	if entity.organic_cost and data.organic_matter < entity.organic_cost then
		return false
	end

	if entity.oxygen_cost and data.oxygen < entity.oxygen_cost then
		return false
	end

	if entity.nutrient_cost then
		if entity.diet == "herbivore" and data.food.herbivore < entity.nutrient_cost then
			return false
		elseif entity.diet == "carnivore" and data.food.carnivore < entity.nutrient_cost then
			return false
		end
	end

	-- Consumo
	if entity.organic_cost then data.organic_matter = data.organic_matter - entity.organic_cost end
	if entity.oxygen_cost then data.oxygen = data.oxygen - entity.oxygen_cost end
	if entity.diet and entity.nutrient_cost then
		if entity.diet == "herbivore" then
			data.food.herbivore = data.food.herbivore - entity.nutrient_cost
		else
			data.food.carnivore = data.food.carnivore - entity.nutrient_cost
		end
	end

	-- Produção
	if entity.oxygen_production then
		data.oxygen = data.oxygen + entity.oxygen_production
	end
	if entity.nutrient_value then
		data.food.herbivore = data.food.herbivore + entity.nutrient_value
	end

	return true
end

-- Função auxiliar para garantir um valor randomizado com propriedade (intensidade)
local function biasedRandom(min, max, power)
	power = power or 2
	local t = math.random() ^ power
	return min + (max - min) * t
end

-- Função para retornar se uma posição está muito próxima de outras
local function isTooClose(x, y, list, minDist)
	for _, p in ipairs(list) do
		local dx, dy = p.x - x, p.y - y
		if dx * dx + dy * dy < minDist * minDist then
			return true
		end
	end
	return false
end

function world:randomGroundPos(minY, maxY)
	local x        = math.random(100, ww - 100)
	local y        = biasedRandom(minY, maxY, 2)

	local attempts = 0
	while isTooClose(x, y, self.plantList, 50) and attempts < 10 do
		x = math.random(100, ww - 100)
		y = biasedRandom(minY, maxY, 2)
		attempts = attempts + 1
	end

	return x, y
end

-- Função para invocar uma planta no mundo
function world:spawnPlant(entity)
	if not self.saveData.unlocked_info[entity.id] then
		self.saveData.unlocked_info[entity.id] = true
	end

	local groundY = wh * 0.80
	local minY    = groundY - 20
	local maxY    = groundY + 90


	local entityWidth, entityHeight = entity.w, entity.h

	local x, y = self:randomGroundPos(minY, maxY)

	local normX = round3(x / ww) -- 0.000 – 1.000
	local normY = round3(y / wh)

	local plant = {
		id     = entity.id,
		name   = entity.name,
		-- guardamos os percentuais, ain ain
		normX  = normX,
		normY  = normY,
		-- manter as coordenadas “reais” por conveniência, por enquanto..
		x      = x,
		y      = y,
		size   = entity.size,
		width  = entityWidth,
		height = entityHeight,
		sprite = love.graphics.newImage("assets/sprites/" .. entity.sprite),
		quads  = {}
	}

	for i = 1, (entity.frames or 1) do
		local quad = love.graphics.newQuad((i - 1) * entityWidth, 0,
			entityWidth, entityHeight,
			plant.sprite:getDimensions())
		table.insert(plant.quads, quad)
	end

	table.insert(self.plantList, plant)
end

-- Função para invocar um peixe no mundo
function world:spawnFish(entity)
	if not self.saveData.unlocked_info[entity.id] then
		self.saveData.unlocked_info[entity.id] = true
	end

	local fish = {
		id = entity.id,
		name = entity.name,
		x = math.random(100, ww - 100),
		y = math.random(self.topBarHeight + 128, wh - (self.topBarHeight + 128)),
		size = entity.size,
		width = 128,
		height = 128,
		velocityX = (math.random() - 0.5) * 100,
		velocityY = (math.random() - 0.5) * 100,
		state = "idle",
		stateTimer = math.random(2, 5),
		animation = { currentFrame = 1, timer = 0, frameDuration = 0.1 },
		sprite = love.graphics.newImage("assets/sprites/" .. entity.sprite),
		organic_production = entity.organic_production or 0,
		quads = {}
	}

	-- Criar quads
	for i = 1, 8 do
		local quad = love.graphics.newQuad((i - 1) * 128, 0, 128, 128, fish.sprite:getDimensions())
		table.insert(fish.quads, quad)
	end

	table.insert(self.fishList, fish)
end

-- Função para invocar um lixo no mundo
function world:spawnWaste(entity)
	local groundY = wh * 0.80
	local minY    = groundY
	local maxY    = groundY + 120

	local x       = math.random(100, ww - 100)
	local y       = biasedRandom(minY, maxY, 2)


	local attempts = 0
	while isTooClose(x, y, self.plantList, 50) and attempts < 10 do
		x = math.random(100, ww - 100)
		y = biasedRandom(minY, maxY, 2)
		attempts = attempts + 1
	end

	local targetY = y           -- Posição no solo
	y = y - wh                  -- Começar fora da tela

	local normX = round3(x / ww) -- 0.000 – 1.000
	local normY = round3(y / wh)

	local waste = {
		id = entity.id,
		name = entity.name,
		normX = normX,
		normY = normY,
		targetY = targetY,
		removing = false,
		x = x,
		y = y,
		width = 128,
		height = 128,
		size = entity.size,
		currentTilt = 0,
		sprite = love.graphics.newImage("assets/sprites/" .. entity.sprite),
		quads = {}
	}

	for i = 1, 8 do
		local quad = love.graphics.newQuad((i - 1) * 128, 0, 128, 128, waste.sprite:getDimensions())
		table.insert(waste.quads, quad)
	end

	table.insert(self.wasteList, waste)
end

-- Função para atualizar animações dos peixes
function world:updateFishAnimations(dt)
	for _, fish in ipairs(self.fishList) do
		-- Alternar entre estados
		fish.stateTimer = fish.stateTimer - dt
		if fish.stateTimer <= 0 then
			if fish.state == "swimming" then
				fish.state = "idle"
				fish.stateTimer = math.random(2, 5)
				fish.velocityX = (math.random() - 0.5) * 20
				fish.velocityY = (math.random() - 0.5) * 20
			else
				fish.state = "swimming"
				fish.stateTimer = math.random(3, 6)
				fish.velocityX = (math.random() - 0.5) * 100
				fish.velocityY = (math.random() - 0.5) * 100
			end
		end

		-- Atualizar animação
		local frameSpeed = fish.state == "swimming" and 0.1 or 0.4
		fish.animation.timer = fish.animation.timer + dt
		if fish.animation.timer >= frameSpeed then
			fish.animation.timer = 0
			fish.animation.currentFrame = fish.animation.currentFrame + 1
			if fish.animation.currentFrame > 8 then
				fish.animation.currentFrame = 1
			end
		end

		-- Suavizar tilt vertical baseado na velocidade Y (eye candy)
		local targetTilt = math.rad(-fish.velocityY * 0.4)
		targetTilt = fish.velocityX <= 0 and targetTilt or -targetTilt
		fish.currentTilt = fish.currentTilt or targetTilt
		local tiltSpeed = 5
		fish.currentTilt = fish.currentTilt + (targetTilt - fish.currentTilt) * math.min(dt * tiltSpeed, 1)
	end
end

-- Função para desenhar as plantas
function world:drawPlants()
	for _, plant in ipairs(self.plantList) do
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.push()
		love.graphics.translate(plant.x, plant.y)
		love.graphics.rotate(plant.currentTilt or 0)

		if #plant.quads > 0 then
			love.graphics.draw(
				plant.sprite,
				plant.quads[1],
				0, 0,
				0,
				plant.size, plant.size,
				plant.width / 2, plant.height / 2
			)
		else
			love.graphics.draw(
				plant.sprite,
				0, 0,
				0,
				plant.size, plant.size,
				plant.width / 2, plant.height / 2
			)
		end

		love.graphics.pop()
	end
end

-- Função para desenhar os peixes
function world:drawFish()
	for _, fish in ipairs(self.fishList) do
		love.graphics.setColor(1, 1, 1, 1)

		local sx = fish.velocityX >= 0 and 1 or -1

		love.graphics.push()
		love.graphics.translate(fish.x, fish.y)
		love.graphics.rotate(fish.currentTilt or 0)

		-- Sem mexer no scale global
		love.graphics.draw(
			fish.sprite,
			fish.quads[fish.animation.currentFrame],
			0, 0,
			0,
			sx * fish.size, fish.size,
			fish.width / 2, fish.height / 2
		)
		love.graphics.pop()
	end
end

-- Função para desenhar os lixos
function world:drawWaste()
	for _, waste in ipairs(self.wasteList) do
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.push()
		love.graphics.translate(waste.x, waste.y)
		love.graphics.rotate(waste.currentTilt or 0)

		love.graphics.draw(
			waste.sprite,
			0, 0,
			0,
			waste.size, waste.size,
			waste.width / 2, waste.height / 2
		)

		love.graphics.pop()
	end
end

-- Função para removar lixo
function world:removeWaste(waste)
	for i, w in ipairs(self.wasteList) do
		if w == waste then
			table.remove(self.wasteList, i)
			return
		end
	end
end

--#region SPAWN WINDOW (A função ficou muito grande, então dividi em várias regiões)
--#region SPAWN WINDOW: Auxiliares

function world:spawnWindow_drawBackground(x0, y0, w0, h0)
	love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
	love.graphics.rectangle("fill", x0, y0, w0, h0, 12, 12)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", x0, y0, w0, h0, 12, 12)
end

function world:spawnWindow_drawTabsAndButtons()
	UI.drawButton(self.spawnWindow.closeButton, self.uiFont)
	for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
		UI.drawButton(tabBtn, self.uiFont)
	end
end

function world:spawnWindow_drawInfoButton(textH, drawX, drawY, contentW, topHeight, block, font)
	local infoSize = textH + 6
	local infoX = drawX + contentW - infoSize -- extrema direita do bloco
	local infoY = drawY + (topHeight / 2) - (infoSize)

	local btn
	-- Checar se já existe botão criado para este bloco
	for _, infoBtn in ipairs(self.spawnWindow.infoButtons) do
		if infoBtn.entity == block.entity then
			btn = infoBtn.button
		end
	end

	if not btn then
		btn = UI.newButton("ℹ", infoX, infoY, infoSize, infoSize, function()
			if self.spawnWindow.infoWindow.text == block.entity.curiosity then
				-- fechar janela se já estiver aberta com o mesmo texto
				self.spawnWindow.infoWindow.visible = false
				self.spawnWindow.infoWindow.text = ""
				return
			end

			self.spawnWindow.infoWindow.text = block.entity.curiosity or ""
			self.spawnWindow.infoWindow.visible = true
		end)
		-- Registra o botão (para hitbox/click)
		table.insert(self.spawnWindow.infoButtons, {
			button = btn,
			x = infoX,
			y = infoY,
			w = infoSize,
			h = infoSize,
			entity = block.entity
		})
	else
		-- Atualiza posição
		btn.x = infoX
		btn.y = infoY
		btn.w = infoSize
		btn.h = infoSize
	end

	if not self.saveData.unlocked_info[block.entity.id] then
		btn.disabled = true
		btn.hovered = false
	else
		btn.disabled = false
	end

	UI.drawButton(btn, font)
end

function world:spawnWindow_drawBlock(block, drawX, drawY, innerPad, listW, font, isSelected)
	-- largura útil para conteúdo
	local contentW = listW - innerPad * 2

	-- nome
	love.graphics.setColor(0.7, 0.9, 1.0)
	local nameText = block.entity.name or block.entity.id
	love.graphics.print(nameText, drawX, drawY)
	local textW = font:getWidth(nameText)
	local textH = font:getHeight()

	-- desenhar ícone (se existir)
	local iconSize = 0
	if block.entity.sprite then
		block.entity.sprite_img = block.entity.sprite_img
				or love.graphics.newImage("assets/sprites/" .. block.entity.sprite)

		local sprite = block.entity.sprite_img
		local sheetW, sheetH = sprite:getDimensions()
		local frameW, frameH

		if block.entity.w and block.entity.h then
			frameW = block.entity.w
			frameH = block.entity.h
		elseif sheetH == 128 and sheetW > 128 then
			frameW = 128
			frameH = 128
		else
			frameW = sheetW
			frameH = sheetH
		end

		local quad = love.graphics.newQuad(0, 0, frameW, frameH, sheetW, sheetH)

		-- tamanho grande do ícone
		iconSize = font:getHeight() * 3.0
		local scale = iconSize / frameH

		-- posição do ícone: à direita do texto
		local iconX = drawX + textW + 6
		local iconY = drawY + (textH / 2) - (frameH * scale / 2)

		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(sprite, quad, iconX, iconY, 0, scale, scale)
	end

	-- altura reservada para topo (nome + ícone)
	local topHeight = math.max(textH, iconSize)

	-- BOTÃO DE INFORMAÇÕES (ℹ)
	self:spawnWindow_drawInfoButton(textH, drawX, drawY, contentW, topHeight, block, font)

	-- descrição
	local wrapped, lines = font:getWrap(block.desc, contentW)
	local lineCount = type(lines) == "table" and #lines or lines or 1
	local descH = lineCount * font:getHeight()

	local descX = drawX
	local descY = drawY + topHeight + 6
	local descW = contentW

	love.graphics.setColor(1, 1, 1)
	love.graphics.printf(block.desc, descX, descY, descW, "left")

	-- calcular altura total do bloco (para hitbox e espaçamento)
	local bh = topHeight + 6 + descH + innerPad * 2

	if isSelected then
		love.graphics.setColor(0.3, 0.6, 1.0, 1)
		love.graphics.setLineWidth(2)
		love.graphics.rectangle("line", drawX - innerPad, drawY - innerPad / 2, listW, bh, 6, 6)
		love.graphics.setLineWidth(1)
	end

	-- COLORIR NÚMEROS

	local nums = {}
	local function addNum(val, color, category)
		if type(val) == "number" and color then
			table.insert(nums, { string.format("%.2f", val), color, category })
		end
	end

	local oxColor       = self.uiLabels.oxygen.color
	local organicColor  = self.uiLabels.organic.color
	local herbColor     = self.uiLabels.herb.color
	local carnColor     = self.uiLabels.carn.color

	local nutrientColor =
			(block.entity.diet == "herbivore" or block.entity.diet == "herb") and herbColor
			or (block.entity.diet == "carnivore" or block.entity.diet == "carn") and carnColor
			or { 1, 1, 0 }

	if block.entity.oxygen_cost then
		addNum(block.entity.oxygen_cost, oxColor, "oxygen_cost")
		addNum(block.entity.nutrient_cost, nutrientColor, "nutrient_cost")
		addNum(block.entity.organic_production, organicColor, "organic_production")
	elseif block.entity.oxygen_production then
		addNum(block.entity.oxygen_production, oxColor, "oxygen_production")
		addNum(block.entity.nutrient_value, nutrientColor, "nutrient_value")
		addNum(block.entity.organic_cost, organicColor, "organic_cost")
	end

	local lineList = type(lines) == "table" and lines or wrapped
	for lineIndex, lineText in ipairs(lineList) do
		for _, pair in ipairs(nums) do
			local numStr, color = pair[1], pair[2]
			local s = string.find(lineText, numStr, 1, true)
			if s then
				local before = lineText:sub(1, s - 1)
				local xOff = font:getWidth(before)
				local yOff = (lineIndex - 1) * font:getHeight()

				local px = descX + xOff
				local py = descY + yOff

				love.graphics.setColor(color)
				love.graphics.print(numStr, descX + xOff, descY + yOff)

				-- REGISTRA O HITBOX DO NÚMERO
				table.insert(self.spawnWindow.coloredNumbers, {
					x = px,
					y = py,
					w = font:getWidth(numStr),
					h = font:getHeight(),
					value = numStr,            -- valor
					color = color,             -- cor do número (removível caso a gente acabe não usando)
					category = pair[3] or "unknown" -- o mais importante (depois da hitbox)
				})
			end
		end
	end

	return bh
end

function world:spawnWindow_computeBlocks(listW, innerPad, blockSpacing, font)
	local contentHeight = 0
	local blocks = {}

	for _, entity in ipairs(self.spawnWindow.entityList) do
		local desc = ""
		if entity.oxygen_cost then
			desc = string.format(entity.description or "",
				entity.oxygen_cost,
				entity.nutrient_cost or 0,
				entity.organic_production or 0
			)
		elseif entity.oxygen_production then
			desc = string.format(entity.description or "",
				entity.oxygen_production,
				entity.nutrient_value or 0,
				entity.organic_cost or 0
			)
		end

		local nameH = font:getHeight()

		local iconSize = 0

		if entity.sprite then
			-- carregar imagem (lazy)
			entity.sprite_img = entity.sprite_img
					or love.graphics.newImage("assets/sprites/" .. entity.sprite)

			local sprite = entity.sprite_img
			local sheetW, sheetH = sprite:getDimensions()
			local frameW, frameH

			if entity.w and entity.h then
				frameW = entity.w
				frameH = entity.h
			elseif sheetH == 128 and sheetW > 128 then
				frameW = 128
				frameH = 128
			else
				frameW = sheetW
				frameH = sheetH
			end

			-- mesmo cálculo usado no draw:
			iconSize = font:getHeight() * 3.0
		end

		local topHeight = math.max(nameH, iconSize)

		local textW = listW - innerPad * 2
		local a, b = font:getWrap(desc, textW)

		local descLines
		if type(b) == "number" then
			descLines = b
		elseif type(b) == "table" then
			descLines = #b
		elseif type(a) == "number" then
			descLines = a
		elseif type(a) == "table" then
			descLines = #a
		else
			descLines = 1
		end

		local descH = descLines * font:getHeight()

		local blockHeight = topHeight + 6 + descH + innerPad * 2

		table.insert(blocks, {
			entity = entity,
			desc   = desc,
			height = blockHeight
		})

		contentHeight = contentHeight + blockHeight + blockSpacing
	end

	if contentHeight > 0 then
		contentHeight = contentHeight - blockSpacing
	end

	contentHeight = contentHeight + 10

	return blocks, contentHeight
end

function world:spawnWindow_applyScroll(listH, contentHeight) --TODO: Isso provavelmente é desnecessário
	local maxScroll = (contentHeight > listH) and (listH - contentHeight) or 0
	self.spawnWindow.maxScroll = maxScroll

	if not self.spawnWindow.scrollY then self.spawnWindow.scrollY = 0 end
	if self.spawnWindow.scrollY > 0 then self.spawnWindow.scrollY = 0 end
	if self.spawnWindow.scrollY < maxScroll then self.spawnWindow.scrollY = maxScroll end
end

function world:spawnWindow_updateInfoWindowGeometry()
	local sw = self.spawnWindow

	-- metade da largura do spawnWindow
	local infoW = sw.w * 0.5
	local infoH = sw.h

	local gap = 30

	sw.infoWindow.x = sw.x + sw.w + gap
	sw.infoWindow.y = sw.y
	sw.infoWindow.w = infoW
	sw.infoWindow.h = infoH
end

function world:spawnWindow_drawInfoWindow()
	local win = self.spawnWindow.infoWindow
	if not win.visible then return end

	local text = win.text or ""

	-- Fundo
	love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
	love.graphics.rectangle("fill", win.x, win.y, win.w, win.h, 12, 12)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", win.x, win.y, win.w, win.h, 12, 12)

	-- Área de texto
	local pad        = 10
	local textX      = win.x + pad
	local textY      = win.y + pad
	local textW      = win.w - pad * 2

	-- Medir altura total do texto com wrap
	local font       = love.graphics.getFont()
	local _, wrapped = font:getWrap(text, textW)
	local textHeight = #wrapped * font:getHeight()

	-- Scroll usando o padrão do spawnWindow
	local visibleH   = win.h - pad * 2
	win.maxScroll    = (textHeight > visibleH) and (visibleH - textHeight) or 0

	win.scrollY      = win.scrollY or 0
	if win.scrollY > 0 then win.scrollY = 0 end
	if win.scrollY < win.maxScroll then win.scrollY = win.maxScroll end

	-- Scissor
	local sx, sy = UI.getScale()
	love.graphics.setScissor(
		win.x * sx,
		win.y * sy,
		win.w * sx,
		win.h * sy
	)

	love.graphics.printf(
		string.format(text),
		textX,
		textY + win.scrollY,
		textW,
		"left"
	)

	love.graphics.setScissor()
end

--#endregion

-- Função principal
function world:drawSpawnWindow()
	if not self.spawnWindow.visible then return end

	local padding        = 10
	local innerPad       = 10
	local blockSpacing   = 10

	local x0, y0, w0, h0 = self.spawnWindow.x, self.spawnWindow.y, self.spawnWindow.w, self.spawnWindow.h

	self:spawnWindow_updateInfoWindowGeometry()

	self:spawnWindow_drawBackground(x0, y0, w0, h0)
	self:spawnWindow_drawTabsAndButtons()

	local listX = x0 + 10
	local listY = y0 + 90
	local listW = w0 - 20
	local listH = h0 - 140

	love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
	love.graphics.rectangle("fill", listX, listY, listW, listH, 8, 8)

	local sx, sy = UI.getScale()
	love.graphics.setScissor(listX * sx, listY * sy, listW * sx, listH * sy)

	local font = love.graphics.getFont()
	local blocks, contentHeight =
			self:spawnWindow_computeBlocks(listW, innerPad, blockSpacing, font)

	self:spawnWindow_applyScroll(listH, contentHeight)

	local drawY = listY + innerPad + self.spawnWindow.scrollY
	local drawX = listX + innerPad

	self.spawnWindow.renderedBlocks = {}
	self.spawnWindow.blockIndex = 0

	-- Esta variável será usada para o hitbox dos números coloridos
	self.spawnWindow.coloredNumbers = {}

	local selected = self.spawnWindow.selectedEntity

	for _, block in ipairs(blocks) do
		local isSelected = (selected == block.entity)
		self.spawnWindow.blockIndex = self.spawnWindow.blockIndex + 1

		local bh = self:spawnWindow_drawBlock(block, drawX, drawY, innerPad, listW, font, isSelected)

		table.insert(self.spawnWindow.renderedBlocks, {
			entity = block.entity,
			hitbox = {
				x = drawX - innerPad,
				y = drawY - innerPad / 2,
				w = listW,
				h = bh
			}
		})

		drawY = drawY + bh + blockSpacing
	end

	love.graphics.setScissor()
	UI.drawButton(self.spawnWindow.spawnEntityButton, self.uiFont)
	self:spawnWindow_drawInfoWindow()
end

--#endregion

-- Função para retornar plantas indevidamente fora do espaço de jogo
function world:bringPlantsBack()
	-- Função irá iterar sobre as plantas e verificar se estão fora dos limites do mundo.
	-- Se estiverem, reposicioná-las com os mesmos parâmetros de spawn.
	-- Só deve ser chamada no :load() e após movê-las.
	for _, plant in ipairs(self.plantList) do
		if plant.x < 0 or plant.x > ww or plant.y < self.topBarHeight or plant.y > wh then
			-- Reposicionar
			local groundY = wh * 0.80
			local minY    = groundY - 20
			local maxY    = groundY + 90

			local x, y    = self:randomGroundPos(minY, maxY)

			plant.x       = x
			plant.y       = y
			plant.normX   = round3(x / ww)
			plant.normY   = round3(y / wh)
		end
	end
end

-- Função para retornar o máximo de matéria orgânica permitida
function world:getMaxOrganicMatter()
	-- Limite atual segue uma equação simples onde o valor de produção de matéria orgânica
	-- * 10 define o limite máximo.
	return self.fishOrganicMatterCurrentRate * 10
end

function world:refreshFishOrganicRate()
	local totalProd = 0

	for _, fish in ipairs(self.fishList) do
		totalProd = totalProd + fish.organic_production
	end

	totalProd = totalProd * self.fishOrganicMatterMultiplier
	self.fishOrganicMatterCurrentRate = totalProd
end

function world:update(dt)
	-- Geração temporizada de massa orgânica pelos peixes
	self.fishOrganicMatterTimer = self.fishOrganicMatterTimer + dt
	self.fishOrganicMatterMultiplier = math.max(0, 1.0 - (#self.wasteList * self.fishOrganicMatterWasteImpact)) -- diminui 2.5% por lixo

	if self.fishOrganicMatterTimer >= self.fishOrganicMatterInterval then
		self:refreshFishOrganicRate()

		if self.saveData.organic_matter < self:getMaxOrganicMatter() then
			self.saveData.organic_matter = (self.saveData.organic_matter or 0) + self.fishOrganicMatterCurrentRate
		end

		self.fishOrganicMatterTimer = 0
	end

	-- Atualizar fade-out da remoção de lixo
	for i = #self.wasteList, 1, -1 do
		local waste = self.wasteList[i]
		if waste.removing then
			waste.size = waste.size - 0.1
			if waste.size <= 0 then
				table.remove(self.wasteList, i)
			end
		end
	end

	-- Evento temporizado de lixo marítimo
	self.wasteEventTimer = self.wasteEventTimer + dt

	if self.wasteEventTimer >= self.wasteEventInterval then
		-- Invocar lixo em uma posição aleatória
		local wasteEntities = entitiesManager.getWasteList()

		if #wasteEntities > 0 and #self.wasteList < self.wasteEventMaxAmount then
			for _ = 1, math.random(3, 6) do
				local wasteEnt = wasteEntities[math.random(1, #wasteEntities)]
				self:spawnWaste(wasteEnt)
			end
		end

		self.wasteEventTimer = 0
	end

	-- Movimentação dos peixes
	for _, fish in ipairs(self.fishList) do
		fish.x = fish.x + fish.velocityX * dt
		fish.y = fish.y + fish.velocityY * dt

		-- Inverter direção ao bater nas bordas
		if fish.x - (fish.width / 2) * fish.size < 0 or fish.x + (fish.width / 2) * fish.size > ww then
			fish.x = fish.x + (fish.velocityX > 0 and -10 or (fish.velocityX < 0 and 10 or 0))
			fish.velocityX = -fish.velocityX
		end
		if fish.y - (fish.height / 2) * fish.size < self.topBarHeight or fish.y + (fish.height / 2) * fish.size > wh then
			fish.y = fish.y + (fish.velocityY > 0 and -10 or (fish.velocityY < 0 and 10 or 0))
			fish.velocityY = -fish.velocityY
		end
	end

	-- Movimentação dos lixos
	for _, waste in ipairs(self.wasteList) do
		-- Mover para baixo até a posição alvo
		if waste.y < waste.targetY then
			waste.y = waste.y + (60 * dt)
			if waste.y >= waste.targetY then
				waste.y = waste.targetY
				waste.targetY = 0
			end
			waste.normY = round3(waste.y / wh)
		end

		-- Cálculo de tilt baseado na proximidade do alvo
		local proximity = (waste.targetY - waste.y)

		-- tilt baseado no movimento (suave)
		local dynamicTilt = proximity * 0.03

		-- só gera um tilt aleatório quando ATERRISSA pela primeira vez
		if math.abs(proximity) < 5 and not waste.landedTilt then
			waste.landedTilt = math.rad(math.random(-55, 55))
		end

		-- tilt final: se aterrissou, usa tilt fixo; senão usa dinâmico
		local targetTilt = waste.landedTilt or dynamicTilt

		-- suavização
		waste.currentTilt = waste.currentTilt or targetTilt
		local tiltSpeed = 3
		waste.currentTilt = waste.currentTilt + (targetTilt - waste.currentTilt) * math.min(dt * tiltSpeed, 1)
	end

	-- Atualizar animações dos peixes
	self:updateFishAnimations(dt)
end

function world:draw()
	local sx, sy = UI.getScale()

	love.graphics.push()
	love.graphics.scale(sx, sy)

	local backgroundScaleX = ww / self.backgroundW
	local backgroundScaleY = wh / self.backgroundH

	-- Fundo geral
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.background, 0, 0, 0, backgroundScaleX, backgroundScaleY)

	-- Barra superior de interface
	love.graphics.setColor(0, 0, 0, 0.4)
	love.graphics.rectangle("fill", 0, 0, ww, self.topBarHeight)

	-- Valores atuais (oxigênio e comida) organizados em 2 linhas
	love.graphics.setFont(self.uiFont)
	local y1 = 15 -- primeira linha
	local y2 = 40 -- segunda linha
	local startX = 40
	local spacing = 225

	local isOrganicMaxed = self.saveData.organic_matter >= self:getMaxOrganicMatter()

	-- Linha 1: Oxigênio e Matéria orgânica
	love.graphics.setColor(self.uiLabels.oxygen.color)
	love.graphics.print(string.format("%s: %.2f mg O₂", self.uiLabels.oxygen.label, self.saveData.oxygen), startX, y1)
	love.graphics.setColor(self.uiLabels.organic.color)
	love.graphics.print(
		string.format("%s: %.2f mg C (%s)", self.uiLabels.organic.label, self.saveData.organic_matter,
			isOrganicMaxed and "Maxed" or string.format("x%.2f", self.fishOrganicMatterMultiplier)),
		startX + spacing,
		y1)

	-- Linha 2: Herbívora e Carnívora
	love.graphics.setColor(self.uiLabels.herb.color)
	love.graphics.print(string.format("%s: %.2f mg C", self.uiLabels.herb.label, self.saveData.food.herbivore), startX, y2)
	love.graphics.setColor(self.uiLabels.carn.color)
	love.graphics.print(string.format("%s: %.2f mg C", self.uiLabels.carn.label, self.saveData.food.carnivore),
		startX + spacing,
		y2)

	-- Desenhar plantas
	self:drawPlants()
	-- Desenhar peixes
	self:drawFish()
	-- Desenhar lixos
	self:drawWaste()

	-- Botão de saída
	UI.drawButton(self.backButton, self.uiFont)
	UI.drawButton(self.spawnButton, self.uiFont)
	self:drawSpawnWindow()

	-- Nome do save no canto inferior esquerdo
	--TODO: ainda irei retirar com um fade bonitinho, depois..
	love.graphics.setFont(self.uiFont)
	love.graphics.setColor(1, 1, 1, 0.6)
	love.graphics.print(self.saveMeta.name, 20, wh - 40)

	if self.canAffordFeedback then UI.drawMessage(self.canAffordFeedback) end

	if self.tooltip.visible then
		UI.drawTooltip(self.tooltip)
	end

	love.graphics.pop()
end

function world:wheelmoved(dx, dy)
	local scrollSpeed = 30 -- ajuste conforme preferir

	if self.spawnWindow and self.spawnWindow.visible then
		local x, y = UI.scaleMouse(love.mouse.getPosition())
		-- Checar se mouse está dentro da janela (x,y,w,h)
		if x >= self.spawnWindow.x and x <= self.spawnWindow.x + self.spawnWindow.w and
				y >= self.spawnWindow.y and y <= self.spawnWindow.y + self.spawnWindow.h then
			self.spawnWindow.scrollY = (self.spawnWindow.scrollY or 0) + dy * scrollSpeed

			-- clamp seguro
			if self.spawnWindow.scrollY > 0 then self.spawnWindow.scrollY = 0 end
			if self.spawnWindow.scrollY < self.spawnWindow.maxScroll then
				self.spawnWindow.scrollY = self.spawnWindow
						.maxScroll
			end
			return -- evitar verificações posteriores
		end
	end

	if self.spawnWindow.infoWindow and self.spawnWindow.infoWindow.visible then
		local x, y = UI.scaleMouse(love.mouse.getPosition())
		-- Checar se mouse está dentro da janela (x,y,w,h)
		if x >= self.spawnWindow.infoWindow.x and x <= self.spawnWindow.infoWindow.x + self.spawnWindow.infoWindow.w and
				y >= self.spawnWindow.infoWindow.y and y <= self.spawnWindow.infoWindow.y + self.spawnWindow.infoWindow.h then
			-- Mesma coisa do spawnWindow
			self.spawnWindow.infoWindow.scrollY = (self.spawnWindow.infoWindow.scrollY or 0) + dy * scrollSpeed

			-- clamp seguro
			if self.spawnWindow.infoWindow.scrollY > 0 then self.spawnWindow.infoWindow.scrollY = 0 end
			if self.spawnWindow.infoWindow.scrollY < self.spawnWindow.infoWindow.maxScroll then
				self.spawnWindow.infoWindow.scrollY = self.spawnWindow.infoWindow
						.maxScroll
			end
			return -- evitar verificações posteriores
		end
	end
end

function world:mousemoved(x, y)
	x, y = UI.scaleMouse(x, y)

	-- controle global do tooltip
	local tooltipDebounce = false

	if self.spawnWindow.visible and self.spawnWindow.coloredNumbers then
		for _, info in ipairs(self.spawnWindow.coloredNumbers) do
			if x >= info.x and x <= info.x + info.w and
					y >= info.y and y <= info.y + info.h then
				-- achou um número
				self.tooltip.text = string.format(self.spawnWindowTooltipDictionary[info.category], info.value)
				-- é tão instantâneo, porém uma ordem de acontecimento sempre é bom
				self.tooltip.visible = true
				tooltipDebounce = true
				break
			end
		end

		if not tooltipDebounce then
			self.tooltip.visible = false
		end
	end

	UI.updateButtonHover(self.backButton, x, y)
	UI.updateButtonHover(self.spawnButton, x, y)

	for _, btn in ipairs(self.spawnWindow.infoButtons or {}) do
		UI.updateButtonHover(btn.button, x, y)
	end

	if self.draggedPlant then
		self.draggedPlant.x = x - self.dragPlantOffsetX
		self.draggedPlant.y = y - self.dragPlantOffsetY
	end

	if self.spawnWindow.visible then
		UI.updateButtonHover(self.spawnWindow.closeButton, x, y)
		UI.updateButtonHover(self.spawnWindow.spawnEntityButton, x, y)

		for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
			UI.updateButtonHover(tabBtn, x, y)
		end
	end
end

function world:mousepressed(x, y, button)
	x, y = UI.scaleMouse(x, y)

	UI.clickButton(self.backButton, button)
	UI.clickButton(self.spawnButton, button)

	for _, btn in ipairs(self.spawnWindow.infoButtons or {}) do
		UI.clickButton(btn.button, button)
	end

	if button == 1 and not self.spawnWindow.visible then
		-- Verificar clique em lixo para limpar
		for _, waste in ipairs(self.wasteList) do
			-- Só pode limpar quando o lixo estiver no chão
			if waste.targetY ~= 0 then break end
			-- Hitbox apromixado
			local radius = waste.size * 0.5 * math.max(waste.width, waste.height) -- aproximação do “hit‑box”
			if (x - waste.x) ^ 2 + (y - waste.y) ^ 2 <= radius ^ 2 then
				-- Adicionar qualidade de remoção ao lixo
				waste.removing = true
				-- Apenas um lixo por clique (também evitando arrastar plantas próximas)
				return
			end
		end

		-- Verificar clique em plantas para arrastar
		for _, plant in ipairs(self.plantList) do
			-- Hitbox apromixado
			local radius = plant.size * 0.5 * math.max(plant.width, plant.height) -- aproximação do “hit‑box”
			if (x - plant.x) ^ 2 + (y - plant.y) ^ 2 <= radius ^ 2 then
				self.draggedPlant = plant
				self.dragPlantOffsetX = x - plant.x
				self.dragPlantOffsetY = y - plant.y
				break
			end
		end
	end

	if self.canAffordFeedback then
		UI.clickMessage(self.canAffordFeedback, x, y)
	end

	if self.spawnWindow.visible then
		UI.clickButton(self.spawnWindow.closeButton, button)
		UI.clickButton(self.spawnWindow.spawnEntityButton, button)

		-- abas normalmente
		for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
			UI.clickButton(tabBtn, button)
		end

		-- clique em um bloco renderizado (respeita scroll porque hitbox foi calculada com drawY+scrollY)
		if button == 1 and not self.spawnWindow.spawnEntityButton.hovered and self.spawnWindow.renderedBlocks then
			-- converte coords do mouse para o sistema UI (igual usado no draw)
			for _, rb in ipairs(self.spawnWindow.renderedBlocks) do
				local hb = rb.hitbox
				if x >= hb.x and x <= hb.x + hb.w and y >= hb.y and y <= hb.y + hb.h then
					-- selecionou corretamente o entity daquele bloco
					self.spawnWindow.selectedEntity = rb.entity
					return
				end
			end
		end
	end
end

function world:mousereleased(x, y, button)
	if button == 1 then
		if self.draggedPlant then
			self.draggedPlant.normX = round3(self.draggedPlant.x / ww)
			self.draggedPlant.normY = round3(self.draggedPlant.y / wh)
			self.draggedPlant = nil
			self:bringPlantsBack()
		end
	end
end

return world
