function createReboundMissile(myGame, myTank, baseMissileFactory)
    local missileConstants = require("missiles/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local myMissile = baseMissileFactory(myGame, myTank)

    -- Initialisation spécifiques au type demandé
    myMissile.explosionZoom = missileConstants.rebound.explosionZoom
    myMissile.initialTtl = missileConstants.rebound.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = missileConstants.rebound.scope
    myMissile.easing = missileConstants.rebound.easing
    myMissile.image = myMissile.game.resources.images.missiles[3]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitbox.radius = myMissile.image:getWidth() / 2
    myMissile.isFired = true
    myMissile.tank.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireSoundStarted = false
    myMissile.octave = 0.5
    myMissile.reload = missileConstants.rebound.reload
    myMissile.fireImages = {}
    myMissile.fireImages[1] = myMissile.game.resources.images.fires[1]
    myMissile.fireImages[2] = myMissile.game.resources.images.fires[2]
    myMissile.fireImages[3] = myMissile.game.resources.images.fires[3]
    myMissile.fireImages[4] = myMissile.game.resources.images.fires[4]
    myMissile.fireImages[5] = myMissile.fireImages[4]
    myMissile.fireImages[6] = myMissile.fireImages[3]
    myMissile.fireImages[7] = myMissile.fireImages[2]
    myMissile.fireImages[8] = myMissile.fireImages[1]
    myMissile.fireSpeed = missileConstants.rebound.fire.speed
    myMissile.fireZoom = missileConstants.rebound.fire.zoom 
    myMissile.rocketImage = myMissile.game.resources.images.fires[1]
    myMissile.damage = {}
    myMissile.damage.missile = missileConstants.rebound.damage.missile
    myMissile.damage.explosion = missileConstants.rebound.damage.explosion
    myMissile.explosionHitbox = createHitbox(myMissile.game, hitboxConstants.circleType)
    myMissile.explosionHitbox.radius = missileConstants.rebound.explosionZoom * myMissile.game.resources.images.missiles[1]:getWidth()
    myMissile.amplitudeShake = missileConstants.rebound.shake.amplitude
    myMissile.timeShake = missileConstants.rebound.shake.time

    -- Génération de missile de replique du missile explosif
    myMissile.createChild = function (index)
        local newMissile = createMissile(myMissile.game, myMissile.tank, missileConstants.rebound.childMode)

        newMissile.scope = love.math.random(missileConstants.rebound.minScope, missileConstants.rebound.maxScope)
        newMissile.initialTtl = newMissile.scope / missileConstants.rebound.maxScope * newMissile.initialTtl
        newMissile.ttl = newMissile.initialTtl
        newMissile.angle = 2 * math.pi / missileConstants.rebound.number * index
        newMissile.initialx = myMissile.x
        newMissile.initialy = myMissile.y
        newMissile.hitbox.x = newMissile.initialx
        newMissile.hitbox.y = newMissile.initialy
        newMissile.damage.missile = missileConstants.rebound.childDamage
        newMissile.damage.explosion = missileConstants.rebound.childDamage / 2
    end


    myMissile.initialUpdate = myMissile.update
    myMissile.update = function (dt)
        myMissile.initialUpdate(dt)
        if myMissile.outDated == true then
            -- Le missile géant explose en plusieurs missiles standards après l'explosion classique
            for i = 1, missileConstants.rebound.number do
                
                -- Génération des missiles enfants
                myMissile.createChild(i)
            end
        end
    end

    myMissile.initialdraw = myMissile.draw    
    myMissile.draw = function ()
        myMissile.initialdraw()
        if myMissile.exploded == false then
            love.graphics.draw(
            myMissile.rocketImage, 
            math.floor(myMissile.x + myMissile.game.offset.x), 
            math.floor(myMissile.y + myMissile.game.offset.y), 
            myMissile.angle, 
            -1, 
            1, 
            0, 
            math.floor(myMissile.rocketImage:getHeight() / 2))
        end
    end

    return myMissile
end