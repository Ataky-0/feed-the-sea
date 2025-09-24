local UI = {}

-- Função para criar um botão
function UI.newButton(text, x, y, w, h, action)
  return {
    text = text,
    x = x,
    y = y,
    w = w,
    h = h,
    hovered = false,
    action = action
  }
end

-- Função para desenhar o botão
function UI.drawButton(button, font)
  love.graphics.setFont(font)
  
  if button.hovered then
    love.graphics.setColor(0.9, 0.6, 0.2) -- hover
  else
    love.graphics.setColor(0.2, 0.6, 0.8) -- normal
  end
  
  love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 12, 12)

  -- borda
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("line", button.x, button.y, button.w, button.h, 12, 12)

  -- conteudo/texto
  love.graphics.setColor(1,1,1)
  love.graphics.printf(button.text, button.x, button.y + button.h/2 - 8, button.w, "center")
end

function UI.drawText(text, x, y, limit, align, color, font)
  love.graphics.setFont(font)
  love.graphics.setColor(color[1], color[2], color[3])
  love.graphics.printf(text, x, y, limit, align)
end

-- Função para atualizar hover
function UI.updateButtonHover(button, mx, my)
  button.hovered = mx > button.x and mx < button.x + button.w and my > button.y and my < button.y + button.h
end

-- Função pra processar clique
function UI.clickButton(button, mouseButton)
  if mouseButton == 1 and button.hovered and button.action then
    button.action()
  end
end

return UI
