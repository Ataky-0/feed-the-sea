-- sample.lua
-- Código para servir de base para a criação de outras cenas
-- Algumas (várias) coisas são opcionais e podem ser removidas caso você queira
-- Este exemplo é baseado/retirado do optionsScene
-- Importa módulos necessários
local UI = require("src.ui")
local sceneManager = require("src.sceneManager")

-- Define a cena
local sampleScene = {}

function sampleScene:load()
	-- Carregar fontes, imagens, variáveis, botões etc.
	-- Exemplo de botão de navegação (voltar):
	-- w = Width (Largura); h = Height (Altura)
	self.backButton = UI.newButton("<", x, y, w, h, function()
		sceneManager:changeScene("mainmenu")
	end)

	-- Exemplo de título da cena
	self.title = "SceneName"
	self.titleFont = love.graphics.newFont(fontSize)

	-- Fontes para botões de navegação ou outras UI
	-- Isto está diretamente ligado à existência de botões de navegação
	-- Como retroceder/avançar
	self.navButtonsFont = love.graphics.newFont(fontSize)
end

function sampleScene:draw()
	local ww, wh = love.graphics.getDimensions()

	-- Limpa a tela com uma cor base
	-- Basicamente para colorir o background com uma cor específica
	-- Red, Green, Blue; Vermelho, Verde e Azul
	-- r,g e b devem ser valores flutuantes entre 0 e 1
	love.graphics.clear(r, g, b)

	-- Desenha título (Consultar a definição dessa função no código de UI)
	UI.drawText(self.title, 0, wh * 0.2, ww, "center", { 1, 1, 1 }, self.titleFont)

	-- Desenhar outros elementos da cena aqui

	-- Exemplo para desenhar botões de navegação
	UI.drawButton(self.backButton, self.navButtonsFont)
end

function sampleScene:mousemoved(x, y)
	-- Atualiza estado de hover dos botões
	UI.updateButtonHover(self.backButton, x, y)
	-- Atualizar outros botões se existirem
end

function sampleScene:mousepressed(x, y, button)
	-- Detecta clique nos botões
	UI.clickButton(self.backButton, button)
	-- Cliques de outros botões
end

function sampleScene:keypressed(key)
	-- Atalho para voltar à cena principal
	if key == "escape" then
		sceneManager:changeScene("mainmenu")
	end
end

return sampleScene
