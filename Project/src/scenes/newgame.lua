local UI = require("src.ui")
local sceneManager = require("src.sceneManager")

-- Define a cena
local newgame = {}

function newgame:load()
  self.backButton = UI.newButton("<", 10, 10, 60, 50, function()
    sceneManager:changeScene("mainmenu")
  end)

  self.title = "New Game"
  self.titleFont = love.graphics.newFont(48)
  self.navButtonsFont = love.graphics.newFont(20)
  self.inputFont = love.graphics.newFont(18)

  local ww, wh = love.graphics.getDimensions()
  local inputWidth, inputHeight = 300, 40
  local spacing = 15

  -- Array com inputs (Por enquanto apenas o nome)
  local x = (ww - inputWidth) / 2
  local y = wh * 0.4 + (inputHeight + spacing)
  self.inputs = {}
  table.insert(self.inputs, UI.newTextInput("Save Name ", "left", "My Ocean..", x, y, inputWidth, inputHeight, self.inputFont))
  -- for i = 1, 3 do
  --   local x = (ww - inputWidth) / 2
  --   local y = wh * 0.3 + (i - 1) * (inputHeight + spacing)
  --   -- passa a fonte já aqui:
  --   table.insert(self.inputs, UI.newTextInput("", "top", "", x, y, inputWidth, inputHeight, self.inputFont))
  -- end

  -- Botão "Create Game"
  local btnW, btnH = 200, 50
  self.createButton = UI.newButton(
    "Create Game",
    (ww - btnW) / 2,
    self.inputs[#self.inputs].y + inputHeight + 80,
    btnW,
    btnH,
    function()
      -- TODO: ação para criar jogo
    end
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
