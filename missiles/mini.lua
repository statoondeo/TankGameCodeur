function createMiniMissile(myGame, myTank, baseMissileFactory)
    local missileConstants = require("missiles/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local myMissile = createBaseMissile(myGame, myTank)

    -- Initialisations spécifiques au type demandé
    myMissile.explosionZoom = missileConstants.mini.explosionZoom
    myMissile.initialTtl = missileConstants.mini.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = missileConstants.mini.scope
    myMissile.easing = missileConstants.mini.easing
    myMissile.image = myMissile.game.resources.images.missiles[1]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitbox.radius = myMissile.image:getWidth() / 2
    myMissile.fireSoundStarted = true
    myMissile.octave = 2
    myMissile.reload = missileConstants.mini.reload
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.damage = {}
    myMissile.damage.missile = missileConstants.mini.damage.missile
    myMissile.damage.explosion = missileConstants.mini.damage.explosion
    myMissile.explosionHitbox = createHitbox(myMissile.game, hitboxConstants.circleType)
    myMissile.explosionHitbox.radius = missileConstants.mini.explosionZoom * myMissile.game.resources.images.missiles[1]:getWidth()

    myMissile.initialUpdate = myMissile.update
    myMissile.update = function (dt)
        myMissile.initialUpdate(dt)

    end

    myMissile.initialDraw = myMissile.draw
    myMissile.draw = function ()
        myMissile.initialDraw()
    end

    return myMissile
end
