require("modules/resourceLoader")
require("modules/obstacle")
require("modules/tweening")
require("modules/collider")

function createGame()
    local gameConstants = require("modules/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local tankConstants = require("tanks/constants")
    local myGame = {}

    -- Stockage des ressources
    myGame.resources = createResourceLoader()
    
    -- Stockage des éléments de jeu
    myGame.sprites = {}
    myGame.tanks = {}

    myGame.load = function()
        myGame.resources.load()
    end

    myGame.GetTileCenterFromTileInMap = function(tileNumber) 
        local point = myGame.GetTileOriginFromTileInMap(tileNumber)

        point.x = point.x + 0.5 * gameConstants.tiles.size.x
        point.y = point.y + 0.5 * gameConstants.tiles.size.y

        return point
    end
    
    myGame.GetTileOriginFromTileInMap = function(tileNumber) 
        local point = {}

        point.x = ((tileNumber - 1) % myGame.map.constantes.tiles.number.x) * gameConstants.tiles.size.x
        point.y = math.floor((tileNumber - 1) / myGame.map.constantes.tiles.number.x) * gameConstants.tiles.size.y

        return point
    end

    myGame.GetTileFromCoordonates = function(x, y) 
        local point = {}

        point.x = math.floor(x / gameConstants.tiles.size.x) + 1
        point.y = math.floor(y / gameConstants.tiles.size.y) + 1

        return point
    end

    myGame.shaderCode = [[
    #define NUM_LIGHTS 64
    struct Light {
        vec2 position;
        vec3 diffuse;
        float power;
    };
    extern Light lights[NUM_LIGHTS];
    extern int num_lights;
    extern vec2 screen;
    const float constant = 1.0;
    const float linear = 0.09;
    const float quadratic = 0.032;
    vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
        vec4 pixel = Texel(image, uvs);
        vec2 norm_screen = screen_coords / screen;
        vec3 diffuse = vec3(0);
        for (int i = 0; i < num_lights; i++) {
            Light light = lights[i];
            vec2 norm_pos = light.position / screen;
            
            float distance = length(norm_pos - norm_screen) * light.power;
            float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
            diffuse += light.diffuse * attenuation;
        }
        diffuse = clamp(diffuse, 0.0, 1.0);
        return pixel + vec4(diffuse, 1.0);
    }
    ]]

    myGame.shader = love.graphics.newShader(myGame.shaderCode)

    myGame.init = function (myMap)
        -- On remet à zéro les données
        myGame.missiles = {}
        myGame.tanks = {}
        myGame.obstacles = {}
        myGame.sprites = {}
        myGame.pauseState = false
        myGame.Collider = createCollider()
        myGame.map = myMap
        myGame.map.init()

        -- On calcule les balises de la carte, c'est à dire les endroits ou les tanks ennemis vont
        -- changer de direction
        -- Construction du tableau de correspondance tuile/direction
        local tileBeacon = {}
        for i, beacon in ipairs(gameConstants.tileBeacons) do
            tileBeacon[beacon[1]] = beacon[2]
        end

        -- Construction du tableau de correspondance tuile/direction de la map
        if myGame.map.modifiers == nil then
            myGame.map.modifiers = {}
            for i, modifier in ipairs(gameConstants.tileModifiers) do
                myGame.map.modifiers[modifier[1]] = modifier[2]
            end       
        end

        -- Construction du tableau de correspondance tuile/direction de la map
        if myGame.map.beacons == nil then
            -- On parcour la map
            myGame.map.beacons = {}
            for i, tile in ipairs(myGame.map.tiles) do
                -- Regarde si la tuile courante doit contenir une balises
                if tileBeacon[tile] ~= nil then
                    -- On ajoute la balise
                    local newBeacon = createHitbox(myGame, hitboxConstants.circleType)
                    newBeacon.id = i
                    local point = myGame.GetTileCenterFromTileInMap(i)
                    newBeacon.x = point.x
                    newBeacon.y = point.y
                    newBeacon.radius = 32
                    newBeacon.directions = tileBeacon[tile]
                    table.insert(myGame.map.beacons, newBeacon)
                end
            end         
        end  

        myGame.offset = {}
        myGame.offset.x = 0
        myGame.offset.y = 0   

        -- Construction du visuel de la map
        myGame.mapGround = love.graphics.newCanvas(myGame.map.constantes.tiles.number.x * gameConstants.tiles.size.x, myGame.map.constantes.tiles.number.y * gameConstants.tiles.size.y)
        myGame.mapAerial = love.graphics.newCanvas(myGame.map.constantes.tiles.number.x * gameConstants.tiles.size.x, myGame.map.constantes.tiles.number.y * gameConstants.tiles.size.y)
        love.graphics.setCanvas(myGame.mapGround)
        for i, tile in ipairs(myGame.map.tiles) do
            local point = myGame.GetTileOriginFromTileInMap(i)
            love.graphics.draw(
                myGame.resources.images.tiles[tile], 
                point.x, 
                point.y)
            end
        -- love.graphics.setCanvas()

        -- On ajoute les obstacles de la map à la collection du niveau en cours
        local targetCanvas
        for i, myObstacle in ipairs(myGame.map.obstacles) do
            local myNewObstacle = createObstacle(
                myGame,
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
                myObstacle[12])
            table.insert(myGame.obstacles, myNewObstacle)
            if myNewObstacle.visible == true then
                if myObstacle[1] <= 6 then
                    targetCanvas = myGame.mapAerial
                else
                    targetCanvas = myGame.mapGround
                end
                love.graphics.setCanvas(targetCanvas)
                myNewObstacle.draw()
            else

                -- Remplissage des zones à peupler avec des décorations
                local j = myObstacle[2]
                while j < myObstacle[2] + myObstacle[11] - 16 do
                    local k = myObstacle[3]
                    while k < myObstacle[3] + myObstacle[12] - 16 do
                        if myObstacle[13][1] ~= nil and myObstacle[13][2] ~= nil then
                            local newObstacle = createObstacle(
                                    myGame,
                                    love.math.random(myObstacle[13][1], myObstacle[13][2]), 
                                    j + 16, 
                                    k + 16, 
                                    love.math.random() * math.pi, 
                                    love.math.random() * 0.4 + 0.8, 
                                    false, 
                                    false,
                                    1,
                                    nil,
                                    0,
                                    0,
                                    0)
                            if newObstacle.imageIndex <= 6 then
                                targetCanvas = myGame.mapAerial
                            else
                                targetCanvas = myGame.mapGround
                            end
                            love.graphics.setCanvas(targetCanvas)
                            newObstacle.draw()                                    
                        end
                        k = k + love.math.random(16, 48)
                    end
                    j = j + love.math.random(16, 48)
                end
            end
        end       
        love.graphics.setCanvas()

        -- Création du tank joueur
        local point
        if myGame.map.start ~= nil then
            -- Calcul de la position à partir de la tuile
            point = myMap.game.GetTileCenterFromTileInMap(myGame.map.start[2] * myMap.constantes.tiles.number.x + myGame.map.start[1])
            myGame.playerTank = createTank(myMap.game, tankConstants.modes.player, myGame.map.playerSkin, point.x, point.y, myGame.map.start[3])
            table.insert(myGame.tanks, myGame.playerTank)
            table.insert(myGame.sprites, myGame.playerTank)
            table.insert(myGame.sprites, myGame.playerTank.turret)
        end
        -- Ennemis
        for i, enemy in ipairs(myGame.map.enemies) do
            point = myMap.game.GetTileCenterFromTileInMap(enemy[3] * myMap.constantes.tiles.number.x + enemy[2])
            local enemyTank = createTank(myMap.game, tankConstants.modes.enemy, enemy[1], point.x, point.y, enemy[4])
            enemyTank.enemy = myGame.playerTank
            enemyTank.update(0)
            enemyTank.turret.update(0)
            table.insert(myGame.tanks, enemyTank)
            table.insert(myGame.sprites, enemyTank)
            table.insert(myGame.sprites, enemyTank.turret)
        end

        love.mouse.setCursor(myGame.resources.images.cursor)

        myGame.initialTtl = 0
        myGame.mode = gameConstants.modes.init
        
        myGame.bloodShake = false
        myGame.bloodShakeMaxTtl = 1
        myGame.bloodShakeTtl = myGame.bloodShakeMaxTtl
        
        myGame.fireShake = false
        myGame.fireShakeMaxTtl = 0.15
        myGame.fireShakeTtl = myGame.fireShakeMaxTtl

    end

    myGame.updateCamera = function (dt)
        local point = {}
        if myGame.playerTank == nil then
            point.x = love.graphics:getWidth() / 2
            point.y = love.graphics:getHeight() / 2
        else
            point.x = myGame.playerTank.x
            point.y = myGame.playerTank.y
        end
        local camera = {}

        -- On centre la caméra sur le joueur
        camera.x = point.x - love.graphics:getWidth() / 2
        camera.y = point.y - love.graphics:getHeight() / 2

        -- Si la caméra déborde de la map on la recadre
        if camera.x < 0 then
            camera.x = 0
        end
        if camera.y < 0 then
            camera.y = 0
        end
        if camera.x > gameConstants.tiles.size.x * myGame.map.constantes.tiles.number.x - love.graphics:getWidth() then
            camera.x = gameConstants.tiles.size.x * myGame.map.constantes.tiles.number.x - love.graphics:getWidth()
        end
        if camera.y > gameConstants.tiles.size.y * myGame.map.constantes.tiles.number.y - love.graphics:getHeight() then
            camera.y = gameConstants.tiles.size.y * myGame.map.constantes.tiles.number.y - love.graphics:getHeight()
        end

        -- On calcule l'offset à appliquer à tous les éléments 
        myGame.offset.x = -camera.x
        myGame.offset.y = -camera.y

        -- Le tank joueur tire on secoue l'écran
        if myGame.fireShake == true then
            myGame.fireShakeTtl = myGame.fireShakeTtl - dt
            if myGame.fireShakeTtl >= 0 then
                myGame.offset.x = myGame.offset.x + myGame.amplitudeShake * math.cos(myGame.fireShakeAngle) * easingInOutBack(myGame.fireShakeTtl / myGame.fireShakeMaxTtl)
                myGame.offset.y = myGame.offset.y + myGame.amplitudeShake * math.sin(myGame.fireShakeAngle) * easingInOutBack(myGame.fireShakeTtl / myGame.fireShakeMaxTtl)
            else
                myGame.fireShake = false
                myGame.fireShakeTtl = myGame.fireShakeMaxTtl
            end
        end
    end

    myGame.update = function(dt)
        if myGame.mode == gameConstants.modes.init then
            myGame.initialTtl = myGame.initialTtl + dt
            myGame.map.music:setVolume(myGame.initialTtl / gameConstants.modes.ttl)
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.mode = gameConstants.modes.game
                if myGame.map.endInit ~= nil then
                    myGame.map.endInit()
                end
            end
        elseif myGame.mode == gameConstants.modes.quit then
            myGame.initialTtl = myGame.initialTtl + dt
            myGame.map.music:setVolume((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl)
            if myGame.resources.musics.win:isPlaying() then
                myGame.resources.musics.win:setVolume((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl)
            end
            if myGame.resources.musics.loose:isPlaying() then
                myGame.resources.musics.loose:setVolume((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl)
            end
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.actionToDo(myGame.actionToDoParam1, myGame.actionToDoParam2)
            end
        elseif myGame.mode == gameConstants.modes.initpause then
            myGame.initialTtl = myGame.initialTtl + dt
            myGame.map.music:setVolume((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl * 0.75 + 0.25)
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.pauseState = true
                myGame.mode = gameConstants.modes.pause
            end
        elseif myGame.mode == gameConstants.modes.quitpause then
            myGame.initialTtl = myGame.initialTtl + dt
            myGame.map.music:setVolume(myGame.initialTtl / gameConstants.modes.ttl * 0.75 + 0.25)
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.pauseState = false
                myGame.mode = gameConstants.modes.game
            end
        elseif myGame.mode == gameConstants.modes.initMessage then
            myGame.initialTtl = myGame.initialTtl + dt
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.mode = gameConstants.modes.message
            end
        elseif myGame.mode == gameConstants.modes.message then
            myGame.initialTtl = myGame.initialTtl + dt
            if myGame.initialTtl > gameConstants.modes.messageTtl then
                myGame.initialTtl = 0
                myGame.mode = gameConstants.modes.quitMessage
            end
        elseif myGame.mode == gameConstants.modes.quitMessage then
            myGame.initialTtl = myGame.initialTtl + dt
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.mode = gameConstants.modes.game
            end
        elseif myGame.mode == gameConstants.modes.initGameEnd then
            myGame.initialTtl = myGame.initialTtl + dt
            myGame.map.music:setVolume((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl)

            if myGame.map.playerWin == true then
                myGame.resources.musics.win:play()
                myGame.resources.musics.win:setVolume(myGame.initialTtl / gameConstants.modes.ttl)
            
            elseif myGame.map.playerLoose == true then
                myGame.resources.musics.loose:play()
                myGame.resources.musics.loose:setVolume(myGame.initialTtl / gameConstants.modes.ttl)

            end
            if myGame.initialTtl > gameConstants.modes.ttl then
                myGame.initialTtl = 0
                myGame.mode = gameConstants.modes.gameEnd
                myGame.playSound(myGame.resources.sounds.validation, 1)
                myGame.map.music:stop()
            end
        elseif myGame.mode == gameConstants.modes.gameEnd then
            -- On attend une réaction du joueur
        elseif myGame.mode == gameConstants.modes.game then
            if myGame.pauseState == false and (myGame.map.playerWin == nil or myGame.map.playerWin == false) then
                
                -- Mise à jour de la position de la caméra
                myGame.updateCamera(dt)
                
                -- Si une tache de sang est affichée on la met à jour
                myGame.updateBloodShake(dt)

                -- On met à jour la carte
                myGame.map.update(dt)

                myGame.Collider.ManageCollision(myGame.missiles, myGame.obstacles, myGame.tanks)

                -- On met à jour les sprites
                for i, mySprite in ipairs(myGame.sprites) do
                    mySprite.update(dt)
                end

                -- On supprime les missiles expirés
                for i=#myGame.missiles, 1, -1 do
                    local myMissile = myGame.missiles[i]
                    if myMissile.outDated == true then
                        table.remove(myGame.missiles, i)
                        -- On le supprime aussi de la liste des sprites
                        for j, mySprite in ipairs(myGame.sprites) do
                            if mySprite == myMissile then
                                table.remove(myGame.sprites, j)
                                break;
                            end
                        end
                    end
                end
            end
        end
    end

    myGame.updateBloodShake = function (dt)
        if myGame.bloodShake == true then
            myGame.bloodShakeTtl = myGame.bloodShakeTtl - dt
            if myGame.bloodShakeTtl >= 0 then
                if myGame.bloodShakeTtl >= 0.8 * myGame.bloodShakeMaxTtl then
                    -- Arrivée de la tache de sang
                    local maxRange = myGame.bloodShakeMaxTtl
                    local minRange = 0.8 * myGame.bloodShakeMaxTtl
                    local currentRange = myGame.bloodShakeTtl
                    local tweenValue = (maxRange - currentRange) / (maxRange - minRange)

                    myGame.bloodShakeZoom = easingOutBack(tweenValue)
                    myGame.bloodShakeAlpha = easingLin(tweenValue)
                else
                    -- Disparition de la tache de sang
                    local maxRange = 0.8 * myGame.bloodShakeMaxTtl
                    local minRange = 0
                    local currentRange = myGame.bloodShakeTtl
                    local tweenValue = currentRange / (maxRange - minRange)

                    myGame.bloodShakeZoom = 1
                    myGame.bloodShakeAlpha = easingLin(tweenValue)
                end
            else
                myGame.bloodShake = false
                myGame.bloodShakeTtl = myGame.bloodShakeMaxTtl
            end
        end
    end

    myGame.drawBloodShake = function ()
        if myGame.bloodShake == true then
            love.graphics.setColor(255, 255, 255, myGame.bloodShakeAlpha)
            love.graphics.draw(
                myGame.resources.images.blood,
                love.graphics:getWidth() / 2,
                love.graphics:getHeight() / 2,
                0,
                myGame.bloodShakeZoom,
                myGame.bloodShakeZoom,
                myGame.resources.images.blood:getWidth() / 2,
                myGame.resources.images.blood:getHeight() / 2
            )
            love.graphics.setColor(255, 255, 255)
        end
    end

    myGame.drawGameEnd = function (myAlpha)
        -- Filtre transparent
        love.graphics.setColor(255, 255, 255, myAlpha)
        love.graphics.draw(myGame.resources.images.background, 0, 0)
        love.graphics.setColor(255, 255, 255)

        local mainLabel
        local actionsLabel
        if myGame.map.playerWin == true then
            mainLabel = "Victorious"
            actionsLabel = "\"Escape\" to main menu, \"Return\" to continue"
        
        elseif myGame.map.playerLoose == true then
            mainLabel = "Defeated"
            actionsLabel = "\"Escape\" to main menu, \"Return\" to retry"

        end
        
        love.graphics.setFont(myGame.resources.fonts.giant)
        local font = love.graphics.getFont()
        love.graphics.print(mainLabel, (love.graphics.getWidth() - font:getWidth(mainLabel)) / 2, (love.graphics.getHeight() - font:getHeight(mainLabel)) / 2)

        love.graphics.setFont(myGame.resources.fonts.small)
        local font = love.graphics.getFont()
        love.graphics.print(actionsLabel, (love.graphics.getWidth() - font:getWidth(actionsLabel)) / 2, 6 * (love.graphics.getHeight() - font:getHeight(actionsLabel)) / 7)
        
        local image = myGame.resources.images.medals[myGame.map.number]

        love.graphics.draw(
            image,
            (love.graphics:getWidth() - image:getWidth()) / 2,
            (love.graphics:getHeight() - image:getHeight()) / 3,
            0,
            1 + myGame.map.number / 5,
            1 + myGame.map.number / 5,
            image:getWidth() / 2,
            image:getHeight() / 2
        ) 
        if myGame.map.playerLoose == true then
            love.graphics.draw(
                myGame.resources.images.cross,
                (love.graphics:getWidth() - image:getWidth()) / 2,
                (love.graphics:getHeight() - image:getHeight()) / 3,
                0,
                1,
                1,
                myGame.resources.images.cross:getWidth() / 2,
                myGame.resources.images.cross:getHeight() / 2
            ) 
        end

        love.graphics.setColor(255, 255, 255)
    end

    myGame.drawPause = function ()
        -- Libellé
        love.graphics.setFont(myGame.resources.fonts.giant)
        local font = love.graphics.getFont()
        local label = "Pause"
        love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, (love.graphics.getHeight() - font:getHeight(label)) / 2)

        love.graphics.setFont(myGame.resources.fonts.small)
        local font = love.graphics.getFont()
        local label = "\"Escape\" to main menu, \"Space\" to resume"
        love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, 6 * (love.graphics.getHeight() - font:getHeight(label)) / 7)
    end

    myGame.drawMessage = function ()
        -- Affichage du titre de la messagebox
        love.graphics.setFont(myGame.resources.fonts.large)
        local font = love.graphics.getFont()
        local label = myGame.message[1]
        local availableHeight = myGame.resources.images.bandeau:getHeight()
        love.graphics.print(
            label, 
            (love.graphics.getWidth() - font:getWidth(label)) / 2, 
            (love.graphics.getHeight() - myGame.resources.images.bandeau:getHeight()) / 2 + availableHeight / 5)    

        love.graphics.setFont(myGame.resources.fonts.small)
        local font = love.graphics.getFont()
        local label = myGame.message[2]
        local availableHeight = myGame.resources.images.bandeau:getHeight()
        love.graphics.print(
            label, 
            (love.graphics.getWidth() - font:getWidth(label)) / 2, 
            (love.graphics.getHeight() - myGame.resources.images.bandeau:getHeight()) / 2 + 3 * availableHeight / 5)  

        local label = myGame.message[3]
        local availableHeight = myGame.resources.images.bandeau:getHeight()
        love.graphics.print(
            label, 
            (love.graphics.getWidth() - font:getWidth(label)) / 2, 
            (love.graphics.getHeight() - myGame.resources.images.bandeau:getHeight()) / 2 + 4 * availableHeight / 5)  
    end

    myGame.draw = function ()
        -- On draw la map
        love.graphics.setShader(myGame.shader)
        myGame.shader:send("screen", { love.graphics:getWidth(), love.graphics.getHeight() })
        local j = 0
        for i, myMissile in ipairs(myGame.missiles) do
            if myMissile.isFired == true then
                local name = "lights[" .. j .."]"
                myGame.shader:send(name .. ".position", { math.floor(myMissile.initialx + myGame.offset.x), math.floor(myMissile.initialy + myGame.offset.y)})
                myGame.shader:send(name .. ".diffuse", {1.0, 1.0, 1.0})
                myGame.shader:send(name .. ".power", 512)
                j = j + 1
            elseif myMissile.exploded == true then
                local name = "lights[" .. j .."]"
                myGame.shader:send(name .. ".position", { math.floor(myMissile.x + myGame.offset.x), math.floor(myMissile.y + myGame.offset.y)})
                myGame.shader:send(name .. ".diffuse", {1.0, 1.0, 1.0})
                myGame.shader:send(name .. ".power", 512)
                j = j + 1
            end
        end

        for i, myTank in ipairs(myGame.tanks) do
            if myTank.outDated == true then
                local name = "lights[" .. j .."]"
                myGame.shader:send(name .. ".position", { math.floor(myTank.x + myGame.offset.x), math.floor(myTank.y + myGame.offset.y)})
                myGame.shader:send(name .. ".diffuse", {1.0, 0.0, 0.0})
                myGame.shader:send(name .. ".power", 128)
                j = j + 1
            end    
        end

        for i, myGoals in ipairs(myGame.map.goalHitbox) do
            if myGoals.achieved == false then
                local name = "lights[" .. j .."]"
                myGame.shader:send(name .. ".position", { math.floor(myGoals.x + myGame.offset.x), math.floor(myGoals.y + myGame.offset.y)})
                myGame.shader:send(name .. ".diffuse", {1.0, 0.5, 0.0})
                myGame.shader:send(name .. ".power", 256)
                j = j + 1
            end    
        end

        myGame.shader:send("num_lights", j)
        
        love.graphics.draw(myGame.mapGround, myGame.offset.x, myGame.offset.y)
        love.graphics.setShader()


        -- On draw les sprites (tanks et missiles)
        for i, mySprite in ipairs(myGame.sprites) do
            mySprite.draw()
        end

        -- On draw le canvas avec les éléments les plus hauts
        love.graphics.draw(myGame.mapAerial, myGame.offset.x, myGame.offset.y)

        myGame.map.draw()

        myGame.drawBloodShake()

        if myGame.mode == gameConstants.modes.pause then
            -- Filtre transparent
            love.graphics.setColor(255, 255, 255, 0.75)
            love.graphics.draw(myGame.resources.images.background, 0, 0)

            -- Libellé
            myGame.drawPause()
            love.graphics.setColor(255, 255, 255)
            
        elseif myGame.mode == gameConstants.modes.initpause then
            -- Filtre transparent
            love.graphics.setColor(255, 255, 255, easingLin(myGame.initialTtl / gameConstants.modes.ttl) * 0.75)
            love.graphics.draw(myGame.resources.images.background, 0, 0)

            -- Libellé
            myGame.drawPause()
            love.graphics.setColor(255, 255, 255)
                
        elseif myGame.mode == gameConstants.modes.quitpause then
            -- Filtre transparent
            love.graphics.setColor(255, 255, 255, easingLin((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl) * 0.75)
            love.graphics.draw(myGame.resources.images.background, 0, 0)

            -- Libellé
            myGame.drawPause()
            love.graphics.setColor(255, 255, 255)

        elseif myGame.mode == gameConstants.modes.initMessage then
            -- Filtre transparent
            love.graphics.setColor(255, 255, 255, easingLin(myGame.initialTtl / gameConstants.modes.ttl) * 0.75)
            love.graphics.draw(myGame.resources.images.bandeau, 0, (love.graphics.getHeight() - myGame.resources.images.bandeau:getHeight()) / 2)

            -- Libellé
            myGame.drawMessage()
            love.graphics.setColor(255, 255, 255)
            
        elseif myGame.mode == gameConstants.modes.message then
            -- Filtre transparent
            love.graphics.setColor(255, 255, 255, 0.75)
            love.graphics.draw(myGame.resources.images.bandeau, 0, (love.graphics.getHeight() - myGame.resources.images.bandeau:getHeight()) / 2)

            -- Libellé
            myGame.drawMessage()
            love.graphics.setColor(255, 255, 255)
                
        elseif myGame.mode == gameConstants.modes.quitMessage then
            -- Filtre transparent
            love.graphics.setColor(255, 255, 255, easingLin((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl) * 0.75)
            love.graphics.draw(myGame.resources.images.bandeau, 0, (love.graphics.getHeight() - myGame.resources.images.bandeau:getHeight()) / 2)

            -- Libellé
            myGame.drawMessage()
            love.graphics.setColor(255, 255, 255)

        elseif myGame.mode == gameConstants.modes.initGameEnd then
            myGame.drawGameEnd(easingLin(myGame.initialTtl / gameConstants.modes.ttl) * 0.75)
            
        elseif myGame.mode == gameConstants.modes.gameEnd then
            myGame.drawGameEnd(0.75)

        elseif myGame.mode == gameConstants.modes.init then
            love.graphics.setColor(0, 0, 0, easingLin((gameConstants.modes.ttl - myGame.initialTtl) / gameConstants.modes.ttl))
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(255, 255, 255)

        elseif myGame.mode == gameConstants.modes.quit then
            love.graphics.setColor(0, 0, 0, easingLin(myGame.initialTtl / gameConstants.modes.ttl))
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(255, 255, 255)
        end
    end

    myGame.playSound = function (sound, pitch)
        sound:stop()
        sound:setPitch(pitch)
        sound:play()
    end
    
    myGame.displayGameMessage = function (label)
        myGame.playSound(myGame.resources.sounds.validation, 1)
        myGame.mode = gameConstants.modes.initMessage
        myGame.message = label
        myGame.initialTtl = 0
    end

    myGame.changeScreen = function (whatToDo, parameter1, parameter2)
        myGame.mode = gameConstants.modes.quit
        myGame.initialTtl = 0
        myGame.actionToDo = whatToDo
        myGame.actionToDoParam1 = parameter1
        myGame.actionToDoParam2 = parameter2
    end

    myGame.switchPausefunction = function()
        myGame.playSound(myGame.resources.sounds.validation, 1)
        if myGame.mode == gameConstants.modes.pause then
            myGame.mode = gameConstants.modes.quitpause
        elseif myGame.mode == gameConstants.modes.game then
            myGame.mode = gameConstants.modes.initpause
        end
    end

    myGame.loadmap = function (map, playerSkin)
        map.playerSkin = playerSkin
        myGame.map.music:stop()
        myGame.resources.musics.win:stop()
        myGame.resources.musics.loose:stop()
        myGame.init(map)
    end

    myGame.quitApp = function ()
        love.event.quit()
    end

    myGame.mousepressed = function (x, y, button, istouch, presses)  
        myGame.map.mousepressed(x, y, button, istouch, presses)
    end

    myGame.keypressed = function (key, scancode, isrepeat)
        if key == "return" then
            if myGame.mode == gameConstants.modes.message then
                myGame.mode = gameConstants.modes.quitMessage
            end

        end
        myGame.map.keypressed(key, scancode, isrepeat)
    end

    return myGame
end
