local sceneManager = require("src.sceneManager")
local UI = require("src.ui")

local mainmenu = {}
local selected = 1

function mainmenu:load()
	local ww, wh = love.graphics.getDimensions()

	-- título
	self.title = "Feed the Sea"
	self.titleFont = love.graphics.newFont(48)

	-- botões
	self.buttonFont = love.graphics.newFont(24)
	self.buttons = {}

	local bw, bh = 200, 50
	local bx = (ww - bw) / 2
	local by = wh * 0.4

	local labels = { "Novo Jogo", "Carregar Jogo", "Opções" }
	for i, text in ipairs(labels) do
		local btn = UI.newButton(text, bx, by + (i - 1) * (bh + 15), bw, bh, function()
			if text == "Opções" then
				sceneManager:changeScene("options")
			elseif text == "Novo Jogo" then
				sceneManager:changeScene("newgame")
			elseif text == "Carregar Jogo" then
				sceneManager:changeScene("loadgame")
			end
		end)
		table.insert(self.buttons, btn)
	end
end

function mainmenu:update(dt)
	-- A gente pode colocar animações por aqui se quiser
end

function mainmenu:draw()
	local ww, wh = love.graphics.getDimensions()

	love.graphics.clear(0 / 255, 30 / 255, 80 / 255)

	-- título
	UI.drawText(self.title, 0, wh * 0.2, ww, "center", { 1, 1, 1 }, self.titleFont)

	-- desenhar botões via UI
	love.graphics.setFont(self.buttonFont)
	for _, b in ipairs(self.buttons) do
		UI.drawButton(b, self.buttonFont)
	end
end

function mainmenu:keypressed(key)
	if key == "up" then
		selected = selected - 1
		if selected < 1 then selected = #self.buttons end
	elseif key == "down" then
		selected = selected + 1
		if selected > #self.buttons then selected = 1 end
	elseif key == "return" or key == "space" then
		self.buttons[selected].action()
	end
end

function mainmenu:mousemoved(x, y, dx, dy, istouch)
	for _, b in ipairs(self.buttons) do
		UI.updateButtonHover(b, x, y)
	end
end

function mainmenu:mousepressed(x, y, button, istouch, presses)
	for _, b in ipairs(self.buttons) do
		UI.clickButton(b, button)
	end
end

return mainmenu
