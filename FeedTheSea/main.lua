-- main.lua
-- Leia sceneManager.lua para entender como as cenas funcionam
local sceneManager = require("src.sceneManager")
local timerManager = require("src.timerManager")
local UI = require("src.ui")

function love.quit()
	local current = sceneManager.current
	if current and current.unload then
		current:unload()
	end
end

function love.load()
	sceneManager:changeScene("mainmenu")
	local w, h = love.graphics.getDimensions()
	love.window.setMode(w, h, {resizable = true, minwidth = UI.UI_BASE_W, minheight = UI.UI_BASE_H})
	love.keyboard.setKeyRepeat(true) -- Para o backspace não enganchar
end

function love.update(dt)
	sceneManager:update(dt)
	timerManager:update(dt)
end

function love.draw()
	sceneManager:draw()
end

function love.resize(w, h)
	-- Manter o tamanho mínimo da janela baseado na resolução atual em ui
	-- if w < UI.UI_BASE_W or h < UI.UI_BASE_H then
	-- 	love.window.setMode(UI.UI_BASE_W,UI.UI_BASE_H,{resizable=true,minwidth=UI.UI_BASE_W,minheight=UI.UI_BASE_H})
	-- end
end

function love.keypressed(key)
	sceneManager:keypressed(key)
end

function love.keyreleased(key)
	sceneManager:keyreleased(key)
end

function love.textinput(t)
	sceneManager:textinput(t)
end

function love.wheelmoved(x, y)
	sceneManager:wheelmoved(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
	sceneManager:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	sceneManager:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	sceneManager:mousereleased(x, y, button, istouch, presses)
end
