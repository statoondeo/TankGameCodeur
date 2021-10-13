local this = {}

this.constantes = {}

this.constantes.tiles = {}
this.constantes.tiles.size = {}
this.constantes.tiles.size.x = 64
this.constantes.tiles.size.y = 64
this.constantes.tiles.number = {}
this.constantes.tiles.number.x = 16
this.constantes.tiles.number.y = 12
this.music = game.musics.map1

this.tiles = 
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
this.start = 
{
    2, 9, 0 
}

-- Numéro de carte
this.number = 1

-- Liste des ennemis
this.ennemis = 
{
    { 5, 3, 2, 0 },
    { 5, 6, 11, math.pi },
    { 5, 15, 5, math.pi / 2 }
}
this.goals = 
{
    { 15, 2, 20 }
}

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
    {  11,  400,    400,    love.math.random(0, 2 * math.pi),   love.math.random(0.9, 1.1), false,  false,  1/5, true,  0,  0,  0,  {} },
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

function this.init()  
    this.playerWin = false
    this.playerLoose = false
    this.playerDetected = false
    this.missionStep = 1
    this.goalHitbox = game.hitbox.create(game.hitbox.constantes.circleType)
    this.goalHitbox.x = (this.goals[1][1] - 0.5) * this.constantes.tiles.size.x
    this.goalHitbox.y = (this.goals[1][2] - 0.5) * this.constantes.tiles.size.y
    this.goalHitbox.radius = this.goals[1][3]
    this.goalHitbox.angle = 0
    this.goals[1][4] = false
    this.music:setLooping(true)
    this.music:play()
    this.ennemyTank = #this.ennemis
end

function this.endInit()
    game.displayGameMessage({"Mission", "Find and get ammo stock", "Don't get detected"})
end

function this.CheckPlayerWin()
    -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
    local win = false
    if this.missionStep == 1 then
        if game.hitbox.IsCollision(game.playerTank.hitBox, this.goalHitbox) == true then
            this.goals[1][4] = true
            this.missionStep = 2
            this.destroyedTank = 0
            game.displayGameMessage({"Mission update", "Seek and destroy all enemy Tanks", "Stay alive"})
            game.sounds.validation:play()
        end
    elseif this.missionStep == 2 then
        this.destroyedTank = 0
        for i, myTank in ipairs(game.tank.tanks) do
            if myTank.mode == game.constantes.tank.modes.ennemy then
                if myTank.outDated == true then
                    this.destroyedTank =  this.destroyedTank + 1
                end
            end
        end
        win = this.destroyedTank == this.ennemyTank
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
    end
end

function this.update(dt, mouse)
    -- On vérifie la condition de victoire (tous les tanks ennemis vaincus)
    this.playerWin = this.CheckPlayerWin()
    -- On vérifie la condition de défaite (le tank joueur détruit)
    this.playerLoose = this.CheckPlayerLoose()
    
    if this.playerWin == true then
        if game.mode ~= game.constantes.modes.initGameEnd then
            game.mode = game.constantes.modes.initGameEnd
        end
    elseif this.playerLoose == true then
        if game.mode ~= game.constantes.modes.initGameEnd then
            game.mode = game.constantes.modes.initGameEnd
        end
    end
    if this.goals[1][4] == false then
        -- Affichage de l'Objectif
        this.goalHitbox.angle = this.goalHitbox.angle + dt
    end
end

function this.draw()
    love.graphics.setFont(game.fonts.small)
    local font = love.graphics.getFont()
    local label
    if this.missionStep == 1 then
        label = "Ammo stocks 0/1"
    elseif this.missionStep == 2 then
        label = "Seek and destroy all enemy Tanks " .. this.destroyedTank .. "/" .. this.ennemyTank
    end
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, font:getHeight(label))

    if this.goals[1][4] == false then
        -- Affichage de l'Objectif
        love.graphics.draw(game.images.bonus, 
            math.floor(this.goalHitbox.x), 
            math.floor(this.goalHitbox.y), 
            this.goalHitbox.angle, 
            1, 
            1, 
            math.floor(game.images.bonus:getWidth() / 2), 
            math.floor(game.images.bonus:getHeight() / 2))
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
            game.changeScreen(game.loadmap, require("maps/map2Module"), game.playerTank.skin) 
        elseif this.playerLoose == true then
            game.changeScreen(game.loadmap, require("maps/map1Module"), game.playerTank.skin)         
        end

    elseif key == "space" then
        game.switchPause()
    end
end

function this.mousepressed(x, y, button, istouch, presses)  
    game.tank.fire(game.playerTank)
end

return this