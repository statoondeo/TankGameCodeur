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
    myMap.constantes.tiles.number.x = 24
    myMap.constantes.tiles.number.y = 12
    myMap.music = myMap.game.resources.musics.map2

    myMap.tiles = 
    {
    25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26,
    26,  2,  7,  7,  7,  7,  7,  7,  1, 25, 26, 25, 26, 25, 26, 25,  2,  7,  7,  7,  7,  1, 26, 25,
    25,  8, 25, 26, 25, 26, 25, 26,  8, 26, 25, 26, 25, 26, 25, 26,  8, 26, 25, 26, 25,  8, 25, 26,
    26,  8, 26, 25, 26, 25, 26, 25,  4,  1, 26, 25, 26, 25, 26, 25,  8, 25, 26, 25, 26,  9,  1, 25,
    25,  9,  1, 26, 25, 26, 25, 26, 25,  8, 25, 26, 25, 26, 25, 26,  8, 26, 25, 26, 25,  8,  8, 26,
    26,  8,  8, 25, 26, 25, 26, 25, 26,  4,  7,  7,  1, 25, 26,  2,  3, 25, 26, 25, 26,  8,  8, 25,
    25,  8,  8, 26, 25, 26, 25, 26, 25, 26, 25, 26,  8, 26, 25,  8, 25, 26, 25, 26, 25,  8,  8, 26,
    26,  8,  8, 25, 26, 25, 26, 25, 26, 25, 26, 25,  8,  2,  7,  3, 26, 25, 26, 25, 26,  8,  8, 25,
    25,  4, 12, 26, 25, 26, 25, 26, 25, 26, 25, 26,  8,  8, 25, 26, 25, 26, 25, 26, 25,  4, 12, 26,
    26,  2,  3, 25, 26, 25, 26, 25, 26, 25, 26, 25,  4,  6,  7,  7,  1, 25, 26, 25, 26, 25,  8, 25,
    25,  4,  7,  7,  7,  7, 11,  7,  7,  7,  1, 26, 25,  8, 25, 26,  9,  7,  7,  7,  7,  7,  3, 26,
    26, 25, 26, 25, 26, 25,  4,  7,  7,  7, 10,  7,  7, 10,  7,  7,  3, 25, 26, 25, 26, 25, 26, 25,
    }

    -- Point de départ du joueur
    myMap.start = 
    {
        2, 3, math.pi / 2
    }

    -- Liste des ennemis
    myMap.enemies = 
    {
        { 5, 6, 1, 0 },
        { 5, 6, 10, math.pi },
        { 5, 18, 1, 0 },
        { 5, 18, 10, math.pi },
        { 6, 22, 5, math.pi / 2 },
    }

    -- Bornes de la carte
    myMap.rightBound = myMap.constantes.tiles.number.x * gameConstants.tiles.size.x
    myMap.bottomBound = myMap.constantes.tiles.number.y * gameConstants.tiles.size.y
    myMap.goals1 = 
    {
        { 12, 7, 20, true },
        { 18, 0, 20, true },
        { 6, 11, 20, true }
    }
    myMap.goals2 = 
    {
        { 2, 3, 20, false },
    }
    -- Numéro de carte
    myMap.number = 2

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
        --  1    2      3       4       5       6       7       8   9       10  11      12      13
        {   0,  190,    380,    0,      1,      true,   true,   1,  false,  0,  150,    200,    { 1, 4 } },
        {   0,  420,    400,    0,      1,      true,   true,   1,  false,  0,  280,    180,    { 1, 4 } },
        {   0,  500,    320,    0,      1,      false,   true,   1,  false,  0,  80,     70,     { 7, 8 } },
        {   0,  220,    130,    0,      1,      true,   true,   1,  false,  0,  160,    130,    { 1, 4 } },
        {   0,  360,    190,    0,      1,      true,   true,   1,  false,  0,  100,    80,     { 1, 4 } },
        {   0,  760,    150,    0,      1,      true,   true,   1,  false,  0,  160,    100,    { 1, 4 } },
        {   0,  800,    50,     0,      1,      false,   true,   1,  false,  0,  80,    50,    { 7, 8 } },
        {   0,  1040,   400,    0,      1,      true,   true,   1,  false,  0,  300,    170,    { 1, 4 } },
        {   0,  1250,   180,    0,      1,      false,   true,   1,  false,  0,  80,     80,     { 7, 8 } },

        {   love.math.random(9, 10),  146,236,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  65,76,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  47,343,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  175,635,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  153,737,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  572,638,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  736,694,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  556,250,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  618,99,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  934,425,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  916,538,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  981,652,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  921,688,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  912,355,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  995,234,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1123,253,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1182,153,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1292,48,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1458,103,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1418,178,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1428,271,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1345,573,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1486,643,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },
        {   love.math.random(9, 10),  1148,740,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 2/3,   true,  0,  0,  0,  {} },

        {   11,  840, 560,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 1/5,   true,  0,  0,  0,  {} },
        {   11,  720, 640,    love.math.random(),   love.math.random() * 0.2 + 0.9, false, false, 1/5,   true,  0,  0,  0,  {} },
    }

    myMap.init = function ()  
        myMap.playerWin = false
        myMap.playerLoose = false
        myMap.playerDetected = false
        myMap.missionStep = 1
        myMap.angle = 0
        myMap.goalAchieved = 0
        myMap.goalHitbox = {}
        myMap.createGoals(myMap.goals1)
        myMap.music:setLooping(true)
        myMap.music:play()
    end

    myMap.endInit = function ()
        myMap.game.displayGameMessage({"Mission", "Find and get the 3 ammo stocks", "Don't get detected"})
    end

    myMap.createGoals = function (myGoals)
        for i, myGoal in ipairs(myGoals) do
            local goalHitbox = createHitbox(myMap.game, hitboxConstants.circleType)
            local point = myMap.game.GetTileCenterFromTileInMap(myGoal[2] * myMap.constantes.tiles.number.x + myGoal[1])
            goalHitbox.x = point.x
            goalHitbox.y = point.y
            goalHitbox.radius = myGoal[3]
            goalHitbox.achieved = false
            goalHitbox.bonus = myGoal[4]
            table.insert(myMap.goalHitbox, goalHitbox)
        end
    end

    myMap.CheckPlayerWin = function ()
        -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
        local win = false
        if myMap.missionStep == 1 then
            local allGoalAchieved = true
            for i, myGoal in ipairs(myMap.goalHitbox) do
                if myGoal.achieved == false and myMap.game.playerTank.hitbox.IsCollision(myGoal) == true then
                    myGoal.achieved = true
                    myMap.goalAchieved = myMap.goalAchieved + 1
                    myMap.game.playSound(myMap.game.resources.sounds.validation, 1)
                end
                allGoalAchieved = allGoalAchieved and myGoal.achieved
            end
            if allGoalAchieved == true then
                myMap.missionStep = 2
                myMap.goalHitbox = {}
                myMap.createGoals(myMap.goals2)
                myMap.game.displayGameMessage({"Mission update", "Get back to start to escape", "Stay alive"})
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