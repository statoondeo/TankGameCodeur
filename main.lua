-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf("no")

-- Désactive le lissage en cas de scale
love.graphics.setDefaultFilter("nearest")

function math.prandom(min, max) 
    return love.math.random() * (max - min) + min 
end

-- Les modules seront disponibles partout
modules = {}

function loadModules()
    modules.tweening = require("tweeningModule")
    
    modules.mainMenu = require("mainTitleModule")
    modules.mainMenu.load()
    
    -- Chargement du module terrain
    modules.battleground = require("battlegroundModule")
    modules.battleground.load()

    modules.tank = require("tankModule")
    modules.tank.load()
    
    modules.obstacle = require("obstacleModule")
    modules.obstacle.load()
    
    modules.hitbox = require("hitboxModule")
    modules.hitbox.load()

    modules.missile = require("missileModule")
    modules.missile.load()

    modules.turret = require("turretModule")
    modules.turret.load()
end

function love.load()
    -- Changement du mode d'affichage
    love.window.setMode (1027, 768, { resizable = false, vsync = true, centered = true})

    -- Chargement des modules
    loadModules()

    -- Chargement du menu principal
    modules.battleground.init(modules.mainMenu)
end

function love.update(dt)
    modules.battleground.update(dt)        
end

function love.draw()
    modules.battleground.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        modules.battleground.mousepressed(x, y, button, istouch, presses)   
    end
end

function love.keypressed(key, scancode, isrepeat)
    modules.battleground.keypressed(key, scancode, isrepeat)  
end