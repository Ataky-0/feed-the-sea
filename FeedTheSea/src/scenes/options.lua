-- options.lua

local UI = require("src.ui")
local sceneManager = require("src.sceneManager")

local options = {}

local ww, wh = UI.getDimensions()

local resolutions = {
	{ 800,  600 },
	{ 1280, 720 },
	{ 1366, 768 },
	{ 1920, 1080 },
}

local function formatRes(r) return string.format("%dx%d", r[1], r[2]) end

function options:load()
	ww, wh              = UI.getDimensions()

	self.backButton     = UI.newButton("<", 10, 10, 60, 50, function()
		sceneManager:changeScene("mainmenu")
	end)

	self.title          = "Opções"
	self.titleFont      = love.graphics.newFont(48)
	self.navButtonsFont = love.graphics.newFont(20)

	-- índice da resolução atual
	self.currentResIdx  = 1
	for i, r in ipairs(resolutions) do
		if r[1] == UI.UI_BASE_W and r[2] == UI.UI_BASE_H then
			self.currentResIdx = i
			break
		end
	end

	-- botão que abre a lista de resoluções
	self.resButton = UI.newButton(
		"Resolução: " .. formatRes(resolutions[self.currentResIdx]),
		ww / 2 - 150, wh * 0.5 - 25, 300, 50,
		function()
			if self.showResList then
				self.showResList = false
				self.resButton.disabled = false
			else
				self.showResList = true
				self.resButton.disabled = true
			end
		end
	)

	-- Criar os botões da lista (invisíveis até que a janela seja mostrada)
	self.resListButtons = {}
	local startX = ww / 2 - 100  -- margem esquerda da caixa
	local startY = wh / 2 - 100 + 10 -- margem superior + padding interno

	for i, r in ipairs(resolutions) do
		local btn = UI.newButton(
			formatRes(r),
			startX,
			startY + (i - 1) * 55, -- posição Y dentro da caixa
			200, 45,
			function()
				self.currentResIdx = i
				UI.setDimensions(r[1], r[2])
				self.resButton.label = "Resolução: " .. formatRes(r)
				self.showResList = false
			end
		)
		table.insert(self.resListButtons, btn)
	end
end

function options:unload()
	options = nil
end

function options:draw()
	local sx, sy = UI.getScale()

	love.graphics.clear(0 / 255, 30 / 255, 80 / 255)

	love.graphics.push()
	love.graphics.scale(sx, sy)

	UI.drawText(self.title, 0, wh * 0.2, ww, "center", { 1, 1, 1 }, self.titleFont)

	UI.drawButton(self.resButton, self.navButtonsFont)
	UI.drawButton(self.backButton, self.navButtonsFont)

	-- Desenhar a janela de seleção, se estiver ativa
	if self.showResList then
		-- Fundo semi‑transparente da janela
		love.graphics.setColor(0, 0, 0, 0.6)
		love.graphics.rectangle(
			"fill",
			ww / 2 - 120, wh / 2 - 100,      -- Canto superior‑esquerdo da caixa
			240, #self.resListButtons * 55 + 20 -- largura × altura da caixa
		)

		love.graphics.setColor(1, 1, 1, 1) -- texto normal

		-- Cálculo do ponto de início dentro da caixa
		local innerX = ww / 2 - 100    -- margem esquerda dos botões
		local innerY = wh / 2 - 100 + 10 -- margem superior + padding interno

		for i, btn in ipairs(self.resListButtons) do
			-- guardamos as coordenadas originais para restaurar depois
			local origX, origY = btn.x, btn.y

			-- colocamos o botão *relativamente* à caixa
			btn.x = innerX
			btn.y = innerY + (i - 1) * 55        -- espaçamento vertical entre os botões

			UI.drawButton(btn, self.navButtonsFont) -- usa a rotina de desenho

			-- restaura as coordenadas originais (caso o botão seja usado em outro contexto)
			btn.x, btn.y = origX, origY
		end
	end

	love.graphics.pop()
end

function options:mousemoved(x, y, dx, dy, istouch)
	x, y = UI.scaleMouse(x, y)                 -- converte coordenadas para escala UI
	UI.updateButtonHover(self.backButton, x, y) -- atualizar hover dos botões principais
	UI.updateButtonHover(self.resButton, x, y)

	if self.showResList then
		for _, btn in ipairs(self.resListButtons) do
			UI.updateButtonHover(btn, x, y)
		end
	end
end

function options:mousepressed(x, y, button, istouch, presses)
	x, y = UI.scaleMouse(x, y)             -- converte coordenadas para escala UI
	UI.clickButton(self.backButton, button) -- clique nos botões principais
	UI.clickButton(self.resButton, button)

	if self.showResList then
		for _, btn in ipairs(self.resListButtons) do
			UI.clickButton(btn, button)
		end
	end
end

function options:keypressed(key)
	if key == "escape" then
		sceneManager:changeScene("mainmenu")
	end
end

return options
