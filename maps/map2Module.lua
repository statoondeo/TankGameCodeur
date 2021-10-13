local this = {}

this.constantes = {}

this.constantes.tiles = {}
this.constantes.tiles.size = {}
this.constantes.tiles.size.x = 64
this.constantes.tiles.size.y = 64
this.constantes.tiles.number = {}
this.constantes.tiles.number.x = 24
this.constantes.tiles.number.y = 12
this.music = game.musics.map2

this.tiles = 
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
this.start = 
{
    2, 3, math.pi / 2
}

-- Liste des ennemis
this.ennemis = 
{
    { 5, 7, 2, 0 },
    { 5, 7, 11, math.pi },
    { 5, 19, 2, 0 },
    { 5, 19, 11, math.pi },
    { 6, 22, 6, math.pi / 2 },
}

-- Bornes de la carte
local rightBound = this.constantes.tiles.number.x * this.constantes.tiles.size.x
local bottomBound = this.constantes.tiles.number.y * this.constantes.tiles.size.y
this.goals1 = 
{
    { 12, 8, 20, true },
    { 18, 1, 20, true },
    { 6, 12, 20, true }
}
this.goals2 = 
{
    { 2, 3, 20, false },
}
-- Numéro de carte
this.number = 2

this.obstacles = 
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
    {   0,  -54,                -54,               0,  1,  true,   true,   1,  false,  0,  rightBound + 128,   64,              { 1, 4 } },
    {   0,  -54,                0,                 0,  1,  true,   true,   1,  false,  0,  64,                 bottomBound,     { 1, 4 } },
    {   0,  -54,                bottomBound - 10,  0,  1,  true,   true,   1,  false,  0,  rightBound + 128,   64,              { 1, 4 } },
    {   0,  rightBound - 10,    0,                 0,  1,  true,   true,   1,  false,  0,  64,                  bottomBound,    { 1, 4 } },

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

function this.init()  
    this.playerWin = false
    this.playerLoose = false
    this.playerDetected = false
    this.missionStep = 1
    this.angle = 0
    this.goalAchieved = 0
    this.goalHitbox = {}
    this.goals = this.goals1
    for i = 1, #this.goals do
        local goalHitbox = game.hitbox.create(game.hitbox.constantes.circleType)
        goalHitbox.x = (this.goals[i][1] - 0.5) * this.constantes.tiles.size.x
        goalHitbox.y = (this.goals[i][2] - 0.5) * this.constantes.tiles.size.y
        goalHitbox.radius = this.goals[i][3]
        goalHitbox.achieved = false
        goalHitbox.bonus = this.goals[i][4]
        table.insert(this.goalHitbox, goalHitbox)
    end
    this.music:setLooping(true)
    this.music:play()
end

function this.endInit()
    game.displayGameMessage({"Mission", "Find and get the 3 ammo stocks", "Don't get detected"})
end

function this.CheckPlayerWin()
    -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
    local win = false
    if this.missionStep == 1 then
        local allGoalAchieved = true
        for i, myGoal in ipairs(this.goalHitbox) do
            if myGoal.achieved == false and game.hitbox.IsCollision(game.playerTank.hitBox, myGoal) == true then
                myGoal.achieved = true
                this.goalAchieved = this.goalAchieved + 1
                game.sounds.validation:play()
            end
            allGoalAchieved = allGoalAchieved and myGoal.achieved
        end
        if allGoalAchieved == true then
            this.missionStep = 2
            this.goalHitbox = {}
            this.goals = this.goals2
            for i = 1, #this.goals do
                local goalHitbox = game.hitbox.create(game.hitbox.constantes.circleType)
                goalHitbox.x = (this.goals[i][1] - 0.5) * this.constantes.tiles.size.x
                goalHitbox.y = (this.goals[i][2] - 0.5) * this.constantes.tiles.size.y
                goalHitbox.radius = this.goals[i][3]
                goalHitbox.achieved = false
                goalHitbox.bonus = this.goals[i][4]
                table.insert(this.goalHitbox, goalHitbox)
            end
            game.displayGameMessage({"Mission update", "Get back to start to escape", "Stay alive"})
        end

    elseif this.missionStep == 2 then
        if game.hitbox.IsCollision(game.playerTank.hitBox, this.goalHitbox[1]) == true then
            this.goalHitbox[1].achieved = true
            game.sounds.validation:play()
        end
        win = this.goalHitbox[1].achieved
        if win == true then
            win = false
            this.missionStep = 3
            this.goalHitbox = {}
            game.displayGameMessage({"Mission update", "Reinforcements are late, seek and destroy main ennemy tank", "Stay alive"})
        end

    elseif this.missionStep == 3 then
        for i, myTank in ipairs(game.tank.tanks) do
            if myTank.mode == game.constantes.tank.modes.ennemy and myTank.skin == 6 and myTank.outDated == true then
                win = true
                break
            end
        end

    end
    return win
end

function this.CheckPlayerLoose()
    if this.missionStep == 1 then
        -- On vérifie la condition de défaite (le tank joueur détecté)
        local loose = false
        for i, myEnemyTank in ipairs(game.tank.tanks) do
            if game.tank.tanks[i].mode == game.constantes.tank.modes.ennemy then
                if myEnemyTank.turret.state == 3 then
                    loose = true
                    break
                end
            end            
        end
        return loose

    elseif this.missionStep == 2 then
        -- On vérifie la condition de défaite (le tank joueur détruit)
        return game.playerTank.outDated

    elseif this.missionStep == 3 then
        -- On vérifie la condition de défaite (le tank joueur détruit)
        return game.playerTank.outDated

    end
end

function this.update(dt, mouse)
    this.angle = (this.angle + dt) % (2 * math.pi)

    -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
    this.playerWin = this.CheckPlayerWin()
    -- On vérifie la condition de défaite (le tank joueur détruit)
    this.playerLoose = this.CheckPlayerLoose()
    
    if this.playerWin == true then
        game.mode = game.constantes.modes.initGameEnd
    elseif this.playerLoose == true then
        game.mode = game.constantes.modes.initGameEnd
    end
end

function this.draw()
    love.graphics.setFont(game.fonts.small)
    local font = love.graphics.getFont()
    local label
    if this.missionStep == 1 then
        label = "Ammo stocks " .. this.goalAchieved .. "/3"
    elseif this.missionStep == 2 then
        label = "Get back to start to escape"
    elseif this.missionStep == 3 then
        label = "Seek and destroy main ennemy Tank"
    end
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, font:getHeight(label))

    for i, myGoal in ipairs(this.goalHitbox) do
        if myGoal.achieved == false then
            if myGoal.bonus == true then
                love.graphics.draw(
                    game.images.bonus, 
                    myGoal.x + game.offset.x, 
                    myGoal.y + game.offset.y, 
                    this.angle, 
                    1, 
                    1, 
                    game.images.bonus:getWidth() / 2, 
                    game.images.bonus:getHeight() / 2)
            else
                love.graphics.setColor(0, 255, 123, 0.75)
                love.graphics.circle("fill", myGoal.x + game.offset.x, myGoal.x + game.offset.y, myGoal.radius)
                love.graphics.setColor(255, 255, 255)
            end
        end
    end
end

function this.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        if game.pauseState == true then
            game.pauseState = false
        end
        game.changeScreen(game.loadmap, require("maps/mainTitleModule")) 

    elseif key == "return" then
        if this.playerWin == true then
            game.changeScreen(game.loadmap, require("maps/mainTitleModule")) 
        elseif this.playerLoose == true then
            game.changeScreen(game.loadmap, require("maps/map2Module"), game.playerTank.skin) 
        end

    elseif key == "space" then
        game.switchPause()
    end
end

function this.mousepressed(x, y, button, istouch, presses)  
    game.tank.fire(game.playerTank)
end

return this