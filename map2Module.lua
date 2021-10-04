local this = {}

this.constantes = {}

this.constantes.tiles = {}
this.constantes.tiles.size = {}
this.constantes.tiles.size.x = 64
this.constantes.tiles.size.y = 64
this.constantes.tiles.number = {}
this.constantes.tiles.number.x = 24
this.constantes.tiles.number.y = 12

this.tiles = 
{
   25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26,
   26,  2,  7,  7,  7,  7,  7,  7,  1, 25, 26, 25, 26, 25, 26, 25,  2,  7,  7,  7,  7,  1, 26, 25,
   25,  8, 25, 26, 25, 26, 25, 26,  8, 26, 25, 26, 25, 26, 25, 26,  8, 26, 25, 26, 25,  8, 25, 26,
   26,  8, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25,  8, 25, 26, 25, 26,  9,  7,  1,
   25,  9,  1, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26, 25, 26,  8, 26, 25, 26, 25,  8, 25,  8,
   26,  8,  8, 25, 26, 25, 26, 25, 26, 25, 26,  7,  1, 25, 26,  2,  3, 25, 26, 25, 26,  8, 26,  8,
   25,  8,  8, 26, 25, 26, 25, 26, 25, 26, 25, 26,  8, 26, 25,  8, 25, 26, 25, 26, 25,  8, 25,  8,
   26,  8,  8, 25, 26, 25, 26, 25, 26, 25, 26, 25,  8,  2,  7,  3, 26, 25, 26, 25, 26,  8, 26,  8,
   25,  4, 12, 26, 25, 26, 25, 26, 25, 26, 25, 26,  8,  8, 25, 26, 25, 26, 25, 26, 25,  4, 11,  3,
   26,  2,  3, 25, 26, 25, 26, 25, 26, 25, 26, 25,  4,  6,  7,  7,  1, 25, 26, 25, 26, 25,  8, 25,
   25,  4,  7,  7,  7,  7, 11,  7,  7,  7,  1, 26, 25,  8, 25, 26,  9,  7,  7,  7,  7,  7,  3, 26,
   26, 25, 26, 25, 26, 25,  4,  7,  7,  7, 10,  7,  7, 10,  7,  7,  3, 25, 26, 25, 26, 25, 26, 25,
}

-- Point de départ du joueur
this.start = 
{
    95, 180, math.pi / 2
}

-- Liste des ennemis
this.ennemis = 
{
    { 4, 630, 270, math.prandom(0, 2 * math.pi) },
    { 4, 70, 690, math.prandom(0, 2 * math.pi) },
    { 5, 1430, 380, math.prandom(0, 2 * math.pi) },
}

-- Bornes de la carte
local rightBound = this.constantes.tiles.number.x * this.constantes.tiles.size.x
local bottomBound = this.constantes.tiles.number.y * this.constantes.tiles.size.y

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
    --{   7,  710,    610,    math.prandom(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0 },

    -- Bornes de l'écran pour éviter que les tanks ou les missiles ne sortent
    --  1    2                  3                  4   5   6       7       8   9       10  11                  12               13
    {   0,  -50,                -50,               0,  1,  true,   true,   1,  false,  0,  rightBound + 100,   65,              { 1, 4 } },
    {   0,  -50,                0,                 0,  1,  true,   true,   1,  false,  0,  65,                 bottomBound,     { 1, 4 } },
    {   0,  -50,                bottomBound - 15,  0,  1,  true,   true,   1,  false,  0,  rightBound + 100,   65,              { 1, 4 } },
    {   0,  rightBound - 15,    0,                 0,  1,  true,   true,   1,  false,  0,  65,                  bottomBound,    { 1, 4 } },

    -- Zones vides à peupler
    --  1    2      3       4       5       6       7       8   9       10  11      12      13
    {   0,  220,    275,    0,      1,      true,   true,   1,  false,  0,  270,    350,    { 7, 8 } },
    {   0,  190,    380,    0,      1,      true,   true,   1,  false,  0,  150,    200,    { 1, 4 } },
    {   0,  420,    400,    0,      1,      true,   true,   1,  false,  0,  280,    180,    { 1, 4 } },
    {   0,  500,    320,    0,      1,      true,   true,   1,  false,  0,  80,     70,     { 1, 4 } },
    {   0,  220,    130,    0,      1,      true,   true,   1,  false,  0,  160,    130,    { 1, 4 } },
    {   0,  360,    190,    0,      1,      true,   true,   1,  false,  0,  100,    80,     { 1, 4 } },
    {   0,  660,    30,     0,      1,      true,   true,   1,  false,  0,  340,    130,    { 7, 8 } },
    {   0,  760,    150,    0,      1,      true,   true,   1,  false,  0,  160,    100,    { 1, 4 } },
    {   0,  800,    50,    0,      1,      true,   true,   1,  false,  0,  80,    50,    { 1, 4 } },
    {   0,  1040,   400,    0,      1,      true,   true,   1,  false,  0,  300,    170,    { 1, 4 } },
    {   0,  1170,   270,    0,      1,      true,   true,   1,  false,  0,  200,    110,    { 7, 8 } },
    {   0,  1250,   180,    0,      1,      true,   true,   1,  false,  0,  80,     80,     { 1, 4 } },

    {   math.random(1, 4),   70,    580,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  150,    150,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  800,    680,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  960,    540,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  850,    390,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  1130,   190,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  1420,   110,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(1, 4),  1280,   620,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },

    {   math.random(7, 8),  540,    190,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  510,    190,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  570,    190,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  710,    320,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  710,    350,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  710,    380,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true,   true,   1,   true,  0,  0,  0,  {} },

    {   math.random(9, 10),  146,236,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  65,76,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  47,343,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  175,635,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  153,737,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  572,638,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  736,694,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  556,250,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  618,99,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  934,425,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  916,538,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  981,652,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  921,688,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  912,355,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  995,234,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1123,253,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1182,153,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1292,48,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1458,103,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1418,178,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1428,271,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1345,573,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1486,643,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },
    {   math.random(9, 10),  1148,740,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 2/3,   true,  0,  0,  0,  {} },

    {   11,  840, 560,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 1/5,   true,  0,  0,  0,  {} },
    {   11,  720, 640,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false, false, 1/5,   true,  0,  0,  0,  {} },

    {   math.random(7, 8),  750,    535,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  800,    500,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  770,    610,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,   true,   1,   true,  0,  0,  0,  {} },
    {   math.random(7, 8),  880,    570,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,   true,   1,   true,  0,  0,  0,  {} },

    {   12,  800, 600,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), true, true, 1,   true,  0,  0,  0,  {} },
}

this.missionLabel = "Trouver et détruire les tanks ennemis"
this.missiontime = 3

function this.update(dt, mouse)
    if this.missiontime >= 0 then
        this.missiontime = this.missiontime - dt
    end
end

function this.draw()
    if this.missiontime >= 0 then

        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() / 2 - 100, love.graphics.getWidth(), 200)
        love.graphics.setColor(255, 255, 255)

        love.graphics.setFont(modules.mainMenu.fonts.mainTitle)
        local font = love.graphics.getFont()
        local score = this.missionLabel
        local largeur_score = font:getWidth(score)
        love.graphics.print(score, (love.graphics.getWidth() - font:getWidth(score)) / 2, (love.graphics.getHeight() - font:getHeight(score)) / 2)
    end
end

function this.keypressed(key, scancode, isrepeat)
    if key == "space" then
        showHitBox = not showHitBox
    end
    if key == "p" then
        pause = not pause
    end
end

return this