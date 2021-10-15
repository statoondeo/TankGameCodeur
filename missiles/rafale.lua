function createRafaleMissile(myGame, myTank, baseMissileFactory)
    local missileConstants = require("missiles/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local myMissile = baseMissileFactory(myGame, myTank)

    myMissile.image = myMissile.game.resources.images.missiles[2]
    myMissile.explosionZoom = missileConstants.rafale.explosionZoom
    myMissile.step = 0    
    myMissile.initialTtl = missileConstants.rafale.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.easing = missileConstants.rafale.easing
    myMissile.scope = missileConstants.rafale.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.fireTtl = 0
    myMissile.octave = 1
    myMissile.reload = missileConstants.rafale.reload
    myMissile.fireIndex = 0
    myMissile.lastShot = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.fireImages[1] = myMissile.game.resources.images.fires[1]
    myMissile.fireImages[2] = myMissile.game.resources.images.fires[3]
    myMissile.fireImages[3] = myMissile.fireImages[1]
    myMissile.fireSpeed = missileConstants.rafale.fire.speed
    myMissile.fireZoom = missileConstants.rafale.fire.zoom 
    myMissile.fireSoundStarted = false
    myMissile.damage = {}
    myMissile.damage.missile = missileConstants.rafale.damage.missile
    myMissile.damage.explosion = missileConstants.rafale.damage.explosion
    myMissile.explosionHitbox = createHitbox(hitboxConstants.circleType)
    myMissile.explosionHitbox.radius = missileConstants.rafale.explosionZoom * myMissile.game.resources.images.missiles[1]:getWidth()
    myMissile.amplitudeShake = missileConstants.rafale.shake.amplitude
    myMissile.timeShake = missileConstants.rafale.shake.time

    myMissile.createChild = function (index)
        -- Création et initialisation du nouveau missile
        local newMissile = createMissile(myMissile.game, myMissile.tank, missileConstants.rafale.childMode)

        newMissile.scope = love.math.random(missileConstants.rafale.childMinScope, missileConstants.rafale.childMaxScope)
        newMissile.initialTtl = newMissile.scope / missileConstants.rafale.maxScope * newMissile.initialTtl
        newMissile.ttl = newMissile.initialTtl
        newMissile.angle = love.math.random(0, 2 * math.pi)
        newMissile.initialx = myMissile.x
        newMissile.initialy = myMissile.y
        newMissile.hitbox.x = newMissile.initialx
        newMissile.hitbox.y = newMissile.initialy
        newMissile.damage.missile = missileConstants.rafale.childDamage
        newMissile .damage.explosion = missileConstants.rafale.childDamage / 2
        newMissile.updateFireSound()
    end

    myMissile.initialUpdate = myMissile.update
    myMissile.update = function (dt)
        myMissile.initialUpdate(dt)
        if myMissile.exploded == false then
            myMissile.lastShot = myMissile.lastShot + dt
            if myMissile.lastShot >= missileConstants.rafale.nbStep then
                myMissile.lastShot = 0
                myMissile.step = myMissile.step + 1
                for i = 1, myMissile.step do
                    myMissile.createChild(myMissile.step)           
                end
            end
        end
    end

    myMissile.initialdraw = myMissile.draw    
    myMissile.draw = function ()
        myMissile.initialdraw()
    end

    return myMissile

end
