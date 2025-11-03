-- newgame.lua
local UI = require("src.ui")
local sceneManager = require("src.sceneManager")
local savesManager = require("src.savesManager")
local timerManager = require("src.timerManager")

local newgame = {}

function newgame:load()
	self.backButton = UI.newButton("<", 10, 10, 60, 50, function()
		sceneManager:changeScene("mainmenu")
	end)

	self.title = "Novo Jogo"
	self.titleFont = love.graphics.newFont(48)
	self.navButtonsFont = love.graphics.newFont(20)
	self.inputFont = love.graphics.newFont(18)
	self.messageFont = love.graphics.newFont(24)

	local ww, wh = love.graphics.getDimensions()
	local inputWidth, inputHeight = 300, 40
	local spacing = 15

	-- Array com inputs (Por enquanto apenas o nome)
	local x = (ww - inputWidth) / 2
	local y = wh * 0.4 + (inputHeight + spacing)
	self.inputs = {}
	table.insert(self.inputs,
		UI.newTextInput("Nome do Save ", "left", "Meu Oceano..", x, y, inputWidth, inputHeight, self.inputFont))

	-- Botão "Create Game"
	local btnW, btnH = 200, 50
	self.createButton = UI.newButton(
		"Criar jogo",
		(ww - btnW) / 2,
		self.inputs[#self.inputs].y + inputHeight + 80,
		btnW,
		btnH,
		function()
			-- Evitar que o botão seja spammado
			self.createButton.disabled = true

			-- Pega o nome do save do input
			local saveName = self.inputs[1].text
			if saveName == "" or saveName:match("^%s*$") then
				self.createdFeedback = UI.newMessage("Não pode criar um Save sem nome!", self.messageFont)
				timerManager:set(1, function()
					self.createdFeedback.closed = true
					self.createButton.disabled = false
				end)
				return
			end

			local save, _ = savesManager.createSave(saveName)

			if save then -- Aqui vamos inserir o feedback visual e então continuar o fluxo.
				self.createdFeedback = UI.newMessage("Save criado com sucesso!", self.messageFont)
				timerManager:set(1, function()
					self.createdFeedback.closed = true
					sceneManager:changeScene("loadgame")
				end)
			else
				self.createdFeedback = UI.newMessage("Save não pôde ser criado!!", self.messageFont)
				timerManager:set(2, function()
					self.createButton.disabled = false
				end)
			end
		end,
		self.navButtonsFont
	)
end

function newgame:draw()
	local ww, wh = love.graphics.getDimensions()

	love.graphics.clear(0 / 255, 30 / 255, 80 / 255)

	UI.drawText(self.title, 0, wh * 0.05, ww, "center", { 1, 1, 1 }, self.titleFont)

	-- Desenhar os inputs (sem passar fonte agora)
	for _, input in ipairs(self.inputs) do
		UI.drawTextInput(input)
	end

	-- Botões
	UI.drawButton(self.backButton, self.navButtonsFont)
	UI.drawButton(self.createButton, self.navButtonsFont)
	if self.createdFeedback then UI.drawMessage(self.createdFeedback) end
end

function newgame:mousemoved(x, y)
	UI.updateButtonHover(self.backButton, x, y)
	UI.updateButtonHover(self.createButton, x, y)

	for _, input in ipairs(self.inputs) do
		UI.updateTextInputHover(input, x, y)
	end
end

function newgame:mousepressed(x, y, button)
	UI.clickButton(self.backButton, button)
	UI.clickButton(self.createButton, button)

	for _, input in ipairs(self.inputs) do
		UI.clickTextInput(input, button)
	end

	if self.createdFeedback then
		UI.clickMessage(self.createdFeedback, x, y)
	end
end

function newgame:keypressed(key)
	if key == "escape" then
		sceneManager:changeScene("mainmenu")
	end

	-- Essa linha é para garantir que as teclas especiais sejam escutadas
	-- Por exemplo: Backspace, Enter e etc
	for _, input in ipairs(self.inputs) do UI.keypressedTextInput(input, key) end
end

-- Aqui é onde a magia realmente acontece
-- Essa belezinha consegue tratar até acentuação
function newgame:textinput(t)
	for _, input in ipairs(self.inputs) do
		UI.textinputTextInput(input, t)
	end
end

return newgame
