local sceneManager = require("src.sceneManager")

function love.load()
  sceneManager:changeScene("mainmenu")
end

function love.update(dt)
  sceneManager:update(dt)
end

function love.draw()
  sceneManager:draw()
end

function love.keypressed(key)
  sceneManager:keypressed(key)
end

function love.mousemoved(x, y, dx, dy, istouch)
  sceneManager:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
  sceneManager:mousepressed(x, y, button, istouch, presses)
end
