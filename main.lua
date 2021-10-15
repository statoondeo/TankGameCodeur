-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf("no")

-- Désactive le lissage en cas de scale
love.graphics.setDefaultFilter("nearest")

-- Variable contenu les données du jeu
require("modules/game")
require("maps/mainTitle")

-- Conteneur du jeu
local game = createGame()

function love.load()
    -- Changement du mode d'affichage
    love.window.setMode (1024, 768, { resizable = false, vsync = true, centered = true})
    love.window.setTitle("Tank battleground")
    math.randomseed(love.timer.getTime())

    -- Chargement des ressources du jeu
    game.load()

    -- Chargement du menu principal    
    game.init(createMainMenu(game))
end

function love.update(dt)
    game.update(dt)        
end

function love.draw()
    game.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    game.mousepressed(x, y, button, istouch, presses)   
end

function love.keypressed(key, scancode, isrepeat)
    game.keypressed(key, scancode, isrepeat)  
end