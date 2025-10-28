-- world.lua
local UI = require("src.ui")
local sceneManager = require("src.sceneManager")
local savesManager = require("src.savesManager")
local entitiesManager = require("src.entitiesManager")
local world = {}

-- Adicionando tabela para armazenar os peixes no mundo
world.fishList = {}

function world:load(saveMeta)
	-- Carrega o conteúdo do save
	self.saveMeta = saveMeta
	self.saveData = savesManager.loadGame(saveMeta.file)
	if not self.saveData then
		error("Erro: save não pôde ser carregado.")
	end

	-- Fonts e layout
	self.titleFont = love.graphics.newFont(32)
	self.uiFont = love.graphics.newFont(18)
	self.topBarHeight = 80
	local ww, wh = love.graphics.getDimensions()

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
		entityList = {}, -- Para armazenar as entidades carregadas
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
		"Spawnar",
		self.spawnWindow.x + self.spawnWindow.w / 2 - 50,
		self.spawnWindow.y + self.spawnWindow.h - 50,
		100,
		30,
		function()
			if self.spawnWindow.selectedEntity then
				self:spawnFish(self.spawnWindow.selectedEntity)
			end
		end
	)
	--#endregion

	-- Botão para sair/voltar
	self.backButton = UI.newButton(
		"Menu",
		ww - 120, 20, 100, 40,
		function()
			sceneManager:changeScene("mainmenu")
		end
	)

	-- Mensagens de UI
	self.uiLabels = {
		oxygen = { label = "Oxi", color = { 0.5, 0.8, 1.0 } },
		biomass = { label = "Bio", color = { 0.9, 0.9, 0.3 } },
		herb = { label = "Herb", color = { 0.4, 1.0, 0.4 } },
		carn = { label = "Carn", color = { 1.0, 0.4, 0.4 } },
	}
end

-- Função para carregar entidades de acordo com a aba selecionada
function world:loadEntitiesForTab(tabIndex)
	self.spawnWindow.currentTab = tabIndex
	if tabIndex == 1 then            -- Aba "Peixes"
		self.spawnWindow.entityList = entitiesManager.getFishList()
	elseif tabIndex == 2 then        -- Aba "Plantas"
		self.spawnWindow.entityList = entitiesManager.getPlantList()
	elseif tabIndex == 3 then        -- Aba "Cardumes"
		self.spawnWindow.entityList = {} -- Implementar quando necessário
	end
end

-- Função para invocar (por enquanto) um peixe no mundo
function world:spawnFish(entity)
	local ww, wh = love.graphics.getDimensions()
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

-- Função para desenhar os peixes
function world:drawFish()
	for _, fish in ipairs(self.fishList) do
		love.graphics.setColor(1, 1, 1, 1)

		local sx = fish.velocityX >= 0 and 1 or -1

		love.graphics.push()
		love.graphics.translate(fish.x, fish.y)
		love.graphics.rotate(fish.currentTilt or 0)

		-- Aplicar flip no draw, sem mexer no scale global
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

-- Função para desenhar a janela de spawn
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
	for i, entity in ipairs(self.spawnWindow.entityList) do
		-- Destacar entidade selecionada
		if entity == self.spawnWindow.selectedEntity then
			love.graphics.setColor(0.5, 0.8, 1.0)
		else
			love.graphics.setColor(1, 1, 1)
		end

		local info = entity.name or entity.id
		info = info .. " ( "

		if entity.oxygen_cost then
			info = info .. string.format("-O2: %.1f", entity.oxygen_cost)
		elseif entity.oxygen_production then
			info = info .. string.format("O2+: %.1f", entity.oxygen_production)
		end

		if entity.diet and entity.nutrient_cost then
			local dietLabel = entity.diet == "herbivore" and "Herb" or "Carn"
			info = info .. string.format(" | %s: %.1f", dietLabel, entity.nutrient_cost)
		elseif entity.nutrient_value then
			info = info .. string.format(" | Nutr: %.1f", entity.nutrient_value)
		end

		if entity.biomass_cost then
			info = info .. string.format(" | Bio: %.1f", entity.biomass_cost)
		end

		info = info .. " )"

		love.graphics.print(info, self.spawnWindow.x + 20, y_offset + (i - 1) * 25)
	end

	-- Botão de spawn
	UI.drawButton(self.spawnWindow.spawnEntityButton, self.uiFont)
end

function world:update(dt)
	-- Atualizar animações dos peixes
	self:updateFishAnimations(dt)

	-- Movimentação simples
	local ww, wh = love.graphics.getDimensions()
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
	local ww, wh = love.graphics.getDimensions()

	-- Fundo geral
	love.graphics.clear(0 / 255, 40 / 255, 100 / 255)

	-- Barra superior de interface
	love.graphics.setColor(0, 0, 0, 0.4)
	love.graphics.rectangle("fill", 0, 0, ww, self.topBarHeight)

	-- Valores atuais (oxigênio e comida) organizados em 2 linhas
	love.graphics.setFont(self.uiFont)
	local y1 = 15 -- primeira linha
	local y2 = 40 -- segunda linha
	local startX = 40
	local spacing = 150

	-- Linha 1: Oxigênio e Biomassa
	love.graphics.setColor(self.uiLabels.oxygen.color)
	love.graphics.print(string.format("%s: %.1f", self.uiLabels.oxygen.label, self.saveData.oxygen), startX, y1)
	love.graphics.setColor(self.uiLabels.biomass.color)
	love.graphics.print(string.format("%s: %.1f", self.uiLabels.biomass.label, self.saveData.biomass), startX + spacing,
		y1)

	-- Linha 2: Herbívora e Carnívora
	love.graphics.setColor(self.uiLabels.herb.color)
	love.graphics.print(string.format("%s: %d", self.uiLabels.herb.label, self.saveData.food.herbivore), startX, y2)
	love.graphics.setColor(self.uiLabels.carn.color)
	love.graphics.print(string.format("%s: %d", self.uiLabels.carn.label, self.saveData.food.carnivore), startX + spacing,
		y2)

	-- Desenhar peixes
	self:drawFish()

	-- Botão de saída
	UI.drawButton(self.backButton, self.uiFont)
	UI.drawButton(self.spawnButton, self.uiFont)
	self:drawSpawnWindow()

	-- Nome do save no canto inferior esquerdo
	--todo: fazer isso desaparecer quando tivermos um background bonito
	love.graphics.setFont(self.uiFont)
	love.graphics.setColor(1, 1, 1, 0.6)
	love.graphics.print(self.saveMeta.name, 20, wh - 40)
end

function world:mousemoved(x, y)
	UI.updateButtonHover(self.backButton, x, y)
	UI.updateButtonHover(self.spawnButton, x, y)

	if self.spawnWindow.visible then
		UI.updateButtonHover(self.spawnWindow.closeButton, x, y)
		UI.updateButtonHover(self.spawnWindow.spawnEntityButton, x, y)

		for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
			UI.updateButtonHover(tabBtn, x, y)
		end
	end
end

function world:mousepressed(x, y, button)
	UI.clickButton(self.backButton, button)
	UI.clickButton(self.spawnButton, button)

	if self.spawnWindow.visible then
		UI.clickButton(self.spawnWindow.closeButton, button)
		UI.clickButton(self.spawnWindow.spawnEntityButton, button)

		-- Verificar clique em entidades da lista
		if button == 1 then
			local y_offset = self.spawnWindow.y + 100
			for i, entity in ipairs(self.spawnWindow.entityList) do
				local entityY = y_offset + (i - 1) * 25
				if x >= self.spawnWindow.x + 20 and x <= self.spawnWindow.x + 200 and
					y >= entityY and y <= entityY + 20 then
					self.spawnWindow.selectedEntity = entity
					break
				end
			end
		end

		for _, tabBtn in ipairs(self.spawnWindow.tabButtons) do
			UI.clickButton(tabBtn, button)
		end
	end
end

return world
