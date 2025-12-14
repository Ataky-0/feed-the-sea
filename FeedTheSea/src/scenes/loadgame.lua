-- loadgame.lua
local UI = require("src.ui")
local sceneManager = require("src.sceneManager")
local savesManager = require("src.savesManager")

local loadgame = {}

local ww, wh = UI.getDimensions()

function loadgame:load()
	-- Renova dimensões
	ww, wh = UI.getDimensions()

	self.title = "Carregar Jogo"
	self.titleFont = love.graphics.newFont(48)
	self.navFont = love.graphics.newFont(20)
	self.itemFont = love.graphics.newFont(18)
	self.smallFont = love.graphics.newFont(14)

	-- Botões de navegação
	self.backButton = UI.newButton("<", 10, 10, 60, 50, function()
		sceneManager:changeScene("mainmenu")
	end)

	self.nextPageButton = UI.newButton(">", ww - 70, wh - 70, 60, 50, function()
		if self.currentPage < self.totalPages then
			self.currentPage = self.currentPage + 1
		end
	end)

	self.prevPageButton = UI.newButton("<", 10, wh - 70, 60, 50, function()
		if self.currentPage > 1 then
			self.currentPage = self.currentPage - 1
		end
	end)

	self.saves = savesManager.listSaves()
	self.currentPage = 1
	self.perPage = 9        -- 2 colunas x 3 linhas
	self.confirmDialog = nil -- confirmação de deletar
	self:updatePagination()
end

function loadgame:unload()
	loadgame = nil
end

-- Dinamicamente calcula o total de páginas
function loadgame:updatePagination()
	self.totalPages = math.max(1, math.ceil(#self.saves / self.perPage))
end

-- Abre uma janela de confirmação para deletar 'save'
function loadgame:openConfirm(save) -- Fix: precisa ajeitar a escala disso aqui ainda
	-- não abrir outra se já existir
	if self.confirmDialog then return end

	local sx, sy = UI.getScale()

	local text = string.format(
		"Deseja realmente deletar o %s?",
		save.name or "save"
	)

	local msg = UI.newMessage(text, self.smallFont)
	msg.x = ww / 2
	msg.y = wh / 2
	msg.closable = false
	msg._saveRef = save

	-- ===== ESCALA REAL (AQUI TÁ O SEGREDO) =====

	local scale = math.min(sx, sy)

	local padding = math.floor(20 * scale)
	local spacing = math.floor(20 * scale)

	local btnW = math.floor(100 * scale)
	local btnH = math.floor(42 * scale)

	-- limites de sanidade
	btnW = math.max(90, math.min(btnW, 160))
	btnH = math.max(36, math.min(btnH, 60))

	-- Texto
	local tw = msg.font:getWidth(msg.text)
	local th = msg.font:getHeight()

	local boxW = tw + padding * 2
	local boxH = th + padding * 2

	-- Botões centralizados abaixo da caixa
	local totalBtnsW = btnW * 2 + spacing
	local bx = msg.x - totalBtnsW / 2
	local by = msg.y + boxH / 2 + spacing

	msg._yesBtn = UI.newButton("Sim", bx, by, btnW, btnH, function()
		savesManager.deleteSave(msg._saveRef.file)
		self.saves = savesManager.listSaves()
		self:updatePagination()
		if self.currentPage > self.totalPages then
			self.currentPage = self.totalPages
		end
		self.confirmDialog = nil
	end, self.smallFont)

	msg._noBtn = UI.newButton("Não", bx + btnW + spacing, by, btnW, btnH, function()
		self.confirmDialog = nil
	end, self.smallFont)

	self.confirmDialog = msg
end

-- Atualizar posições dos botões (para o caso da janela ser redimensionada)
function loadgame:updateConfirmPositions()
	if not self.confirmDialog then return end
	local msg = self.confirmDialog
	local tw = msg.font:getWidth(msg.text)
	local th = msg.font:getHeight()
	local padding = 16
	local boxW = tw + padding * 2
	local boxH = th + padding

	local btnW, btnH = msg._yesBtn.w, msg._yesBtn.h
	local spacing = 16
	local totalBtnsW = btnW * 2 + spacing

	local bx = msg.x - totalBtnsW / 2
	local by = msg.y + boxH / 2 + 12

	msg._yesBtn.x = bx
	msg._yesBtn.y = by
	msg._noBtn.x = bx + btnW + spacing
	msg._noBtn.y = by
end

function loadgame:draw()
	local sx, sy = UI.getScale()

	love.graphics.clear(0 / 255, 30 / 255, 80 / 255)

	love.graphics.push()
	love.graphics.scale(sx, sy)

	-- Título
	UI.drawText(self.title, 0, 30, ww, "center", { 1, 1, 1 }, self.titleFont)

	-- Botão voltar
	UI.drawButton(self.backButton, self.navFont)

	-- ===== LAYOUT RESPONSIVO 3x3 =====

	local cols, rows = 3, 3
	local spacingX, spacingY = 30, 30

	local marginTop = 110
	local marginSide = 80
	local marginBottom = 100

	local usableW = ww - marginSide * 2
	local usableH = wh - marginTop - marginBottom

	local cardW = math.min(
		500,
		(usableW - spacingX * (cols - 1)) / cols
	)

	local cardH = math.min(
		200,
		(usableH - spacingY * (rows - 1)) / rows
	)

	local startX = (ww - (cardW * cols + spacingX * (cols - 1))) / 2
	local startY = marginTop

	-- ===== PAGINAÇÃO =====

	local startIdx = (self.currentPage - 1) * self.perPage + 1
	local endIdx = math.min(startIdx + self.perPage - 1, #self.saves)

	for i = startIdx, endIdx do
		local save = self.saves[i]
		local localIndex = i - startIdx
		local col = localIndex % cols
		local row = math.floor(localIndex / cols)

		local x = startX + col * (cardW + spacingX)
		local y = startY + row * (cardH + spacingY)

		self:drawSaveCard(save, x, y, cardW, cardH)
	end

	-- Navegação
	if self.currentPage > 1 then
		UI.drawButton(self.prevPageButton, self.navFont)
	end

	if self.currentPage < self.totalPages then
		UI.drawButton(self.nextPageButton, self.navFont)
	end

	UI.drawText(
		string.format("Página %d / %d", self.currentPage, self.totalPages),
		0, wh - 40, ww, "center", { 1, 1, 1 }, self.navFont
	)

	-- Confirmação
	if self.confirmDialog then
		self:updateConfirmPositions()
		UI.drawMessage(self.confirmDialog)
		UI.drawButton(self.confirmDialog._yesBtn, self.smallFont)
		UI.drawButton(self.confirmDialog._noBtn, self.smallFont)
	end

	love.graphics.pop()
end

-- Desenhar caixa de save (unidade)
function loadgame:drawSaveCard(save, x, y, w, h)
	-- Fundo
	love.graphics.setColor(0.1, 0.3, 0.6)
	love.graphics.rectangle("fill", x, y, w, h, 16, 16)

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x, y, w, h, 16, 16)

	-- Nome truncado
	love.graphics.setFont(self.itemFont)
	local maxWidth = w - 20
	local name = save.name

	while self.itemFont:getWidth(name) > maxWidth and #name > 3 do
		name = name:sub(1, -2)
	end

	if self.itemFont:getWidth(save.name) > maxWidth then
		name = name:sub(1, -4) .. "..."
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.printf(name, x + 10, y + 10, maxWidth, "left")

	-- Última visita
	love.graphics.setFont(self.smallFont)
	love.graphics.setColor(0.85, 0.85, 0.85)
	love.graphics.printf(
		"Última visita: " .. save.last_played,
		x + 10, y + 40, maxWidth, "left"
	)

	-- Botões (CRIADOS UMA VEZ, POSIÇÃO ATUALIZADA SEMPRE)
	local pad = math.floor(w * 0.03)

	local btnW = math.min(200, math.max(120, w * 0.4))
	local btnH = math.min(65, math.max(40, h * 0.28))

	local btnY = y + h - btnH - pad

	if not save._loadBtn then
		save._loadBtn = UI.newButton("Carregar", 0, 0, btnW, btnH, function()
			print("Carregando save:", save.file)
			-- Troca a cena para o mundo
			sceneManager:changeScene("world", save)
		end)

		save._deleteBtn = UI.newButton("Deletar", 0, 0, btnW, btnH, function()
			self:openConfirm(save)
		end)
	end

	save._loadBtn.x = x + pad
	save._loadBtn.y = btnY

	save._deleteBtn.x = x + w - btnW - pad
	save._deleteBtn.y = btnY

	UI.drawButton(save._loadBtn, self.smallFont)
	UI.drawButton(save._deleteBtn, self.smallFont)
end

function loadgame:mousemoved(x, y)
	x, y = UI.scaleMouse(x, y)
	-- se houver diálogo, apenas atualizar hover dos botões do diálogo
	if self.confirmDialog then
		UI.updateButtonHover(self.confirmDialog._yesBtn, x, y)
		UI.updateButtonHover(self.confirmDialog._noBtn, x, y)
		return
	end

	UI.updateButtonHover(self.backButton, x, y)
	UI.updateButtonHover(self.nextPageButton, x, y)
	UI.updateButtonHover(self.prevPageButton, x, y)

	for _, save in ipairs(self.saves) do
		if save._loadBtn then UI.updateButtonHover(save._loadBtn, x, y) end
		if save._deleteBtn then UI.updateButtonHover(save._deleteBtn, x, y) end
	end
end

function loadgame:mousepressed(x, y, button)
	x, y = UI.scaleMouse(x, y)
	-- se houver diálogo, apenas processar os botões do diálogo
	if self.confirmDialog then
		local yesBtn = self.confirmDialog._yesBtn
		local noBtn = self.confirmDialog._noBtn

		UI.clickButton(yesBtn, button)
		UI.clickButton(noBtn, button)
		return
	end

	UI.clickButton(self.backButton, button)
	UI.clickButton(self.nextPageButton, button)
	UI.clickButton(self.prevPageButton, button)

	for _, save in ipairs(self.saves) do
		if save._loadBtn then UI.clickButton(save._loadBtn, button) end
		if save._deleteBtn then UI.clickButton(save._deleteBtn, button) end
	end
end

function loadgame:keypressed(key)
	if key == "escape" then
		-- fechar diálogo se aberto, senão voltar ao menu
		if self.confirmDialog then
			self.confirmDialog = nil
		else
			sceneManager:changeScene("mainmenu")
		end
	elseif key == "left" and self.currentPage > 1 then
		self.currentPage = self.currentPage - 1
	elseif key == "right" and self.currentPage < self.totalPages then
		self.currentPage = self.currentPage + 1
	end
end

return loadgame
