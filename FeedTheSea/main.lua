-- main.lua
-- Leia sceneManager.lua para entender como as cenas funcionam
local sceneManager = require("src.sceneManager")
local timerManager = require("src.timerManager")

function love.quit()
	local current = sceneManager.current
	if current and current.unload then
		current:unload()
	end
end

function love.load()
	sceneManager:changeScene("mainmenu")
	love.keyboard.setKeyRepeat(true) -- Para o backspace não enganchar
end

function love.update(dt)
	sceneManager:update(dt)
	timerManager:update(dt)
end

function love.draw()
	sceneManager:draw()
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

function love.mousemoved(x, y, dx, dy, istouch)
	sceneManager:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	sceneManager:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	sceneManager:mousereleased(x, y, button, istouch, presses)
end
