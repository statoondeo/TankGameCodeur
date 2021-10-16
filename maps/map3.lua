function createMap2(myGame)
    local gameConstants = require("modules/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local tankConstants = require("tanks/constants")
    local turretConstants = require("turrets/constants")

    local myMap = {}

    myMap.game = myGame

    myMap.constantes = {}

    myMap.constantes.tiles = {}
    myMap.constantes.tiles.number = {}
    myMap.constantes.tiles.number.x = 16
    myMap.constantes.tiles.number.y = 12
    myMap.music = myMap.game.resources.musics.map2

    myMap.tiles = 
    {
        40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39,
        39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40,
        40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39,
        39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40,
        40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39,
        39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40,
        40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39,
        39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40,
        40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39,
        39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40,
        40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39,
        39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40, 39, 40,
    }

    -- Point de départ du joueur
    myMap.start = 
    {
        7, 8, math.pi / 2
    }

    -- Liste des ennemis
    myMap.enemies = 
    {
    }
    
    myMap.enemies1 = 
    {
        { 5, 7, 0, 0 },
        { 5, 8, 11, 0 },
        { 5, 0, 5, 0 },
        { 5, 15, 6, 0 },
        { 6, 0, 0, 0 },
    }

    -- Bornes de la carte
    myMap.rightBound = myMap.constantes.tiles.number.x * gameConstants.tiles.size.x
    myMap.bottomBound = myMap.constantes.tiles.number.y * gameConstants.tiles.size.y

    -- Numéro de carte
    myMap.number = 3

    myMap.obstacles = 
    {
        -- 1 -> Index de l'image (0 si pas d'affichage)
        -- 2 -> x
        -- 3 -> y
        -- 4 -> angle
        -- 5 -> zoom
        -- 6 -> stop missile
        -- 7 -> stop tank
        -- 8 -> modificateur de vitesse
        -- 9 -> hitbox ronde sinon rectanglaire (nil pour aucune interaction)
        -- 10 -> radius de la hitbox si ronde et non visible (image = 0)
        -- 11 -> width de la hitbox si retangulaire
        -- 12 -> height de la hitbox si retangulaire
        -- 13 -> Liste des images d'obstacle avec lesquelles remplir les zones vides
        --  1   2       3       4                               5                       6       7       8    9      10  11  12
        -- éléments de décor interagissant avec les collisions
        --{   7,  710,    610,    love.math.random(),   1,                      false,  true,  1, true,  0,  0,  0 },

        -- Bornes de l'écran pour éviter que les tanks ou les missiles ne sortent
        --  1    2                  3                  4   5   6       7       8   9       10  11                  12               13
        {   0,  -54,                -54,               0,  1,  true,   true,   1,  false,  0,  myMap.rightBound + 128,   64,              { 1, 4 } },
        {   0,  -54,                0,                 0,  1,  true,   true,   1,  false,  0,  64,                 myMap.bottomBound,     { 1, 4 } },
        {   0,  -54,                myMap.bottomBound - 10,  0,  1,  true,   true,   1,  false,  0,  myMap.rightBound + 128,   64,              { 1, 4 } },
        {   0,  myMap.rightBound - 10,    0,                 0,  1,  true,   true,   1,  false,  0,  64,                  myMap.bottomBound,    { 1, 4 } },

        -- Zones vides à peupler
     }

    myMap.init = function ()  
        myMap.playerWin = false
        myMap.playerLoose = false
        myMap.missionStep = 0
        myMap.angle = 0
        myMap.music:setLooping(true)
        myMap.music:play()
    end

    myMap.CheckPlayerWin = function ()
        -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
        local win = false
        if myMap.missionStep == 0 then
            myMap.missionStep = 1
            myMap.game.displayGameMessage({"Mission", "Defeat the 3 enemy waves", "Stay alive"})

        elseif myMap.missionStep == 1 then
            myMap.destroyedTank = 0
            for i, myTank in ipairs(myMap.game.tanks) do
                if myTank.mode == tankConstants.modes.enemy then
                    if myTank.outDated == true then
                        myMap.destroyedTank =  myMap.destroyedTank + 1
                    end
                end
            end

            if myMap.destroyedTank == myMap.enemyTank then
                myMap.missionStep = 2
                myMap.game.displayGameMessage({"Mission update", "Survive this new enemy wave", "pffff"})
            end

        elseif myMap.missionStep == 2 then
            if myMap.game.playerTank.hitbox.IsCollision(myMap.goalHitbox[1]) == true then
                myMap.goalHitbox[1].achieved = true
                myMap.game.playSound(myMap.game.resources.sounds.validation, 1)
            end
            win = myMap.goalHitbox[1].achieved
            if win == true then
                win = false
                myMap.missionStep = 3
                myMap.goalHitbox = {}
                myMap.game.displayGameMessage({"Mission update", "Reinforcements are late, seek and destroy main enemy tank", "Stay alive"})
            end

        elseif myMap.missionStep == 3 then
            for i, myTank in ipairs(myMap.game.tanks) do
                if myTank.mode == tankConstants.modes.enemy and myTank.skin == 6 and myTank.outDated == true then
                    win = true
                    break
                end
            end

        end
        return win
    end

    myMap.CheckPlayerLoose = function ()
        if myMap.missionStep == 1 then
            -- On vérifie la condition de défaite (le tank joueur détecté)
            local loose = false
            for i, myEnemyTank in ipairs(myMap.game.tanks) do
                if myMap.game.tanks[i].mode == tankConstants.modes.enemy then
                    if myEnemyTank.turret.state == 3 then
                        loose = true
                        break
                    end
                end            
            end
            return loose

        elseif myMap.missionStep == 2 then
            -- On vérifie la condition de défaite (le tank joueur détruit)
            return myMap.game.playerTank.outDated

        elseif myMap.missionStep == 3 then
            -- On vérifie la condition de défaite (le tank joueur détruit)
            return myMap.game.playerTank.outDated

        end
    end

    myMap.update = function (dt)
        myMap.angle = (myMap.angle + dt) % (2 * math.pi)

        -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
        myMap.playerWin = myMap.CheckPlayerWin()
        -- On vérifie la condition de défaite (le tank joueur détruit)
        myMap.playerLoose = myMap.CheckPlayerLoose()
        
        if myMap.playerWin == true then
            myMap.game.mode = gameConstants.modes.initGameEnd
        elseif myMap.playerLoose == true then
            myMap.game.mode = gameConstants.modes.initGameEnd
        end
    end

    myMap.draw = function ()
        love.graphics.setFont(myMap.game.resources.fonts.small)
        local font = love.graphics.getFont()
        local label
        if myMap.missionStep == 1 then
            label = "Ammo stocks " .. myMap.goalAchieved .. "/3"
        elseif myMap.missionStep == 2 then
            label = "Get back to start to escape"
        elseif myMap.missionStep == 3 then
            label = "Seek and destroy main enemy Tank"
        end
        love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, font:getHeight(label))

        for i, myGoal in ipairs(myMap.goalHitbox) do
            if myGoal.achieved == false then
                local asset = nil
                if myGoal.bonus == true then
                    asset = myMap.game.resources.images.bonus
                else
                    asset = myMap.game.resources.images.crosshair
                end
                love.graphics.draw(
                    asset, 
                    myGoal.x + myMap.game.offset.x, 
                    myGoal.y + myMap.game.offset.y, 
                    myMap.angle, 
                    1, 
                    1, 
                    asset:getWidth() / 2, 
                    asset:getHeight() / 2)
            end
        end
    end

    myMap.keypressed = function (key, scancode, isrepeat)
        if key == "escape" then
            if myMap.game.pauseState == true then
                myMap.game.pauseState = false
            end
            myMap.game.changeScreen(myMap.game.loadmap, createMainMenu(myMap.game)) 

        elseif key == "return" then
            if myMap.playerWin == true then
                myMap.game.changeScreen(myMap.game.loadmap, createMainMenu(myMap.game)) 
            elseif myMap.playerLoose == true then
                myMap.game.changeScreen(myMap.game.loadmap, createMap2(myMap.game), myMap.game.playerTank.skin) 
            end

        elseif key == "space" then
            myMap.game.switchPausefunction()
        end
    end

    myMap.mousepressed = function (x, y, button, istouch, presses)  
        myMap.game.playerTank.fire()
    end

    return myMap
end