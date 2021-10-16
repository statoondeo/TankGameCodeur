require("maps/map1")
require("tanks/base")
require("modules/tweening")

function createMainMenu(myGame)
    local tankConstants = require("tanks/constants")
    local myMap = {}
    -- Quelle carte sert de fond d'écran
    -- On wrappe la carte demandée pour se transformer en map
    myMap.game = myGame
    myMap.map = createMap1(myMap.game)
    myMap.constantes = myMap.map.constantes
    myMap.tiles = myMap.map.tiles
    myMap.obstacles = myMap.map.obstacles

    -- Point de départ du joueur
    myMap.start = nil

    -- Liste des ennemis
    myMap.enemies = 
    {
    }

    myMap.innerConstantes = {}
    myMap.innerConstantes.buttonStartBlinkTimerLength = 0.5
    myMap.innerConstantes.selection = {}
    myMap.innerConstantes.selection.ttl = 0.5
    myMap.innerConstantes.selection.modes = {}
    myMap.innerConstantes.selection.modes.none = 0
    myMap.innerConstantes.selection.modes.tank = 1
    myMap.innerConstantes.selection.modes.game = 2
    myMap.innerConstantes.selection.modes.quit = 3
    myMap.innerConstantes.difficulties = {}
    myMap.innerConstantes.difficulties[1] = "(Hard difficulty)"
    myMap.innerConstantes.difficulties[2] = "(Normal difficulty)"
    myMap.innerConstantes.difficulties[3] = "(Easy difficulty)"
    myMap.music = myMap.game.resources.musics.menu

    myMap.init = function ()
        myMap.buttonStartBlinkTimer = 0
        myMap.buttonStartBlinkDelta = 1 
        myMap.tanks = {}
        myMap.turrets = {}
        for i = 1, tankConstants.base.skins.number.player do
            local myTank = createTank(myMap.game, tankConstants.modes.player, i + 1, -100, 5 * love.graphics.getHeight() / 7, 0)
            myTank.drawLife = false
            myTank.label = myMap.innerConstantes.difficulties[i]
            table.insert(myMap.tanks, myTank)
            table.insert(myMap.turrets, myTank.turret)
        end
        myMap.oldTank = 2
        myMap.currentTank = 2
        myMap.selectionWip = myMap.innerConstantes.selection.modes.tank
        myMap.selectionDirection = 1
        myMap.selectionTtl = 0
        myMap.music:setLooping(true)
        myMap.music:play()
    end

    myMap.update = function (dt)
        -- Clignotement du démarrage
        if myMap.buttonStartBlinkTimer >= myMap.innerConstantes.buttonStartBlinkTimerLength then
            myMap.buttonStartBlinkDelta = -1 
        else
            if myMap.buttonStartBlinkTimer <= 0 then
                myMap.buttonStartBlinkDelta = 1 
            end
        end
        myMap.buttonStartBlinkTimer = myMap.buttonStartBlinkTimer + myMap.buttonStartBlinkDelta * dt

        if myMap.selectionWip == myMap.innerConstantes.selection.modes.none then
            -- On affiche le tank
            -- Mais il ne peut pas bouger
            myMap.tanks[myMap.currentTank].x = love.graphics.getWidth() / 2
            myMap.tanks[myMap.currentTank].angle = 0
            myMap.tanks[myMap.currentTank].update(dt)
            myMap.tanks[myMap.currentTank].turret.update(dt)
        elseif myMap.selectionWip == myMap.innerConstantes.selection.modes.tank then
            myMap.selectionTtl = myMap.selectionTtl + dt
            if myMap.selectionTtl >= myMap.innerConstantes.selection.ttl then
                myMap.selectionWip = myMap.innerConstantes.selection.modes.none
                myMap.selectionTtl = 0
            else
                -- On déplace les tanks
                local distance = (100 + love.graphics.getWidth() / 2) * easingInOutBack(myMap.selectionTtl / myMap.innerConstantes.selection.ttl)
                myMap.tanks[myMap.oldTank].x = myMap.tanks[myMap.oldTank].initialx + distance * myMap.selectionDirection
                myMap.tanks[myMap.currentTank].x = myMap.tanks[myMap.currentTank].initialx + distance * myMap.selectionDirection
                myMap.tanks[myMap.oldTank].UpdateTurretAnchor(dt)
                myMap.tanks[myMap.oldTank].UpdateTurretAnchor(dt)

                myMap.tanks[myMap.oldTank].turret.update(dt)
                myMap.tanks[myMap.currentTank].turret.update(dt)
            end
        end
    end

    myMap.draw = function ()
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, 0.75)
        love.graphics.draw(myMap.game.resources.images.background, 0, 0)
        love.graphics.setColor(255, 255, 255)

        -- Titre principal
        love.graphics.setFont(myMap.game.resources.fonts.giant)
        local font = love.graphics.getFont()
        local label = "Tanks"
        love.graphics.print(
            label, 
            math.floor((love.graphics.getWidth() - font:getWidth(label)) / 2), 
            math.floor((love.graphics.getHeight() - font:getHeight(label)) / 7))
        love.graphics.setFont(myMap.game.resources.fonts.large)
        font = love.graphics.getFont()
        label = "Battleground"
        love.graphics.print(
            label, 
            math.floor((love.graphics.getWidth() - font:getWidth(label)) / 2), 
            math.floor(2 * (love.graphics.getHeight() - font:getHeight(label)) / 7))

        love.graphics.setFont(myMap.game.resources.fonts.small)
        font = love.graphics.getFont()
        label = "Raphael DUCHOSSOY (GameCodeur.fr)"
        love.graphics.print(
            label, 
            math.floor((love.graphics.getWidth() - font:getWidth(label)) / 2), 
            math.floor(3 * (love.graphics.getHeight() - font:getHeight(label)) / 7))
        label = "\"Click\" to fire, \"Arrows\" to select tank, \"Escape\" to quit"
        love.graphics.print(
            label, 
            math.floor((love.graphics.getWidth() - font:getWidth(label)) / 2), 
            math.floor(6 * (love.graphics.getHeight() - font:getHeight(label)) / 7))

        love.graphics.setFont(myMap.game.resources.fonts.medium)
        font = love.graphics.getFont()
        label = "\"Enter\" to start"
        love.graphics.setColor(255, 255, 255, easingInOutCubic(myMap.buttonStartBlinkTimer / myMap.innerConstantes.buttonStartBlinkTimerLength))
        love.graphics.print(
            label, 
            math.floor((love.graphics.getWidth() - font:getWidth(label)) / 2), 
            math.floor(4 * (love.graphics.getHeight() - font:getHeight(label)) / 7))
        love.graphics.setColor(255, 255, 255)

        -- On affiche les médailles
        for i = 1, 3 do
            love.graphics.draw(
                myMap.game.resources.images.medals[i],
                math.floor((love.graphics:getWidth() - myMap.game.resources.images.medals[i]:getWidth()) / 7),
                math.floor(150 + 1.5 * (i - 1) * myMap.game.resources.images.medals[i]:getHeight()),
                0,
                1 + i / 5,
                1 + i / 5,
                math.floor(myMap.game.resources.images.medals[i]:getWidth() / 2),
                math.floor(myMap.game.resources.images.medals[i]:getHeight() / 2)
            )
            love.graphics.draw(
                myMap.game.resources.images.medals[i],
                math.floor(6 * (love.graphics:getWidth() - myMap.game.resources.images.medals[i]:getWidth()) / 7),
                math.floor(150 + 1.5 * (i - 1) * myMap.game.resources.images.medals[i]:getHeight()),
                0,
                1 + i / 5,
                1 + i / 5,
                math.floor(myMap.game.resources.images.medals[i]:getWidth() / 2),
                math.floor(myMap.game.resources.images.medals[i]:getHeight() / 2)
            )
        end

        if myMap.selectionWip == myMap.innerConstantes.selection.modes.none then
            love.graphics.setFont(myMap.game.resources.fonts.small)
            font = love.graphics.getFont()
            label = myMap.tanks[myMap.currentTank].label
            love.graphics.print(
                label, 
                math.floor((love.graphics.getWidth() - font:getWidth(label)) / 2), 
                math.floor(5.4 * love.graphics.getHeight() / 7))    
        end

        -- On affiche les tank
        myMap.tanks[myMap.oldTank].draw()
        myMap.tanks[myMap.currentTank].draw()

        -- On affiche la tourelle
        myMap.turrets[myMap.oldTank].draw()
        myMap.turrets[myMap.currentTank].draw()
        
        -- On draw les missiles
        for i, myMissile in ipairs(myMap.game.missiles) do
            myMissile.draw()
        end
    end

    myMap.mousepressed = function (x, y, button, istouch, presses)  
        if myMap.selectionWip == myMap.innerConstantes.selection.modes.none then
            myMap.tanks[myMap.currentTank].fire()
        end
    end

    myMap.keypressed = function (key, scancode, isrepeat)
        if myMap.selectionWip == myMap.innerConstantes.selection.modes.none then
            if key == "left" or key == "right" then
                myMap.selectionWip = myMap.innerConstantes.selection.modes.tank
                myMap.oldTank = myMap.currentTank
                myMap.tanks[myMap.oldTank].initialx = myMap.tanks[myMap.oldTank].x
                if key == "left" then
                    myMap.currentTank = myMap.currentTank - 1
                    if myMap.currentTank <= 0 then
                        myMap.currentTank = #myMap.tanks
                    end
                    myMap.tanks[myMap.currentTank].initialx = 100 + love.graphics.getWidth()
                    myMap.selectionDirection = -1
                else
                    myMap.currentTank = myMap.currentTank + 1
                    if myMap.currentTank > #myMap.tanks then
                        myMap.currentTank = 1
                    end
                    myMap.tanks[myMap.currentTank].initialx = -100
                    myMap.selectionDirection = 1
                end
                myMap.game.playSound(myMap.game.resources.sounds.switch, 1)

            elseif key == "return" then
                myMap.game.playSound(myMap.game.resources.sounds.validation, 1)
                myMap.game.changeScreen(myMap.game.loadmap, createMap1(myMap.game), myMap.tanks[myMap.currentTank].skin) 

            elseif key == "escape" then
                myMap.game.playSound(myMap.game.resources.sounds.validation, 1)
                myMap.game.changeScreen(myMap.game.quitApp) 
            end
        end
    end

    return myMap

end