local this = {}

this.constantes = {}
this.constantes.tilesNumber = 40
this.constantes.modes = {}
this.constantes.modes.init = 1
this.constantes.modes.quit = 2
this.constantes.modes.game = 3
this.constantes.modes.initpause = 4
this.constantes.modes.pause = 5
this.constantes.modes.quitpause = 6
this.constantes.modes.initMessage = 7
this.constantes.modes.message = 8
this.constantes.modes.quitMessage = 9
this.constantes.modes.initGameEnd = 10
this.constantes.modes.gameEnd = 11
this.constantes.modes.ttl = 0.5
this.constantes.modes.messageTtl = 2
this.images = {}
this.sounds = {}
this.fonts = {}
this.fonts.size = {}
this.fonts.size.tiny = 9
this.fonts.size.small = 18
this.fonts.size.medium = 36
this.fonts.size.large = 72
this.fonts.size.giant = 108
this.pauseState = false

this.tileBeacons = 
{
    { 1, { 3, 4 } },
    { 2, { 2, 3 } },
    { 3, { 1, 4 } },
    { 4, { 1, 2 } },
    { 5, { 1, 2, 3, 4 } },
    { 6, { 1, 2, 3, 4 } },
    { 9, { 1, 2, 3 } },
    { 10, { 1, 2, 4 } },
    { 11, { 2, 3, 4 } },
    { 12, { 1, 3, 4 } },
    { 27, { 3, 4 } },
    { 28, { 2, 3 } },
    { 29, { 1, 4 } },
    { 30, { 1, 2 } },
    { 31, { 1, 2, 3, 4 } },
    { 32, { 1, 2, 3, 4 } },
    { 35, { 1, 2, 3 } },
    { 36, { 1, 2, 4 } },
    { 37, { 2, 3, 4 } },
    { 38, { 1, 3, 4 } },
}

function this.load()
    -- Chargement des ressources
    this.images.tiles = {}
    for i = 1, this.constantes.tilesNumber do
        this.images.tiles[i] = love.graphics.newImage("images/tiles/" .. i .. ".png")
    end
    this.images.medals = {}
    for i = 1, 3 do
        this.images.medals[i] = love.graphics.newImage("images/medal_" .. i .. ".png")
    end
    this.images.background = love.graphics.newImage("images/Background.png")
    this.images.bandeau = love.graphics.newImage("images/bandeau.png")
    this.images.bonus = love.graphics.newImage("images/bonus_1.png")
    this.images.cross = love.graphics.newImage("images/cross.png")
    this.images.cursor = love.mouse.newCursor("images/crosshair.png", 0, 0)
    this.fonts.tiny = love.graphics.newFont("fonts/KenFutureNarrow.ttf", this.fonts.size.tiny)
    this.fonts.small = love.graphics.newFont("fonts/KenFutureNarrow.ttf", this.fonts.size.small)
    this.fonts.medium = love.graphics.newFont("fonts/KenFutureNarrow.ttf", this.fonts.size.medium)
    this.fonts.large = love.graphics.newFont("fonts/KenFutureNarrow.ttf", this.fonts.size.large)
    this.fonts.giant = love.graphics.newFont("fonts/KenFutureNarrow.ttf", this.fonts.size.giant)
    this.sounds.validation = love.audio.newSource("sounds/confirmation_001.ogg", "static")

end

function this.init(myMap)
    modules.missile.missiles = {}
    modules.tank.tanks = {}
    modules.turret.turrets = {}
    modules.obstacle.obstacles = {}
    this.map = myMap
    this.map.init()

    -- On calcule les balises de la carte, c'est à dire les endroits ou les tanks ennemis vont
    -- changer de direction
    -- Construction du tableau de correspondance tuile/direction
    local tileBeacon = {}
    for i, beacon in ipairs(this.tileBeacons) do
        tileBeacon[beacon[1]] = beacon[2]
    end

    -- On parcour la map
    this.map.beacons = {}
    for i, tile in ipairs(this.map.tiles) do
        -- Regarde si la tuile courante doit contenir une balises
        if tileBeacon[tile] ~= nil then
            -- On ajoute la balise
            local newBeacon = {}
            newBeacon[1] = i                -- Beacon id
            -- Beacon x
            newBeacon[2] = (0.5 + (i - 1) % this.map.constantes.tiles.number.x) * this.map.constantes.tiles.size.x
            -- Beacon y
            newBeacon[3] = (0.5 + math.floor((i - 1) / this.map.constantes.tiles.number.x)) * this.map.constantes.tiles.size.y
            newBeacon[4] = 3                -- Beacon radius
            newBeacon[5] = tileBeacon[tile] -- Beacon directions
            table.insert(this.map.beacons, newBeacon)
        end
    end    

    -- On ajoute les obstacles de la map à la collection du niveau en cours
    this.additionalDecors = {}
    for i, myObstacle in ipairs(this.map.obstacles) do
        table.insert(
            modules.obstacle.obstacles, 
            modules.obstacle.create(
                myObstacle[1], 
                myObstacle[2], 
                myObstacle[3], 
                myObstacle[4], 
                myObstacle[5], 
                myObstacle[6], 
                myObstacle[7],
                myObstacle[8],
                myObstacle[9],
                myObstacle[10],
                myObstacle[11],
                myObstacle[12]))

        -- Remplissage des zones à peupler avec des décorations
        if myObstacle[1] == 0 then
            -- On remplit chaque zone demandée
            local j = myObstacle[2]
            while j < myObstacle[2] + myObstacle[11] do
                local k = myObstacle[3]
                while k < myObstacle[3] + myObstacle[12] do
                    if myObstacle[13][1] ~= nil and myObstacle[13][2] ~= nil then
                        table.insert(
                            this.additionalDecors, 
                            modules.obstacle.create(
                                love.math.random(myObstacle[13][1], myObstacle[13][2]), 
                                j + 12, 
                                k + 12, 
                                love.math.random() * math.pi, 
                                love.math.random() * 0.8 + 0.4, 
                                false, 
                                false,
                                1,
                                nil,
                                0,
                                0,
                                0))
                    end
                    k = k + 25
                end
                j = j + 25
            end
        end
    end

    -- Création du tank joueur
    if this.map.start ~= nil then
        this.playerTank = modules.tank.create(modules.tank.constantes.modes.player, this.map.playerSkin, this.map.start[1], this.map.start[2], this.map.start[3])
        table.insert(modules.tank.tanks, this.playerTank)
        table.insert(modules.turret.turrets, this.playerTank.turret)
    end
    -- Ennemis
    for i, ennemy in ipairs(this.map.ennemis) do
        local ennemyTank = modules.tank.create(modules.tank.constantes.modes.ennemy, ennemy[1], ennemy[2], ennemy[3], ennemy[4])
        ennemyTank.enemy = this.playerTank
        table.insert(modules.tank.tanks, ennemyTank)
        table.insert(modules.turret.turrets, ennemyTank.turret)
    end

    love.mouse.setCursor(this.images.cursor)

    this.offset = {}
    this.offset.x = 0
    this.offset.y = 0    

    this.initialTtl = 0
    this.mode = this.constantes.modes.init
end

function this.updateCamera(dt)
    if this.playerTank ~= nil then
        local camera = {}

        -- On centre la caméra sur le joueur
        camera.x = this.playerTank.x - love.graphics:getWidth() / 2
        camera.y = this.playerTank.y - love.graphics:getHeight() / 2

        -- Si la caméra déborde de la map on la recadre
        if camera.x < 0 then
            camera.x = 0
        end
        if camera.y < 0 then
            camera.y = 0
        end
        if camera.x > this.map.constantes.tiles.size.x * this.map.constantes.tiles.number.x - love.graphics:getWidth() then
            camera.x = this.map.constantes.tiles.size.x * this.map.constantes.tiles.number.x - love.graphics:getWidth()
        end
        if camera.y > this.map.constantes.tiles.size.y * this.map.constantes.tiles.number.y - love.graphics:getHeight() then
            camera.y = this.map.constantes.tiles.size.y * this.map.constantes.tiles.number.y - love.graphics:getHeight()
        end

        -- On calcule l'offset à appliquer à tous les éléments 
        this.offset.x = -camera.x
        this.offset.y = -camera.y
    end
end

function this.update(dt)
    if this.mode == this.constantes.modes.init then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.mode = this.constantes.modes.game
            if this.map.endInit ~= nil then
                this.map.endInit()
            end
        end
    elseif this.mode == this.constantes.modes.quit then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.actionToDo(this.actionToDoParam1, this.actionToDoParam2)
        end
    elseif this.mode == this.constantes.modes.initpause then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.pauseState = true
            this.mode = this.constantes.modes.pause
        end
    elseif this.mode == this.constantes.modes.quitpause then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.pauseState = false
            this.mode = this.constantes.modes.game
        end
    elseif this.mode == this.constantes.modes.initMessage then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.mode = this.constantes.modes.message
        end
    elseif this.mode == this.constantes.modes.message then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.messageTtl then
            this.initialTtl = 0
            this.mode = this.constantes.modes.quitMessage
        end
    elseif this.mode == this.constantes.modes.quitMessage then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.mode = this.constantes.modes.game
        end
    elseif this.mode == this.constantes.modes.initGameEnd then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.initialTtl = 0
            this.mode = this.constantes.modes.gameEnd
            modules.game.sounds.validation:play()
        end
    elseif this.mode == this.constantes.modes.gameEnd then
        -- On attend une réaction du joueur
    elseif this.mode == this.constantes.modes.game then
        if this.pauseState == false and (this.map.playerWin == nil or this.map.playerWin == false) then
            -- Récupération de la position de la souris
            local mouse = {}
            mouse.x, mouse.y = love.mouse.getPosition()
            
            -- Mise à jour de la position de la caméra
            this.updateCamera(dt)

            -- On met à jour la carte
            this.map.update(dt, mouse)
    
            -- Gestion des collisions
            modules.obstacle.ManageCollision()
    
            -- On met à jour les obstacles
            modules.obstacle.update(dt)
    
            -- On met à jour les tanks
            modules.tank.update(dt)
     
            -- On met à jour les tourelles
            modules.turret.update(dt, mouse)
    
            -- On update les missiles
            modules.missile.update(dt)
        end
    end
end

function this.drawGameEnd(myAlpha)
    -- Filtre transparent
    love.graphics.setColor(255, 255, 255, myAlpha)
    love.graphics.draw(this.images.background, 0, 0)
    love.graphics.setColor(255, 255, 255)

    local mainLabel
    local actionsLabel
    if this.map.playerWin == true then
        mainLabel = "Victorious"
        actionsLabel = "\"Escape\" to main menu, \"Return\" to continue"
    
    elseif this.map.playerLoose == true then
        mainLabel = "Defeated"
        actionsLabel = "\"Escape\" to main menu, \"Return\" to retry"

    end
    
    love.graphics.setFont(this.fonts.giant)
    local font = love.graphics.getFont()
    love.graphics.print(mainLabel, (love.graphics.getWidth() - font:getWidth(mainLabel)) / 2, (love.graphics.getHeight() - font:getHeight(mainLabel)) / 2)

    love.graphics.setFont(this.fonts.small)
    local font = love.graphics.getFont()
    love.graphics.print(actionsLabel, (love.graphics.getWidth() - font:getWidth(actionsLabel)) / 2, 6 * (love.graphics.getHeight() - font:getHeight(actionsLabel)) / 7)
    
    local image = modules.game.images.medals[this.map.number ]

    love.graphics.draw(
        image,
        (love.graphics:getWidth() - image:getWidth()) / 2,
        (love.graphics:getHeight() - image:getHeight()) / 3,
        0,
        1 + this.map.number / 5,
        1 + this.map.number / 5,
        image:getWidth() / 2,
        image:getHeight() / 2
    ) 
    if this.map.playerLoose == true then
        love.graphics.draw(
            this.images.cross,
            (love.graphics:getWidth() - image:getWidth()) / 2,
            (love.graphics:getHeight() - image:getHeight()) / 3,
            0,
            1,
            1,
            this.images.cross:getWidth() / 2,
            this.images.cross:getHeight() / 2
        ) 
    end

    love.graphics.setColor(255, 255, 255)
end

function this.drawPause()
    -- Libellé
    love.graphics.setFont(this.fonts.giant)
    local font = love.graphics.getFont()
    local label = "Pause"
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, (love.graphics.getHeight() - font:getHeight(label)) / 2)

    love.graphics.setFont(this.fonts.small)
    local font = love.graphics.getFont()
    local label = "\"Escape\" to main menu, \"Space\" to resume"
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, 6 * (love.graphics.getHeight() - font:getHeight(label)) / 7)
end

function this.drawMessage()
    -- Affichage du titre de la messagebox
    love.graphics.setFont(this.fonts.large)
    local font = love.graphics.getFont()
    local label = this.message[1]
    local availableHeight = this.images.bandeau:getHeight()
    love.graphics.print(
        label, 
        (love.graphics.getWidth() - font:getWidth(label)) / 2, 
        (love.graphics.getHeight() - this.images.bandeau:getHeight()) / 2 + availableHeight / 5)    

    love.graphics.setFont(this.fonts.small)
    local font = love.graphics.getFont()
    local label = this.message[2]
    local availableHeight = this.images.bandeau:getHeight()
    love.graphics.print(
        label, 
        (love.graphics.getWidth() - font:getWidth(label)) / 2, 
        (love.graphics.getHeight() - this.images.bandeau:getHeight()) / 2 + 3 * availableHeight / 5)  

    local label = this.message[3]
    local availableHeight = this.images.bandeau:getHeight()
    love.graphics.print(
        label, 
        (love.graphics.getWidth() - font:getWidth(label)) / 2, 
        (love.graphics.getHeight() - this.images.bandeau:getHeight()) / 2 + 4 * availableHeight / 5)  
end

function this.draw()
    -- On draw la map
    for i, tile in ipairs(this.map.tiles) do
        love.graphics.draw(
            this.images.tiles[tile], 
            (i - 1) % this.map.constantes.tiles.number.x * this.map.constantes.tiles.size.x + this.offset.x, 
            math.floor((i - 1) / this.map.constantes.tiles.number.x) * this.map.constantes.tiles.size.y + this.offset.y)
    end
    
    -- -- On affiche les balises
    -- -- love.graphics.setFont(modules.game.fonts.tiny)
    -- -- for i, myBeacon in ipairs(this.map.beacons) do
    -- --     local myBeaconHitbox = modules.hitbox.create(modules.hitbox.constantes.circleType)
    -- --     myBeaconHitbox.x = myBeacon[2]
    -- --     myBeaconHitbox.y = myBeacon[3]
    -- --     myBeaconHitbox.radius = myBeacon[4]

    -- --     love.graphics.circle("fill", myBeaconHitbox.x + this.offset.x, myBeaconHitbox.y + this.offset.y, myBeaconHitbox.radius)

    -- --     love.graphics.setColor(0, 0, 0)
    -- --     love.graphics.print(myBeacon[1], myBeaconHitbox.x + this.offset.x, myBeaconHitbox.y + this.offset.y)
    -- --     love.graphics.setColor(255, 255, 255)
    -- -- end

    -- On draw les obstacles
    modules.obstacle.draw()

    -- On draw les tanks
    modules.tank.draw()
    
    -- On draw les tourelles
    modules.turret.draw()    

    -- On draw les missiles
    modules.missile.draw()

    -- On draw les décors additionnels
    for i, myDecor in ipairs(this.additionalDecors) do
        modules.obstacle.drawObstacle(myDecor)
    end

    this.map.draw()

    if this.mode == this.constantes.modes.pause then
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, 0.75)
        love.graphics.draw(this.images.background, 0, 0)

        -- Libellé
        this.drawPause()
        love.graphics.setColor(255, 255, 255)
        
    elseif this.mode == this.constantes.modes.initpause then
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, modules.tweening.easingLin(this.initialTtl / this.constantes.modes.ttl) * 0.75)
        love.graphics.draw(this.images.background, 0, 0)

        -- Libellé
        this.drawPause()
        love.graphics.setColor(255, 255, 255)
            
    elseif this.mode == this.constantes.modes.quitpause then
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, modules.tweening.easingLin((this.constantes.modes.ttl - this.initialTtl) / this.constantes.modes.ttl) * 0.75)
        love.graphics.draw(this.images.background, 0, 0)

        -- Libellé
        this.drawPause()
        love.graphics.setColor(255, 255, 255)

    elseif this.mode == this.constantes.modes.initMessage then
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, modules.tweening.easingLin(this.initialTtl / this.constantes.modes.ttl) * 0.75)
        love.graphics.draw(this.images.bandeau, 0, (love.graphics.getHeight() - this.images.bandeau:getHeight()) / 2)

        -- Libellé
        this.drawMessage()
        love.graphics.setColor(255, 255, 255)
        
    elseif this.mode == this.constantes.modes.message then
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, 0.75)
        love.graphics.draw(this.images.bandeau, 0, (love.graphics.getHeight() - this.images.bandeau:getHeight()) / 2)

        -- Libellé
        this.drawMessage()
        love.graphics.setColor(255, 255, 255)
            
    elseif this.mode == this.constantes.modes.quitMessage then
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, modules.tweening.easingLin((this.constantes.modes.ttl - this.initialTtl) / this.constantes.modes.ttl) * 0.75)
        love.graphics.draw(this.images.bandeau, 0, (love.graphics.getHeight() - this.images.bandeau:getHeight()) / 2)

        -- Libellé
        this.drawMessage()
        love.graphics.setColor(255, 255, 255)

    elseif this.mode == this.constantes.modes.initGameEnd then
        this.drawGameEnd(modules.tweening.easingLin(this.initialTtl / this.constantes.modes.ttl) * 0.75)
        
    elseif this.mode == this.constantes.modes.gameEnd then
        this.drawGameEnd(0.75)

    elseif this.mode == this.constantes.modes.init then
        love.graphics.setColor(0, 0, 0, modules.tweening.easingLin((this.constantes.modes.ttl - this.initialTtl) / this.constantes.modes.ttl))
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 255)

    elseif this.mode == this.constantes.modes.quit then
        love.graphics.setColor(0, 0, 0, modules.tweening.easingLin(this.initialTtl / this.constantes.modes.ttl))
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 255)
    end
end

function this.displayGameMessage(label)
    this.sounds.validation:play()
    this.mode = this.constantes.modes.initMessage
    this.message = label
    this.initialTtl = 0
end

function this.changeScreen(whatToDo, parameter1, parameter2)
    this.sounds.validation:play()
    this.mode = this.constantes.modes.quit
    this.initialTtl = 0
    this.actionToDo = whatToDo
    this.actionToDoParam1 = parameter1
    this.actionToDoParam2 = parameter2
end

function this.switchPause()
    this.sounds.validation:play()
    if this.mode == this.constantes.modes.pause then
        this.mode = this.constantes.modes.quitpause
    elseif this.mode == this.constantes.modes.game then
        this.mode = this.constantes.modes.initpause
    end
end

function this.loadmap(map, playerSkin)
    map.playerSkin = playerSkin
    this.init(map)
end

function this.quitApp()
    love.event.quit()
end

function this.mousepressed(x, y, button, istouch, presses)  
    print("Mouse=>", x - this.offset.x .."/".. y - this.offset.y)
    this.map.mousepressed(x, y, button, istouch, presses)
end

function this.keypressed(key, scancode, isrepeat)
    if key == "return" then
        if this.mode == this.constantes.modes.message then
            this.mode = this.constantes.modes.quitMessage
        end
    end
    this.map.keypressed(key, scancode, isrepeat)
end

return this