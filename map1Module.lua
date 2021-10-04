local this = {}

this.constantes = {}

this.constantes.tiles = {}
this.constantes.tiles.size = {}
this.constantes.tiles.size.x = 64
this.constantes.tiles.size.y = 64
this.constantes.tiles.number = {}
this.constantes.tiles.number.x = 16
this.constantes.tiles.number.y = 12

this.tiles = 
{
   26, 25, 26, 25, 26, 25, 26, 21, 39, 40, 39, 40, 39, 40, 39, 40,
   25,  2,  7,  7,  1, 25, 26, 21, 39, 40, 39, 40, 39, 40, 39, 39,
   26,  8, 26, 25,  8, 26, 25, 21, 28, 33, 33, 33, 33, 33, 27, 40,
   25,  8, 25, 26,  8, 25, 26, 21, 34, 40, 39, 40, 39, 40, 34, 40,
   26,  4,  7,  7,  6,  7,  7, 13, 31, 33, 27, 39, 40, 39, 34, 39,
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
    95, 180, math.pi / 2
}

-- Liste des ennemis
this.ennemis = 
{
    --{ 4, 815, 605, 3 * math.pi / 2 }
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
    {   7,  710,    610,    math.prandom(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
    {   7,  930,    570,    math.prandom(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
    {   8,  780,    130,    math.prandom(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
    {   8,  780,    160,    math.prandom(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
    {   8,  780,    190,    math.prandom(0, 2 * math.pi),   1,                      false,  true,  1, true,  0,  0,  0,  {} },
    {   9,  50,     550,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {   9,  320,    500,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {   9,  260,    110,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {   9,  560,    270,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {   9,  630,    71,     math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  50,     100,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  90,     90,     math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  180,    680,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  190,    460,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  220,    180,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  410,    430,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  440,    240,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  440,    460,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  10,  630,    430,    math.prandom(0, 2 * math.pi),   math.prandom(0.8, 1.2), false,  false,  2/3, true,  0,  0,  0,  {} },
    {  11,  800,    250,    math.prandom(0, 2 * math.pi),   math.prandom(1, 1.5), false,  false,  1/5, true,  0,  0,  0,  {} },
    -- Arbres du décor
    {   1,  630,    250,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   1,  350,    420,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   2,  790,    450,    math.prandom(0, 2 * math.pi),   math.prandom(0.6, 1.4), true,   true,   1,   true,  0,  0,  0,  {} },
    {   4,  155,    190,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   4,  390,    210,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   4,  600,    450,    math.prandom(0, 2 * math.pi),   math.prandom(0.5, 1.5), true,   true,   1,   true,  0,  0,  0,  {} },
    {   3,  220,    250,    math.prandom(0, 2 * math.pi),   math.prandom(0.6, 1.4), true,   true,   1,   true,  0,  0,  0,  {} },
    {   3,  70,     430,    math.prandom(0, 2 * math.pi),   math.prandom(0.6, 1.4), true,   true,   1,   true,  0,  0,  0,  {} },
    {   3,  430,    630,    math.prandom(0, 2 * math.pi),   math.prandom(0.6, 1.4), true,   true,   1,   true,  0,  0,  0,  {} },
    -- Zones du terrain avec modificateur de vitesse
    {  0,   122,    122,    0, 1,     false,  false,  9/10, false, 0,  140,  140,  {} },
    {  0,   0,      0,      0, 1,     false,  false,  9/10, false, 0,  480,  70,  {} },
    {  0,   0,      70,     0, 1,     false,  false,  9/10, false, 0,  70,  245,  {} },
    {  0,   0,      315,    0, 1,     false,  false,  9/10, false, 0,  260,  460,  {} },
    {  0,   315,    70,     0, 1,     false,  false,  9/10, false, 0,  165,  190,  {} },
    {  0,   315,    315,    0, 1,     false,  false,  9/10, false, 0,  165,  330,  {} },
    {  0,   260,    700,    0, 1,     false,  false,  9/10, false, 0,  220,  70,  {} },
    {  0,   480,    0,      0, 1,     false,  false,  8/10, false, 0,  550,  135,  {} },
    {  0,   480,    135,    0, 1,     false,  false,  8/10, false, 0,  40,  125,  {} },
    {  0,   480,    315,    0, 1,     false,  false,  8/10, false, 0,  40,  330,  {} },
    {  0,   480,    700,    0, 1,     false,  false,  8/10, false, 0,  550,  70,  {} },
    {  0,   695,    632,    0, 1,     false,  false,  8/10, false, 0,  330,  68,  {} },
    {  0,   568,    313,    0, 1,     false,  false,  8/10, false, 0,  80,  333,  {} },
    {  0,   568,    183,    0, 1,     false,  false,  8/10, false, 0,  127,  80,  {} },
    {  0,   695,    183,    0, 1,     false,  false,  8/10, false, 0,  210,  402,  {} },
    {  0,   950,    135,    0, 1,     false,  false,  8/10, false, 0,  75,  497,  {} },
    -- Bornes de l'écran pour éviter que le tank ou les missiles ne sortent
    {  0,   -100,   -100,   0,                              1,  true,   true,   1,    false, 0,  love.graphics:getWidth() + 200,  100,  { 1, 4 } },
    {  0,   -100,   0,      0,                              1,  true,   true,   1,    false, 0,  100,  love.graphics:getHeight(),  { 1, 4 } },
    {  0,   -100,   love.graphics:getHeight(),   0,         1,  true,   true,   1,    false, 0,  love.graphics:getWidth() + 200,  100,  { 1, 4 } },
    {  0,   love.graphics:getWidth(),   0,      0,          1,  true,   true,   1,    false, 0,  100,  love.graphics:getHeight(),  { 1, 4 } }
}

function this.init()
end

function this.update(dt, mouse)
end

function this.draw()
end

function this.mousepressed(x, y, button, istouch, presses)  
    modules.tank.fire(modules.battleground.playerTank)
end

function this.keypressed(key, scancode, isrepeat)
    -- if key == "space" then
    --     showHitBox = not showHitBox
    -- end
    -- if key == "p" then
    --     pause = not pause
    -- end
end

return this