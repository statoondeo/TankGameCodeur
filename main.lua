-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf("no")

-- Désactive le lissage en cas de scale
love.graphics.setDefaultFilter("nearest")

math.randomseed(love.timer.getTime())

-- Les modules seront disponibles partout
modules = {}

function loadModules()
    modules.tweening = require("modules/tweeningModule")
    
    modules.game = require("modules/gameModule")
    modules.game.load()

    modules.tank = require("tanks/tankModule")
    modules.tank.load()
    
    modules.obstacle = require("modules/obstacleModule")
    modules.obstacle.load()
    
    modules.hitbox = require("modules/hitboxModule")
    modules.hitbox.load()

    modules.missile = require("missiles/missileModule")
    modules.missile.load()

    modules.turret = require("turrets/turretModule")
    modules.turret.load()
end

function love.load()
    -- Changement du mode d'affichage
    love.window.setMode (1027, 768, { resizable = false, vsync = true, centered = true})

    -- Chargement des modules
    loadModules()

    -- Chargement du menu principal    
    local mainMenu = require("maps/mainTitleModule")
    mainMenu.load()    
    modules.game.init(mainMenu)
end

function love.update(dt)
    modules.game.update(dt)        
end

function love.draw()
    modules.game.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    modules.game.mousepressed(x, y, button, istouch, presses)   
end

function love.keypressed(key, scancode, isrepeat)
    modules.game.keypressed(key, scancode, isrepeat)  
end