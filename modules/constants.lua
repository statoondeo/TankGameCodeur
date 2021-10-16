local this = {}

this.tilesNumber = 40
this.modes = {}
this.modes.init = 1
this.modes.quit = 2
this.modes.game = 3
this.modes.initpause = 4
this.modes.pause = 5
this.modes.quitpause = 6
this.modes.initMessage = 7
this.modes.message = 8
this.modes.quitMessage = 9
this.modes.initGameEnd = 10
this.modes.gameEnd = 11
this.modes.ttl = 0.5
this.modes.messageTtl = 2

-- Obstacles
this.obstacle = {}
this.obstacle.nbObstacleResource = 12

this.fonts = {}
this.fonts.size = {}
this.fonts.size.tiny = 9
this.fonts.size.small = 18
this.fonts.size.medium = 36
this.fonts.size.large = 72
this.fonts.size.giant = 108

this.tiles = {}
this.tiles.size = {}
this.tiles.size.x = 64
this.tiles.size.y = 64

-- Directions proposées par les tuiles
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

-- Modificateurs de mouvement des tuiles
this.tileModifiers = 
{
    { 13, 95 / 100 },
    { 14, 95 / 100 },
    { 15, 95 / 100 },
    { 16, 95 / 100 },
    { 17, 95 / 100 },
    { 18, 95 / 100 },
    { 19, 95 / 100 },
    { 20, 95 / 100 },
    { 21, 85 / 100 },
    { 22, 85 / 100 },
    { 23, 85 / 100 },
    { 24, 85 / 100 },
    { 25, 90 / 100 },
    { 26, 90 / 100 },
    { 27, 95 / 100 },
    { 28, 95 / 100 },
    { 29, 95 / 100 },
    { 30, 95 / 100 },
    { 31, 95 / 100 },
    { 32, 95 / 100 },
    { 33, 95 / 100 },
    { 34, 95 / 100 },
    { 35, 95 / 100 },
    { 36, 95 / 100 },
    { 37, 95 / 100 },
    { 38, 95 / 100 },
    { 39, 80 / 100 },
    { 40, 80 / 100 },
}

return this