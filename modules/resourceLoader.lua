function createResourceLoader()
    local gameConstants = require("modules/constants")
    local tankConstants = require("tanks/constants")
    local turretConstants = require("turrets/constants")
    local missileConstants = require("missiles/constants")
    local resourceLoader = {}
    -- Stockage des ressources
    resourceLoader.images = {}
    resourceLoader.images.tanks = {}
    resourceLoader.images.turrets = {}
    resourceLoader.images.missiles = {}
    resourceLoader.images.flames = {}
    resourceLoader.images.emotes = {}
    resourceLoader.images.explosions = {}
    resourceLoader.images.fires = {}
    resourceLoader.images.obstacles = {}
    resourceLoader.sounds = {}
    resourceLoader.musics = {}
    resourceLoader.fonts = {}

    resourceLoader.load = function()
        -- Chargement des ressources
        -- Images
        -- Tuiles
        resourceLoader.images.tiles = {}
        for i = 1, gameConstants.tilesNumber do
            resourceLoader.images.tiles[i] = love.graphics.newImage("images/tiles/" .. i .. ".png")
        end

        -- Médailles
        resourceLoader.images.medals = {}
        for i = 1, 3 do
            resourceLoader.images.medals[i] = love.graphics.newImage("images/medal_" .. i .. ".png")
        end

        -- Tanks
        for i = 1, tankConstants.base.skins.number.total do
            resourceLoader.images.tanks[i] = love.graphics.newImage("images/tank_" .. i .. ".png")
        end
        resourceLoader.images.tanks.trace = love.graphics.newImage("images/trace.png")

        -- Tourelles
        for i = 1, turretConstants.base.skins.count do
            resourceLoader.images.turrets[i] = love.graphics.newImage("images/turret_" .. i .. ".png")
        end 
        for i = 1, turretConstants.base.flames.count do
            resourceLoader.images.flames[i] = love.graphics.newImage("images/flame_" .. i .. ".png")
        end  
        for i = 1, turretConstants.base.emotes.count do
            resourceLoader.images.emotes[i] = love.graphics.newImage("images/emote_" .. i .. ".png")
        end  

        -- Missiles
        for i = 1, gameConstants.missile.frame do
            resourceLoader.images.missiles[i] = love.graphics.newImage("images/missile_" .. i .. ".png")
        end

        -- Explosion
        for i = 1, gameConstants.explosion.frame do
            resourceLoader.images.explosions[i] = love.graphics.newImage("images/explosion_" .. i .. ".png")
        end

        -- tirs
        for i = 1, gameConstants.missile.fire.frame do
            resourceLoader.images.fires[i] = love.graphics.newImage("images/shot_" .. i .. ".png")
        end

        -- Obstacles
        for i = 1, gameConstants.obstacle.nbObstacleResource do
            resourceLoader.images.obstacles[i] = love.graphics.newImage("images/obstacle_" .. i .. ".png")
        end

        -- Images diverses
        resourceLoader.images.background = love.graphics.newImage("images/Background.png")
        resourceLoader.images.bandeau = love.graphics.newImage("images/bandeau.png")
        resourceLoader.images.bonus = love.graphics.newImage("images/bonus_1.png")
        resourceLoader.images.cross = love.graphics.newImage("images/cross.png")
        resourceLoader.images.blood = love.graphics.newImage("images/blood.png")

        -- Curseurs
        resourceLoader.images.cursor = love.mouse.newCursor("images/crosshair.png", 0, 0)

        -- Fonts
        resourceLoader.fonts.tiny = love.graphics.newFont("fonts/KenFutureNarrow.ttf", gameConstants.fonts.size.tiny)
        resourceLoader.fonts.small = love.graphics.newFont("fonts/KenFutureNarrow.ttf", gameConstants.fonts.size.small)
        resourceLoader.fonts.medium = love.graphics.newFont("fonts/KenFutureNarrow.ttf", gameConstants.fonts.size.medium)
        resourceLoader.fonts.large = love.graphics.newFont("fonts/KenFutureNarrow.ttf", gameConstants.fonts.size.large)
        resourceLoader.fonts.giant = love.graphics.newFont("fonts/KenFutureNarrow.ttf", gameConstants.fonts.size.giant)

        -- Effets sonores
        resourceLoader.sounds.validation = love.audio.newSource("sounds/confirmation_001.ogg", "static")
        resourceLoader.sounds.switch = love.audio.newSource("sounds/switch28.ogg", "static")
        resourceLoader.sounds.alert = love.audio.newSource("sounds/tindeck.mp3", "static")
        resourceLoader.sounds.explosion  = love.audio.newSource("sounds/explosion.mp3", "static")
        resourceLoader.sounds.shot = love.audio.newSource("sounds/shot.wav", "static")

        -- Musiques
        resourceLoader.musics.menu = love.audio.newSource("musics/bensound-epic.mp3", "stream")
        resourceLoader.musics.map1 = love.audio.newSource("musics/bensound-evolution.mp3", "stream")
        resourceLoader.musics.map2 = love.audio.newSource("musics/bensound-theduel.mp3", "stream")
        resourceLoader.musics.win = love.audio.newSource("musics/bensound-brazilsamba.mp3", "stream")
        resourceLoader.musics.loose = love.audio.newSource("musics/bensound-creepy.mp3", "stream")
    end

    return resourceLoader
end
