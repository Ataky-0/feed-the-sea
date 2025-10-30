local UI = require("src.ui")
local sceneManager = require("src.sceneManager")

local optionsScene = {}

function optionsScene:load()
	--local ww, wh = love.graphics.getDimensions()
	self.backButton = UI.newButton("<", 10, 10, 60, 50, function()
		sceneManager:changeScene("mainmenu")
	end)
	self.title = "Options"
	self.titleFont = love.graphics.newFont(48)

	self.navButtonsFont = love.graphics.newFont(20)
end

function optionsScene:draw()
	local ww, wh = love.graphics.getDimensions()

	love.graphics.clear(0 / 255, 30 / 255, 80 / 255)

	-- Título da cena
	UI.drawText(self.title, 0, wh * 0.2, ww, "center", { 1, 1, 1 }, self.titleFont)

	-- Botões de configuração

	--TODO

	-- Botões de navegação
	UI.drawButton(self.backButton, self.navButtonsFont)
end

function optionsScene:mousemoved(x, y)
	UI.updateButtonHover(self.backButton, x, y)
end

function optionsScene:mousepressed(x, y, button)
	UI.clickButton(self.backButton, button)
end

function optionsScene:keypressed(key)
	if key == "escape" then
		sceneManager:changeScene("mainmenu")
	end
end

return optionsScene
