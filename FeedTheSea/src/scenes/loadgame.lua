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
	self.perPage = 9       -- 2 colunas x 3 linhas
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
function loadgame:openConfirm(save)
	-- não abrir outra se já existir
	if self.confirmDialog then return end

	local text = string.format("Deseja realmente deletar o %s?", save.name or "save")
	local msg = UI.newMessage(text, self.smallFont)
	msg.x = ww / 2
	msg.y = wh / 2
	msg.closable = false -- fechamos via botões
	msg._saveRef = save

	-- calcular botões posicionados abaixo da mensagem
	local tw = msg.font:getWidth(msg.text)
	local th = msg.font:getHeight()
	local padding = 16
	local boxW = tw + padding * 2
	local boxH = th + padding

	local btnW, btnH = 80, 36
	local spacing = 16
	local totalBtnsW = btnW * 2 + spacing

	local bx = msg.x - totalBtnsW / 2
	local by = msg.y + boxH / 2 + 12

	msg._yesBtn = UI.newButton("Sim", bx, by, btnW, btnH, function()
		-- executar deleção
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

	-- Botões principais
	UI.drawButton(self.backButton, self.navFont)

	-- Layout da página
	local startX, startY = ww * 0.1, 110
	local baseCardW, baseCardH = 500, 200
	local cardW, cardH = baseCardW / sx, baseCardH / sy
	local spacingX, spacingY = 30, 30
	local cols = 3

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

	-- Navegação de página
	if self.currentPage > 1 then
		UI.drawButton(self.prevPageButton, self.navFont)
	end

	if self.currentPage < self.totalPages then
		UI.drawButton(self.nextPageButton, self.navFont)
	end

	-- Info de página
	UI.drawText(
		string.format("Página %d / %d", self.currentPage, self.totalPages),
		0, wh - 40, ww, "center", { 1, 1, 1 }, self.navFont
	)

	-- Se houver diálogo de confirmação, desenhar por cima
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
	local sx, sy = UI.getScale()
	-- Fundo do card
	love.graphics.setColor(0.1, 0.3, 0.6)
	love.graphics.rectangle("fill", x, y, w, h, 16, 16)

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x, y, w, h, 16, 16)

	-- Nome truncado
	love.graphics.setFont(self.itemFont)
	local maxWidth = w - 20
	local name = save.name
	while self.itemFont:getWidth(name) > maxWidth do
		name = name:sub(1, -2)
		if #name <= 3 then break end
	end
	if self.itemFont:getWidth(save.name) > maxWidth then
		name = name:sub(1, -4) .. "..."
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.printf(name, x + 10, y + 10, maxWidth, "left")

	-- Última visita
	love.graphics.setFont(self.smallFont)
	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.printf("Última visita: " .. save.last_played, x + 10, y + 40, maxWidth, "left")

	-- Botões
	if not save._loadBtn then
		local pad = 10 / sx

		local btnW = 200 / sx
		local btnH = 65 / sy
		local btnY = y + h - (75 / sy)

		save._loadBtn = UI.newButton("Carregar", x + pad, btnY, btnW, btnH, function()
			print("Carregando save:", save.file)
			-- Troca a cena para o mundo
			sceneManager:changeScene("world", save)
		end)

		btnW = 200 / sx
		btnH = 65 / sy
		local btnX = x + w - btnW - pad
		btnY = y + h - (75 / sy)

		local s = save -- capturar referência local
		save._deleteBtn = UI.newButton("Deletar", btnX, btnY, btnW, btnH, function()
			self:openConfirm(s)
		end)
	end

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