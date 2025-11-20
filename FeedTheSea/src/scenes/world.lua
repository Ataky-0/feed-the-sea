-- world.lua
local UI               = require("src.ui")
local sceneManager     = require("src.sceneManager")
local savesManager     = require("src.savesManager")
local entitiesManager  = require("src.entitiesManager")

local world            = {}

local ww, wh           = UI.getDimensions()

-- Tabelas para armazenar os peixes no mundo
world.fishList         = {}
world.plantList        = {}
world.shoalList        = {}

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

	-- Variáveis usadas pelo acréscimo temporizado de Biomassa
	self.fishBiomassTimer = 0
	self.fishBiomassInterval = 10

	-- Imagem de fundo
	self.background = love.graphics.newImage("assets/background.png")
	self.backgroundW, self.backgroundH = self.background:getDimensions()

	-- Fonts e layout
	self.titleFont = love.graphics.newFont("assets/fonts/DejaVuSans.ttf", 32)
	self.uiFont = love.graphics.newFont("assets/fonts/DejaVuSans.ttf", 18)
	self.messageFont = love.graphics.newFont("assets/fonts/DejaVuSans.ttf", 24)
	self.topBarHeight = 80

	-- Invocar peixes e plantas do save
	for id, qty in pairs(self.saveData.fish or {}) do
		local ent = assert(entitiesManager.getFishById(id), "Peixe inexistente.") -- assume que existe
		for _ = 1, qty do
			self:spawnFish(ent)
		end
	end

	for _, plant in ipairs(self.saveData.producers or {}) do
		local ent = entitiesManager.getPlantById(plant.id)
		if ent then
			self:spawnPlant(ent)                        -- cria a planta com coordenadas “aleatórias” temporárias
			local p = self.plantList[#self.plantList]   -- última inserida
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

	--#region Janela de Entidades
	-- Janela
	self.spawnWindow = {
		visible = false,
		x = ww / 2 - 250,
		y = wh / 2 - 200,
		w = 500,
		h = 400,
		closeButton = nil,
		tabs = { "Peixes", "Plantas", "Cardumes" },
		currentTab = 1,
		entityList = {},   -- Para armazenar as entidades carregadas
		selectedEntity = nil -- Entidade selecionada para spawn
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

	-- Mensagens de UI
	self.uiLabels = {
		oxygen = { label = "Oxigênio", color = { 0.5, 0.8, 1.0 } },
		biomass = { label = "Biomassa", color = { 0.9, 0.9, 0.3 } },
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

		if entity.biomass_cost then
			if data.biomass < entity.biomass_cost then return false end
			data.biomass = data.biomass - entity.biomass_cost
		end

		return true
	end

	if entity.biomass_cost and data.biomass < entity.biomass_cost then
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
	if entity.biomass_cost then data.biomass = data.biomass - entity.biomass_cost end
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

-- Função para invocar uma planta no mundo
function world:spawnPlant(entity)
	local groundY  = wh * 0.80
	local minY     = groundY - 20
	local maxY     = groundY + 90

	local x        = math.random(100, ww - 100)
	local y        = biasedRandom(minY, maxY, 2)

	local attempts = 0
	while isTooClose(x, y, self.plantList, 50) and attempts < 10 do
		x = math.random(100, ww - 100)
		y = biasedRandom(minY, maxY, 2)
		attempts = attempts + 1
	end

	local entityWidth, entityHeight = entity.w, entity.h

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
	local fish = {
		id = entity.id,
		name = entity.name,
		x = math.random(100, ww - 100),
		y = math.random(100, wh - 100),
		size = entity.size,
		width = 128,
		height = 128,
		velocityX = (math.random() - 0.5) * 100,
		velocityY = (math.random() - 0.5) * 100,
		state = "idle",
		stateTimer = math.random(2, 5),
		animation = { currentFrame = 1, timer = 0, frameDuration = 0.1 },
		sprite = love.graphics.newImage("assets/sprites/" .. entity.sprite),
		biomass_production = entity.biomass_production or 0,
		quads = {}
	}

	-- Criar quads
	for i = 1, 8 do
		local quad = love.graphics.newQuad((i - 1) * 128, 0, 128, 128, fish.sprite:getDimensions())
		table.insert(fish.quads, quad)
	end

	table.insert(self.fishList, fish)
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

-- Função para desenhar a janela de spawn de entidades
function world:drawSpawnWindow()
	if not self.spawnWindow.visible then return end

	-- Fundo da janela
	love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
	love.graphics.rectangle("fill", self.spawnWindow.x, self.spawnWindow.y, self.spawnWindow.w, self.spawnWindow.h, 12,
		12)

	-- Borda
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", self.spawnWindow.x, self.spawnWindow.y, self.spawnWindow.w, self.spawnWindow.h, 12,
		12)

	-- Botão de fechar
	UI.drawButton(self.spawnWindow.closeButton, self.uiFont)

	-- Abas
	for i, tabBtn in ipairs(self.spawnWindow.tabButtons) do
		UI.drawButton(tabBtn, self.uiFont)
	end

	-- Holder da lista de entidades
	love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
	love.graphics.rectangle("fill", self.spawnWindow.x + 10, self.spawnWindow.y + 90, self.spawnWindow.w - 20,
		self.spawnWindow.h - 140, 8, 8)

	-- Desenhar as entidades na lista
	love.graphics.setColor(1, 1, 1)
	local y_offset = self.spawnWindow.y + 100
	local lineSpacing = 5   -- espaço entre stats
	local entitySpacing = 10 -- espaço extra entre entidades

	for i, entity in ipairs(self.spawnWindow.entityList) do
		local x = self.spawnWindow.x + 20
		local font = love.graphics.getFont()
		local padding = 5

		-- Preparar stats
		local stats = {}
		local oxColor = { 0.4, 0.7, 1.0 }
		local dietColor = { 0.4, 1.0, 0.4 }
		local bioColor = { 1.0, 0.8, 0.4 }
		local nutrientColor = { 1.0, 1.0, 0.0 }

		if entity.oxygen_cost then
			table.insert(stats, { label = "Oxigênio consumido", value = -entity.oxygen_cost, color = oxColor })
		elseif entity.oxygen_production then
			table.insert(stats, { label = "Oxigênio produzido", value = entity.oxygen_production, color = oxColor })
		end

		if entity.diet and entity.nutrient_cost then
			local dietLabel = "Dieta "
			dietLabel = entity.diet == "herbivore" and dietLabel .. "herbívora" or dietLabel .. "carnívora"
			dietLabel = dietLabel .. " consumida"
			table.insert(stats, { label = dietLabel, value = -entity.nutrient_cost, color = dietColor })
		elseif entity.nutrient_value then
			table.insert(stats, { label = "Nutrição gerada", value = entity.nutrient_value, color = nutrientColor })
		end

		if entity.biomass_cost then
			table.insert(stats, { label = "Biomassa consumida", value = -entity.biomass_cost, color = bioColor })
		end

		-- Calcula altura total das stats
		local statPadding = 4
		local statSpacing = lineSpacing
		local totalStatsHeight = 0
		for _, stat in ipairs(stats) do
			totalStatsHeight = totalStatsHeight + font:getHeight() + statPadding * 2 + statSpacing
		end
		if totalStatsHeight > 0 then totalStatsHeight = totalStatsHeight - statSpacing end

		-- Altura da caixa do nome
		local name = entity.name or entity.id
		local nameHeight = font:getHeight() + padding * 2

		-- Altura total do bloco
		local blockHeight = math.max(nameHeight, totalStatsHeight)
		local y = y_offset
		local nameY = y + (blockHeight - nameHeight) / 2

		-- Fundo alternado opcional
		if i % 2 == 0 then
			love.graphics.setColor(0, 0, 0, 0.15)
		else
			love.graphics.setColor(0, 0, 0, 0.05)
		end
		love.graphics.rectangle("fill", self.spawnWindow.x + 10, y, self.spawnWindow.w - 20, blockHeight, 8, 8)

		-- Caixa do nome
		local nameWidth = font:getWidth(name) + padding * 2
		if entity == self.spawnWindow.selectedEntity then
			love.graphics.setColor(0.5, 0.8, 1.0, 0.3)
		else
			love.graphics.setColor(0, 0, 0, 0.3)
		end
		love.graphics.rectangle("fill", x, nameY, nameWidth, nameHeight, 4, 4)

		-- Nome
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(name, x + padding, nameY + padding)

		-- Desenha stats
		local statX = x + nameWidth + 10
		local statY = y
		for _, stat in ipairs(stats) do
			local statText = string.format("%s: %.1f", stat.label, stat.value)
			local statWidth = font:getWidth(statText) + statPadding * 2
			local statHeight = font:getHeight() + statPadding * 2

			-- Caixa do stat
			love.graphics.setColor(0, 0, 0, 0.3)
			love.graphics.rectangle("fill", statX, statY, statWidth, statHeight, 3, 3)

			-- Texto
			love.graphics.setColor(stat.color)
			love.graphics.print(statText, statX + statPadding, statY + statPadding)

			-- Próximo stat embaixo
			statY = statY + statHeight + statSpacing
		end

		-- Linha divisória entre entidades
		if i < #self.spawnWindow.entityList then
			local lineY = y_offset + blockHeight + entitySpacing / 2 - 1
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.rectangle("fill", self.spawnWindow.x + 10, lineY, self.spawnWindow.w - 20, 1)
		end

		-- Próxima entidade
		y_offset = y_offset + blockHeight + entitySpacing

		love.graphics.setColor(1, 1, 1)
	end

	-- Botão de spawn
	UI.drawButton(self.spawnWindow.spawnEntityButton, self.uiFont)
end

function world:update(dt)
	-- Atualizar animações dos peixes
	self:updateFishAnimations(dt)

	-- Geração temporizada de biomassa pelos peixes
	self.fishBiomassTimer = self.fishBiomassTimer + dt

	if self.fishBiomassTimer >= self.fishBiomassInterval then
		local totalProd = 0

		for _, fish in ipairs(self.fishList) do
			totalProd = totalProd + fish.biomass_production
		end

		self.saveData.biomass = (self.saveData.biomass or 0) + totalProd

		self.fishBiomassTimer = 0
	end

	-- Movimentação dos peixes
	for _, fish in ipairs(self.fishList) do
		fish.x = fish.x + fish.velocityX * dt
		fish.y = fish.y + fish.velocityY * dt

		-- Inverter direção ao bater nas bordas
		if fish.x - (fish.width / 2) * fish.size < 0 or fish.x + (fish.width / 2) * fish.size > ww then
			fish.velocityX = -fish.velocityX
		end
		if fish.y - (fish.height / 2) * fish.size < self.topBarHeight or fish.y + (fish.height / 2) * fish.size > wh then
			fish.velocityY = -fish.velocityY
		end
	end
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

	-- Linha 1: Oxigênio e Biomassa
	love.graphics.setColor(self.uiLabels.oxygen.color)
	love.graphics.print(string.format("%s: %.2f mg O₂", self.uiLabels.oxygen.label, self.saveData.oxygen), startX, y1)
	love.graphics.setColor(self.uiLabels.biomass.color)
	love.graphics.print(string.format("%s: %.2f mg C", self.uiLabels.biomass.label, self.saveData.biomass), startX + spacing,
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

	love.graphics.pop()
end

function world:mousemoved(x, y)
	x, y = UI.scaleMouse(x, y)

	UI.updateButtonHover(self.backButton, x, y)
	UI.updateButtonHover(self.spawnButton, x, y)

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

	if button == 1 and not self.spawnWindow.visible then
		for _, plant in ipairs(self.plantList) do
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

		-- Verificar clique em entidades da lista
		if button == 1 then
			local y_offset = self.spawnWindow.y + 100
			local entitySpacing = 10
			local font = love.graphics.getFont()
			local padding = 5
			local lineSpacing = 5
			local statPadding = 4

			for _, entity in ipairs(self.spawnWindow.entityList) do
				-- Conta quantos stats existem pra calcular altura aproximada
				local statCount = 0
				if entity.oxygen_cost or entity.oxygen_production then statCount = statCount + 1 end
				if entity.diet and entity.nutrient_cost or entity.nutrient_value then statCount = statCount + 1 end
				if entity.biomass_cost then statCount = statCount + 1 end

				local totalStatsHeight = statCount * (font:getHeight() + statPadding * 2 + lineSpacing)
				if statCount > 0 then totalStatsHeight = totalStatsHeight - lineSpacing end

				local nameHeight = font:getHeight() + padding * 2
				local blockHeight = math.max(nameHeight, totalStatsHeight)
				local blockX = self.spawnWindow.x + 10
				local blockY = y_offset
				local blockW = self.spawnWindow.w - 20

				if x >= blockX and x <= blockX + blockW and y >= blockY and y <= blockY + blockHeight then
					self.spawnWindow.selectedEntity = entity
					break
				end

				y_offset = y_offset + blockHeight + entitySpacing
			end
		end


		for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
			UI.clickButton(tabBtn, button)
		end
	end
end

function world:mousereleased(x, y, button)
	if button == 1 then
		if self.draggedPlant then
			self.draggedPlant.normX = round3(self.draggedPlant.x / ww)
			self.draggedPlant.normY = round3(self.draggedPlant.y / wh)
			self.draggedPlant = nil
		end
	end
end

return world
