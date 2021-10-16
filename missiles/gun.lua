function createGunMissile(myGame, myTank, baseMissileFactory)
    local missileConstants = require("missiles/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local myMissile = baseMissileFactory(myGame, myTank)

    -- Initialisations spécifiques au type demandé
    myMissile.step = 0    
    myMissile.initialTtl = missileConstants.gun.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.explosionZoom = missileConstants.gun.explosionZoom
    myMissile.image = myMissile.game.resources.images.missiles[1]
    myMissile.easing = missileConstants.gun.easing
    myMissile.scope = missileConstants.gun.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.step = 0
    myMissile.fireTtl = 0
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.fireImages[1] = myMissile.game.resources.images.fires[1]
    myMissile.fireImages[2] = myMissile.game.resources.images.fires[2]
    myMissile.fireImages[3] = myMissile.fireImages[1]
    myMissile.fireImages[4] = myMissile.fireImages[2]
    myMissile.fireImages[5] = myMissile.fireImages[1]
    myMissile.fireImages[6] = myMissile.fireImages[2]
    myMissile.fireImages[7] = myMissile.fireImages[1]
    myMissile.fireSpeed = missileConstants.gun.fire.speed
    myMissile.fireZoom = missileConstants.gun.fire.zoom 
    myMissile.fireSoundStarted = false
    myMissile.octave = 2
    myMissile.reload = missileConstants.gun.reload
    myMissile.damage = {}
    myMissile.damage.missile = missileConstants.gun.damage.missile
    myMissile.damage.explosion = missileConstants.gun.damage.explosion
    myMissile.explosionHitbox = createHitbox(myMissile.game, hitboxConstants.circleType)
    myMissile.explosionHitbox.radius = missileConstants.gun.explosionZoom * myMissile.game.resources.images.missiles[1]:getWidth()
    myMissile.amplitudeShake = missileConstants.gun.shake.amplitude
    myMissile.timeShake = missileConstants.gun.shake.time

    myMissile.createChild = function ()
        -- Création et initialisation du nouveau missile
        local newMissile = createMissile(myMissile.game, myMissile.tank, missileConstants.gun.childMode)

        -- Gestion du scope des obus de la rafale
        newMissile.scope = love.math.random(missileConstants.gun.minScope, missileConstants.gun.maxScope)

        -- Gestion du angle des obus de la rafale
        newMissile.angle = love.math.random(myMissile.angle - missileConstants.gun.angleAmplitude, myMissile.angle + missileConstants.gun.angleAmplitude)

        -- Gestion du ttl des obus de la rafale
        newMissile.initialTtl = newMissile.scope / missileConstants.gun.scope * missileConstants.gun.ttl
        newMissile.ttl = newMissile.initialTtl

        newMissile.updateFireSound()

        return newMissile
    end

    myMissile.initialUpdate = myMissile.update
    myMissile.update = function (dt)
        myMissile.initialUpdate(dt)
        myMissile.step = myMissile.step + 1
        if myMissile.step <= missileConstants.gun.nbChild then
            myMissile.createChild()
        end
    end

    myMissile.initialDraw = myMissile.draw
    myMissile.draw = function ()
        myMissile.initialDraw()
    end

    return myMissile
end