function createMap1(myGame)
    local gameConstants = require("modules/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local tankConstants = require("tanks/constants")
    local turretConstants = require("turrets/constants")
    local myMap = {}
    myMap.game = myGame
    myMap.constantes = {}

    myMap.constantes.tiles = {}
    myMap.constantes.tiles.size = {}
    myMap.constantes.tiles.size.x = 64
    myMap.constantes.tiles.size.y = 64
    myMap.constantes.tiles.number = {}
    myMap.constantes.tiles.number.x = 16
    myMap.constantes.tiles.number.y = 12
    myMap.music = myMap.game.resources.musics.map1

    myMap.tiles = 
    {
    26, 25, 26, 25, 26, 25, 26, 21, 39, 40, 39, 40, 39, 40, 39, 40,
    25,  2,  7,  7,  1, 25, 26, 21, 39, 40, 39, 40, 39, 40, 39, 39,
    26,  8, 26, 25,  8, 26, 25, 21, 28, 33, 33, 33, 33, 33, 27, 40,
    25,  8, 25, 26,  8, 25, 26, 21, 34, 40, 39, 40, 39, 40, 34, 40,
    26,  4,  7,  7,  6,  7,  7, 14, 31, 33, 27, 39, 40, 39, 34, 39,
    25, 26, 25, 26,  8, 25, 26, 21, 34, 40, 34, 40, 39, 40, 34, 40,
    26, 25, 26, 25,  8, 26, 25, 21, 34, 39, 34, 39, 40, 39, 34, 39,
    25, 26, 25, 26,  8, 25, 26, 21, 34, 40, 34, 40, 39, 40, 34, 40,
    26, 25, 26, 25,  8, 26, 25, 21, 34, 39, 34, 39, 40, 39, 34, 39,
    25, 26, 25, 26,  8, 25, 26, 21, 34, 40, 35, 33, 33, 33, 29, 40,
    26, 25, 26, 25,  4,  7,  7, 13, 36, 33, 29, 39, 40, 39, 40, 39,
    25, 25, 26, 25, 26, 25, 26, 21, 40, 39, 40, 39, 40, 39, 40, 39
    }

    -- Point de départ du joueur
    myMap.start = 
    {
        2, 9, 0 
    }

    -- Numéro de carte
    myMap.number = 1

    -- Liste des ennemis
    myMap.enemies = 
    {
        { 5, 3, 2, 0 },
        { 5, 6, 11, math.pi },
        { 5, 15, 5, math.pi / 2 }
    }
    myMap.goals = 
    {
        { 15, 2, 20 }
    }

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
        -- 9 -> hitbox ronde sinon rectanglaire (true pour aucune interaction)
        -- 10 -> radius de la hitbox si ronde et non visible (image = 0)
        -- 11 -> width de la hitbox si retangulaire
        -- 11 -> height de la hitbox si retangulaire
        --  1   2       3       4                               5                       6       7       8    9      10  11  12
        -- éléments de décor interagissant avec les collisions
        {   7,  710,    650,    love.math.random(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
        {   7,  880,    570,    love.math.random(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
        {   8,  780,    210,    love.math.random(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
        {   8,  810,    210,    love.math.random(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
        {   8,  840,    210,    love.math.random(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
        {  11,  400,    400,    love.math.random(0, 2 * math.pi),   love.math.random() * 0.2 + 0.9, false,  false,  1/5, true,  0,  0,  0,  {} },

        {  love.math.random(9, 10),  146,236,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  65,76,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  47,343,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  175,635,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  153,737,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  572,638,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  736,694,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },
        {  love.math.random(9, 10),  556,250,    love.math.random(),   love.math.random() * 0.2 + 0.8, false, false, 2/3,   true,  0,  0,  0,  {} },

        -- Bornes de l'écran pour éviter que les tanks ou les missiles ne sortent
        {  0,   -54,   -54,   0,                              1,  true,   true,   1,    false, 0,  love.graphics:getWidth() + 128,  64,  { 1, 6 } },
        {  0,   -54,   0,      0,                              1,  true,   true,   1,    false, 0,  64,  love.graphics:getHeight(),  { 1, 6 } },
        {  0,   -54,   love.graphics:getHeight() - 10,   0,         1,  true,   true,   1,    false, 0,  love.graphics:getWidth() + 128,  64,  { 1, 6 } },
        {  0,   love.graphics:getWidth() - 10,   0,      0,          1,  true,   true,   1,    false, 0,  64,  love.graphics:getHeight(),  { 1, 6 } },
        
        -- Zones vides à peupler
        {  0,   90,    360,    0, 1,     true,   true,  1, false, 0,  160,  120,  { 1, 6} },
        {  0,   0,    610,    0, 1,     true,   true,  1, false, 0,  240,  130,  { 1, 6} },
        {  0,   680,    200,    0, 1,     true,   true,  1, false, 0,  110,  70,  { 1, 6} },
        {  0,   780,    370,    0, 1,     true,   true,  1, false, 0,  100,  70,  { 1, 6} },
        {  0,   720,    500,    0, 1,     true,   true,  1, false, 0,  60,  50,  { 1, 6} },
        {  0,   350,    70,    0, 1,     true,   true,  1, false, 0,  110,  110,  { 1, 6} },
        {  0,   150,    150,    0, 1,     true,   true,  1, false, 0,  90,  90,  { 1, 6} },
        {  0,   370,    550,    0, 1,     false,   true,  1, false, 0,  100,  50,  { 7, 8} },
        {  0,   570,    70,    0, 1,     false,   true,  1, false, 0,  200,  40,  { 7, 8} },
    }

    myMap.init = function ()  
        myMap.playerWin = false
        myMap.playerLoose = false
        myMap.playerDetected = false
        myMap.missionStep = 1
        myMap.goalHitbox = createHitbox(hitboxConstants.circleType)
        myMap.goalHitbox.x = (myMap.goals[1][1] - 0.5) * myMap.constantes.tiles.size.x
        myMap.goalHitbox.y = (myMap.goals[1][2] - 0.5) * myMap.constantes.tiles.size.y
        myMap.goalHitbox.radius = myMap.goals[1][3]
        myMap.goalHitbox.angle = 0
        myMap.goals[1][4] = false
        myMap.music:setLooping(true)
        myMap.music:play()
        myMap.enemyTank = #myMap.enemies
    end

    myMap.endInit = function ()
        myMap.game.displayGameMessage({"Mission", "Find and get ammo stock", "Don't get detected"})
    end

    myMap.CheckPlayerWin = function ()
        -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
        local win = false
        if myMap.missionStep == 1 then
            if myMap.game.playerTank.hitbox.IsCollision(myMap.goalHitbox) == true then
                myMap.goals[1][4] = true
                myMap.missionStep = 2
                myMap.destroyedTank = 0
                myMap.game.displayGameMessage({"Mission update", "Seek and destroy all enemy Tanks", "Stay alive"})
                myMap.game.resources.sounds.validation:play()
            end
        elseif myMap.missionStep == 2 then
            myMap.destroyedTank = 0
            for i, myTank in ipairs(myMap.game.tanks) do
                if myTank.mode == tankConstants.modes.enemy then
                    if myTank.outDated == true then
                        myMap.destroyedTank =  myMap.destroyedTank + 1
                    end
                end
            end
            win = myMap.destroyedTank == myMap.enemyTank
        end
        return win
    end

    myMap.CheckPlayerLoose = function ()
        if myMap.missionStep == 1 then
            -- On vérifie la condition de défaite (le tank joueur détecté)
            local loose = false
            for i, myEnemyTank in ipairs(myMap.game.tanks) do
                if myMap.game.tanks[i].mode == tankConstants.modes.enemy then
                    if myEnemyTank.turret.state == turretConstants.enemy.attack.mode then
                        loose = true
                        break
                    end
                end            
            end
            return loose
        elseif myMap.missionStep == 2 then
            -- On vérifie la condition de défaite (le tank joueur détruit)
            return myMap.game.playerTank.outDated
        end
    end

    myMap.update = function (dt)
        -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
        myMap.playerWin = myMap.CheckPlayerWin()
        -- On vérifie la condition de défaite (le tank joueur détruit)
        myMap.playerLoose = myMap.CheckPlayerLoose()
        
        if myMap.playerWin == true then
            if myMap.game.mode ~= gameConstants.modes.initGameEnd then
                myMap.game.mode = gameConstants.modes.initGameEnd
            end
        elseif myMap.playerLoose == true then
            if myMap.game.mode ~= gameConstants.modes.initGameEnd then
                myMap.game.mode = gameConstants.modes.initGameEnd
            end
        end
        if myMap.goals[1][4] == false then
            -- Affichage de l'Objectif
            myMap.goalHitbox.angle = myMap.goalHitbox.angle + dt
        end
    end

    myMap.draw = function ()
        love.graphics.setFont(myMap.game.resources.fonts.small)
        local font = love.graphics.getFont()
        local label
        if myMap.missionStep == 1 then
            label = "Ammo stocks 0/1"
        elseif myMap.missionStep == 2 then
            label = "Seek and destroy all enemy Tanks " .. myMap.destroyedTank .. "/" .. myMap.enemyTank
        end
        love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, font:getHeight(label))

        if myMap.goals[1][4] == false then
            -- Affichage de l'Objectif
            love.graphics.draw(myMap.game.resources.images.bonus, 
                math.floor(myMap.goalHitbox.x), 
                math.floor(myMap.goalHitbox.y), 
                myMap.goalHitbox.angle, 
                1, 
                1, 
                math.floor(myMap.game.resources.images.bonus:getWidth() / 2), 
                math.floor(myMap.game.resources.images.bonus:getHeight() / 2))
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
                myMap.game.changeScreen(myMap.game.loadmap, createMap2(myMap.game), myMap.game.playerTank.skin) 
            elseif myMap.playerLoose == true then
                myMap.game.changeScreen(myMap.game.loadmap, createMap1(myMap.game), myMap.game.playerTank.skin)         
            end

        elseif key == "space" then
            myMap.game.switchPause()
        end
    end

    myMap.mousepressed = function (x, y, button, istouch, presses)  
        myMap.game.playerTank.fire()
    end

    return myMap
end