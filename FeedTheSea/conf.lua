-- conf.lua
function love.conf(t)
	t.window.title = "Feed the Sea"
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = false -- Pois o jogo ainda não lida com redimensionamento
	t.window.fullscreen = false
end
