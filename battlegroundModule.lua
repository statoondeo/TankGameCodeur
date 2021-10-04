local this = {}

this.constantes = {}
this.constantes.tilesNumber = 40
this.constantes.modes = {}
this.constantes.modes.init = 1
this.constantes.modes.game = 2
this.constantes.modes.ttl = 0.5
this.images = {}
this.playerTank = {}
this.pauseState = false

function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.tilesNumber do
        this.images[i] = love.graphics.newImage("images/tiles/" .. i .. ".png")
    end
end

function this.init(myMap)
    modules.missile.missiles = {}
    modules.tank.tanks = {}
    modules.turret.turrets = {}
    modules.obstacle.obstacles = {}
    this.map = myMap
    this.map.init()

    -- On ajoute les obstacles de la map à la collection du niveau en cours
    this.obstacles = {}
    this.additionalDecors = {}
    for i, myObstacle in ipairs(this.map.obstacles) do
        table.insert(
            this.obstacles, 
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
                                math.random(myObstacle[13][1], myObstacle[13][2]), 
                                j + math.random(0, 15), 
                                k + math.random(0, 15), 
                                math.prandom(0, 2 * math.pi), 
                                math.prandom(0.8, 1.2), 
                                false, 
                                false,
                                1,
                                nil,
                                0,
                                0,
                                0))
                    end
                    k = k + 40
                end
                j = j + 40
            end
        end
    end

    -- Création du tank joueur
    -- myBattleground.playerTank = modules.tank.create(modules.tank.constantes.modes.player, modules.tank.constantes.skins.playerGreen)
    -- myBattleground.playerTank = modules.tank.create(modules.tank.constantes.modes.player, modules.tank.constantes.skins.playerBlue)
    if this.map.start ~= nil then
        this.playerTank = modules.tank.create(modules.tank.constantes.modes.player, this.map.playerSkin, this.map.start[1], this.map.start[2], this.map.start[3])
        table.insert(modules.tank.tanks, this.playerTank)
        table.insert(modules.turret.turrets, this.playerTank.turret)
    end
    -- Ennemis
    for i, ennemy in ipairs(this.map.ennemis) do
        local ennemyTank = modules.tank.create(modules.tank.constantes.modes.ennemy, ennemy[1], ennemy[2], ennemy[3], ennemy[4])
        ennemyTank.ennemy = this.playerTank
    end

    this.offset = {}
    this.offset.x = 0
    this.offset.y = 0    

    this.initialTtl = 0
    this.mode = this.constantes.modes.init
end

function this.updateCamera(dt)
    -- On déplace la caméra
    -- On centre la caméra sur le joueur
    local camera = {}
    camera.x = this.playerTank.x - love.graphics:getWidth() / 2
    camera.y = this.playerTank.y - love.graphics:getHeight() / 2

    -- Si la caméra déborde de la map on la recadre
    if camera.x < 0 then
        camera.x = 0
    end
    if camera.y < 0 then
        camera.y = 0
    end
    if camera.x + love.graphics:getWidth() > this.map.constantes.tiles.size.x * this.map.constantes.tiles.number.x then
        camera.x = love.graphics:getWidth() - this.map.constantes.tiles.size.x * this.map.constantes.tiles.number.x
    end
    if camera.y + love.graphics:getHeight() > this.map.constantes.tiles.size.y * this.map.constantes.tiles.number.y then
        camera.y = love.graphics:getHeight() - this.map.constantes.tiles.size.y * this.map.constantes.tiles.number.y
    end

    -- On calcule l'offset à appliquer à tous les éléments 
    this.offset.x = this.camera.x
    this.offset.y = this.camera.y
end

function this.update(dt)
    if this.mode == this.constantes.modes.init then
        this.initialTtl = this.initialTtl + dt
        if this.initialTtl > this.constantes.modes.ttl then
            this.mode = this.constantes.modes.game
        end
    elseif this.mode == this.constantes.modes.game then
        if this.pauseState == false then
            -- Récupération de la position de la souris
            local mouse = {}
            mouse.x, mouse.y = love.mouse.getPosition()
    
            -- On met à jour la carte
            this.map.update(dt, mouse)
    
            -- Gestion des collisions
            --modules.obstacle.ManageCollision(this.obstacles)
    
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

function this.draw()
    -- On draw la map
    for i, tile in ipairs(this.map.tiles) do
        love.graphics.draw(
            this.images[tile], 
            (i - 1) % this.map.constantes.tiles.number.x * this.map.constantes.tiles.size.x + this.offset.x, 
            math.floor((i - 1) / this.map.constantes.tiles.number.x) * this.map.constantes.tiles.size.y + this.offset.y)
    end
    
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

    if this.mode == this.constantes.modes.init then
        love.graphics.setColor(0, 0, 0, modules.tweening.easingLin((this.constantes.modes.ttl - this.initialTtl) / this.constantes.modes.ttl))
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 255)
    end
end

function this.mousepressed(x, y, button, istouch, presses)  
    this.map.mousepressed(x, y, button, istouch, presses)
end

function this.keypressed(key, scancode, isrepeat)
    this.map.keypressed(key, scancode, isrepeat)
end

return this