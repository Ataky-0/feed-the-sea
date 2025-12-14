-- ui.lua
local utf8 = require("utf8")

local sceneManager = require("src.sceneManager")

local UI = {}

UI.UI_BASE_W = 1280
UI.UI_BASE_H = 720
-- Funções locais para auxílio

local function updateInputText(input, newText)
	input.text = newText
	input.textObject:set(input.text)
end

-- Função para obter dimensões ao longo de todo o jogo
function UI.getDimensions()
	return UI.UI_BASE_W, UI.UI_BASE_H
end

-- Função para alterar resolução
function UI.setDimensions(newW, newH)
	-- love.window.setMode(UI.UI_BASE_W, UI.UI_BASE_H, {minwidth=UI.UI_BASE_W, minheight=UI.UI_BASE_H})
	local w, h = love.graphics.getDimensions()
	UI.UI_BASE_W, UI.UI_BASE_H = newW, newH
	love.window.setMode(w, h, { resizable = true, minwidth = UI.UI_BASE_W, minheight = UI.UI_BASE_H })
	sceneManager:reloadScene()
end

-- Função para obter escala atual da UI baseada em resolução
function UI.getScale()
	local ww, wh = love.graphics.getDimensions()
	local sx = ww / UI.UI_BASE_W
	local sy = wh / UI.UI_BASE_H
	return sx, sy
end

-- Função para escalar coordenadas do mouse
function UI.scaleMouse(x, y)
	local sx, sy = UI.getScale()
	return x / sx, y / sy
end

-- Função para criar um input de texto
function UI.newTextInput(label, labelPos, placeholder, x, y, w, h, font)
	local textObject = love.graphics.newText(font or love.graphics.getFont(), "")

	return {
		text = "",
		label = label or "",
		labelPos = labelPos or "top", -- top, bottom, left, right
		placeholder = placeholder or "",
		x = x,
		y = y,
		w = w,
		h = h,
		focused = false,
		hovered = false,
		textObject = textObject,
		font = font or love.graphics.getFont(),
		placeholderObject = love.graphics.newText(font or love.graphics.getFont(), placeholder or "")
	}
end

-- Função para criar um botão
function UI.newButton(text, x, y, w, h, action, font)
	return {
		text = text,
		x = x,
		y = y,
		w = w,
		h = h,
		hovered = false,
		action = action,
		disabled = false,
		sound = nil,
		font = font or love.graphics.getFont()
	}
end

-- Função para criar mensagem clicável
function UI.newMessage(text, font)
	local ww, wh = UI.getDimensions()
	local message = {
		text = text or "",
		x = ww / 2,
		y = wh / 2,
		alpha = 0.9,
		font = font or love.graphics.getFont(),
		hovered = false,
		closed = false,
		closable = true, -- fecha ao clicar
	}
	return message
end

-- Função para criar tooltip (mensagem preso ao mouse)
function UI.newTooltip(text, font, maxX)
	local tooltip = {
		text = text or "",
		font = font or love.graphics.getFont(),
		maxX = maxX or 0,
		alpha = 0.9,
		visible = false
	}
	return tooltip
end

-- Função para desenhar tooltip
function UI.drawTooltip(tooltip)
	if not tooltip.visible then return end

	local mx, my = UI.scaleMouse(love.mouse.getPosition())
	local font = tooltip.font
	love.graphics.setFont(font)

	-- quebra automática de linhas
	local maxWidth = tooltip.maxX or 300
	local wrappedText, wrappedLines = font:getWrap(tooltip.text, maxWidth)

	-- calcula largura/altura final do texto
	local tw = 0
	for _, line in ipairs(wrappedLines) do
		local w = font:getWidth(line)
		if w > tw then tw = w end
	end

	local lineHeight = font:getHeight()
	local th = #wrappedLines * lineHeight

	-- padding da caixa
	local paddingX = 16
	local paddingY = 12

	local boxW = tw + paddingX * 2
	local boxH = th + paddingY * 2

	-- posição da caixa (centralizada no mouse)
	local bx = mx - boxW / 2
	local by = my - boxH - 10 -- leve deslocamento pra cima

	-- fundo com arredondamento
	love.graphics.setColor(0, 0, 0, tooltip.alpha)
	love.graphics.rectangle("fill", bx, by, boxW, boxH, 12, 12)

	-- texto
	love.graphics.setColor(1, 1, 1, tooltip.alpha)
	love.graphics.printf(
		tooltip.text,
		bx + paddingX,
		by + paddingY,
		tw,
		"left"
	)
end

-- Função para desenhar mensagem
function UI.drawMessage(msg)
	if msg.closed then return end

	love.graphics.setFont(msg.font)
	love.graphics.setColor(0, 0, 0, msg.alpha)
	local tw = msg.font:getWidth(msg.text)
	local th = msg.font:getHeight()
	local padding = 16

	love.graphics.rectangle(
		"fill",
		msg.x - tw / 2 - padding,
		msg.y - th / 2 - padding / 2,
		tw + padding * 2,
		th + padding,
		12, 12
	)

	love.graphics.setColor(1, 1, 1, msg.alpha)
	love.graphics.printf(msg.text, msg.x - tw / 2, msg.y - th / 2, tw, "center")
end

-- Função para desenhar o botão
function UI.drawButton(button, font)
	local font = font or button.font or love.graphics.getFont() -- Operador ternário no Lua é outro nível
	love.graphics.setFont(font)

	-- Definir cor de fundo do botão
	if button.disabled then
		love.graphics.setColor(0.1, 0.1, 0.1)
	elseif button.hovered then
		love.graphics.setColor(0.9, 0.6, 0.2) -- hover
	else
		love.graphics.setColor(0.2, 0.6, 0.8) -- normal
	end

	-- Desenhar fundo do botão
	love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 12, 12)

	-- Borda do botão
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", button.x, button.y, button.w, button.h, 12, 12)

	-- Conteúdo/Texto centralizado verticalmente
	love.graphics.setColor(1, 1, 1)
	local textHeight = font:getHeight()
	local textY = button.y + (button.h / 2) - (textHeight / 2)
	love.graphics.printf(button.text, button.x, textY, button.w, "center")
end

function UI.drawText(text, x, y, limit, align, color, font)
	love.graphics.setFont(font)
	love.graphics.setColor(color[1], color[2], color[3])
	love.graphics.printf(text, x, y, limit, align)
end

-- Função para atualizar hover
function UI.updateButtonHover(button, mx, my)
	if button.disabled then return end
	button.hovered = mx > button.x and mx < button.x + button.w and my > button.y and my < button.y + button.h
end

-- Função pra processar clique
function UI.clickButton(button, mouseButton)
	if mouseButton == 1 and button.hovered and button.action and not button.disabled then
		if button.sound then
			local clickSound = love.audio.newSource(button.sound, "stream")
			clickSound:setVolume(0.3)
			love.audio.play(clickSound)
		else
			local clickSound = love.audio.newSource("assets/sounds/bubble-pop.ogg", "stream")
			clickSound:setVolume(0.3)
			love.audio.play(clickSound)
		end

		button.action()
	end
end

-- Função para desenhar o input
function UI.drawTextInput(input)
	-- desenha label
	if input.label ~= "" then
		local labelObject = love.graphics.newText(input.font, input.label)
		local lx, ly = input.x, input.y

		if input.labelPos == "top" then
			ly = input.y - input.font:getHeight() - 2
			love.graphics.draw(labelObject, lx, ly)
		elseif input.labelPos == "bottom" then
			ly = input.y + input.h + 2
			love.graphics.draw(labelObject, lx, ly)
		elseif input.labelPos == "left" then
			lx = input.x - labelObject:getWidth() - 5
			love.graphics.draw(labelObject, lx, input.y + input.h / 2 - input.font:getHeight() / 2)
		elseif input.labelPos == "right" then
			lx = input.x + input.w + 5
			love.graphics.draw(labelObject, lx, input.y + input.h / 2 - input.font:getHeight() / 2)
		end
	end

	-- caixa arredondada
	if input.focused then
		love.graphics.setColor(0.9, 0.6, 0.2) -- focado
	elseif input.hovered then
		love.graphics.setColor(0.6, 0.6, 0.6) -- hover
	else
		love.graphics.setColor(0.2, 0.2, 0.2) -- normal
	end
	love.graphics.rectangle("fill", input.x, input.y, input.w, input.h, 8, 8)

	-- borda
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", input.x, input.y, input.w, input.h, 8, 8)

	-- texto ou placeholder usando Text object
	local displayObject = input.textObject
	local textColor = { 1, 1, 1 }

	if input.text == "" and not input.focused then
		displayObject = input.placeholderObject
		textColor = { 0.7, 0.7, 0.7 }
	end

	love.graphics.setColor(textColor)
	local textX = input.x + 5
	local textY = input.y + input.h / 2 - displayObject:getHeight() / 2

	-- Truncar texto se for muito longo
	local textWidth = displayObject:getWidth()
	if textWidth > input.w - 10 then
		love.graphics.draw(displayObject, textX, textY, 0, (input.w - 10) / textWidth, 1)
	else
		love.graphics.draw(displayObject, textX, textY)
	end
end

-- Hover do input
function UI.updateTextInputHover(input, mx, my)
	input.hovered = mx > input.x and mx < input.x + input.w and my > input.y and my < input.y + input.h
end

-- Clique no input
function UI.clickTextInput(input, mouseButton)
	if mouseButton == 1 then
		input.focused = input.hovered
	end
end

-- Detectar clique para fechar mensagem
function UI.clickMessage(msg, mx, my)
	if msg.closed or not msg.closable then return end
	local tw = msg.font:getWidth(msg.text)
	local th = msg.font:getHeight()
	local padding = 16
	local x1 = msg.x - tw / 2 - padding
	local y1 = msg.y - th / 2 - padding / 2
	local x2 = x1 + tw + padding * 2
	local y2 = y1 + th + padding

	if mx > x1 and mx < x2 and my > y1 and my < y2 then
		msg.closed = true
	end
end

-- Captura o input em caixa de input (para ações extras)
function UI.keypressedTextInput(input, key)
	if not input.focused then return end

	if key == "backspace" then
		local byteoffset = utf8.offset(input.text, -1)
		if byteoffset then
			input.text = string.sub(input.text, 1, byteoffset - 1)
			updateInputText(input, input.text)
		end
	elseif key == "return" or key == "kpenter" or key == "escape" then
		input.focused = false
	end
end

function UI.textinputTextInput(input, t)
	if input.focused then
		input.text = input.text .. t
		input.textObject:set(input.text)
	end
end

-- Função para atualizar o texto do botão (útil se o texto mudar dinamicamente)
function UI.setButtonText(button, newText)
	button.text = newText
	button.textObject:set(newText)
end

-- Função para atualizar o placeholder do input
function UI.setInputPlaceholder(input, newPlaceholder)
	input.placeholder = newPlaceholder
	input.placeholderObject:set(newPlaceholder)
end

return UI
