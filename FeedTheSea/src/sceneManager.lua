-- Tudo que ocorre na main que será usado nas cenas
-- tem que ser replicado, esta relação é facilmente
-- observada ao comparar a main.lua com o src/sceneManager.lua.

-- Toda ação a princípio é capturada na main e jogada para a cena atual.

local sceneManager = {
  current = nil,
  scenes = {}
}

function sceneManager:changeScene(name)
  if self.current and self.current.unload then
    self.current:unload()
  end

  if not self.scenes[name] then
    self.scenes[name] = require("src.scenes." .. name)
  end

  self.current = self.scenes[name]
  if self.current.load then
    self.current:load()
  end
end

function sceneManager:update(dt)
  if self.current and self.current.update then
    self.current:update(dt)
  end
end

function sceneManager:draw()
  if self.current and self.current.draw then
    self.current:draw()
  end
end

function sceneManager:keypressed(key)
  if self.current and self.current.keypressed then
    self.current:keypressed(key)
  end
end

function sceneManager:keyreleased(key)
  if self.current and self.current.keyreleased then
    self.current:keyreleased(key)
  end
end

function sceneManager:textinput(t)
  if self.current and self.current.textinput then
    self.current:textinput(t)
  end
end

function sceneManager:mousemoved(x, y, dx, dy, istouch)
  if self.current and self.current.mousemoved then
    self.current:mousemoved(x, y, dx, dy, istouch)
  end
end

function sceneManager:mousepressed(x, y, button, istouch, presses)
  if self.current and self.current.mousepressed then
    self.current:mousepressed(x, y, button, istouch, presses)
  end
end

return sceneManager
