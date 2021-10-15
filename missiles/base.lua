require("missiles/mini")
require("missiles/gun")
require("missiles/rafale")
require("missiles/rebound")

-- Création d'un missile
function createBaseMissile(myGame, myTank)
    local hitboxConstants = require("modules/hitboxConstants")
    local gameConstants = require("modules/constants")
    local myMissile = {}
    myMissile.game = myGame    
    myMissile.baseMissileFactory = createBaseMissile    
    myMissile.tank = myTank
    myMissile.angle = myMissile.tank.turret.angle
    myMissile.initialx = myMissile.tank.turret.output.x
    myMissile.initialy = myMissile.tank.turret.output.y
    myMissile.x = myMissile.initialx
    myMissile.y = myMissile.initialy
    myMissile.exploded = false
    myMissile.explosionTimeLife = 0
    myMissile.outDated = false
    myMissile.hitbox = createHitbox(hitboxConstants.circleType)
    myMissile.hitbox.x = myMissile.x
    myMissile.hitbox.y = myMissile.y
    myMissile.ExplosionSoundStarted = false   
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.explosionImageIndex = 0
    myMissile.explosionDamageDone = false


    myMissile.updateFireSound = function (dt)
        -- Son d'explosion du missile si pas encore fait
        myMissile.game.resources.sounds.shots[1]:stop()
        myMissile.game.resources.sounds.shots[1]:setPitch(myMissile.octave)
        myMissile.game.resources.sounds.shots[1]:play()
        myMissile.fireSoundStarted = true
    end

    myMissile.updateExplosionSound = function (dt)
        -- Son d'explosion du missile si pas encore fait
        myMissile.game.resources.sounds.explosion:stop()
        myMissile.game.resources.sounds.explosion:setPitch(myMissile.octave)
        myMissile.game.resources.sounds.explosion:play()
        myMissile.ExplosionSoundStarted = true
    end

    -- Update des missiles
    myMissile.update = function (dt)
        if myMissile.exploded == true then
            myMissile.updateExplosion(dt)
        else
            myMissile.updateFire(dt)
            myMissile.updateMovingMissile(dt)
        end
    end

    myMissile.updateMovingMissile = function (dt)
        -- Mouvement du missile
        myMissile.ttl = myMissile.ttl - dt

        if (myMissile.ttl <= 0) then
            -- Un missile en bout de course explose
            myMissile.exploded = true
        else
            -- Déplacement du missile
            local easingFactor = myMissile.easing((myMissile.initialTtl - myMissile.ttl) / myMissile.initialTtl)
            myMissile.x = myMissile.initialx + myMissile.scope * math.cos(myMissile.angle) * easingFactor
            myMissile.y = myMissile.initialy + myMissile.scope * math.sin(myMissile.angle) * easingFactor
            
            -- On accorde les hitbox
            myMissile.hitbox.x = myMissile.x
            myMissile.hitbox.y = myMissile.y
        end
    end

    myMissile.updateFireSound = function (dt)
        -- Son d'explosion du missile si pas encore fait
        myMissile.game.resources.sounds.shot:stop()
        myMissile.game.resources.sounds.shot:setPitch(myMissile.octave)
        myMissile.game.resources.sounds.shot:play()
        myMissile.fireSoundStarted = true
    end

    myMissile.updateFire = function (dt)
        if myMissile.isFired == true then
            -- Son de l'explosion
            if myMissile.fireSoundStarted == false then
                myMissile.updateFireSound(dt)
            end

            -- On avance dans l'animation du tir
            myMissile.fireTtl = myMissile.fireTtl + myMissile.fireSpeed * dt
            myMissile.fireIndex = math.floor(myMissile.fireTtl) + 1

            -- Est-ce que le tir doit disparaitre
            if myMissile.fireIndex > #myMissile.fireImages then
                myMissile.isFired = false
            else
                myMissile.fireImage = myMissile.fireImages[myMissile.fireIndex]
            end
        end
    end

    myMissile.updateExplosion = function (dt)
        -- Son de l'explosion
        if myMissile.ExplosionSoundStarted == false then
            myMissile.updateExplosionSound(dt)
        end

        -- On avance dans l'animation de l'explosion du missile
        myMissile.explosionTimeLife = myMissile.explosionTimeLife + gameConstants.explosion.speed * dt

        -- Est-ce que le missile doit disparaitre (animation d'explosion terminée)
        myMissile.explosionImageIndex = math.floor(myMissile.explosionTimeLife) + 1
        if myMissile.explosionImageIndex > #myMissile.game.resources.images.explosions then
            myMissile.outDated = true
        else
            if myMissile.hitbox.type ~= hitboxConstants.noneType then
                myMissile.explosionImage = myMissile.game.resources.images.explosions[myMissile.explosionImageIndex]
            end
        end
    end

    -- En cas de collision, on affiche le missile au point de contact
    myMissile.rewind = function ()
        -- On remonte dans le temps pour sortir des obstacles
        myMissile.ttl = myMissile.ttl + 0.1
        local easingFactor = myMissile.easing((myMissile.initialTtl - myMissile.ttl) / myMissile.initialTtl)
        myMissile.x = myMissile.initialx + myMissile.scope * math.cos(myMissile.angle) * easingFactor
        myMissile.y = myMissile.initialy + myMissile.scope * math.sin(myMissile.angle) * easingFactor
        return myMissile.ttl <= myMissile.initialTtl
    end

    -- Affichage de l'explosion
    myMissile.drawExplosion = function ()
        if myMissile.explosionImage ~= nil then
            love.graphics.draw(
                myMissile.explosionImage, 
                math.floor(myMissile.hitbox.x + myMissile.game.offset.x), 
                math.floor(myMissile.hitbox.y + myMissile.game.offset.y), 
                myMissile.angle, 
                myMissile.explosionZoom, 
                myMissile.explosionZoom, 
                math.floor(myMissile.explosionImage:getWidth() / 2), 
                math.floor(myMissile.explosionImage:getHeight() / 2))
        end
    end

    myMissile.drawActiveMissile = function ()
        -- Affichage du missile proprement dit
        if myMissile.hitbox.type ~= hitboxConstants.noneType then
            love.graphics.draw(
                myMissile.image, 
                math.floor(myMissile.x + myMissile.game.offset.x), 
                math.floor(myMissile.y + myMissile.game.offset.y), 
                myMissile.angle,
                1,
                1,
                math.floor(myMissile.center.x), 
                math.floor(myMissile.center.y))
        end
    end

    myMissile.drawFire = function ()
        if myMissile.fireImage ~= nil then
            love.graphics.draw(
                myMissile.fireImage, 
                math.floor(myMissile.tank.turret.output.x + myMissile.game.offset.x), 
                math.floor(myMissile.tank.turret.output.y + myMissile.game.offset.y), 
                myMissile.angle, 
                myMissile.fireZoom, 
                myMissile.fireZoom, 
                0, 
                math.floor(myMissile.fireImage:getHeight() / 2))
        end
    end

    -- Affichage d'un missile
    myMissile.draw = function ()
        if myMissile.exploded then
            myMissile.drawExplosion()
        else
            myMissile.drawActiveMissile()
            if myMissile.isFired == true then
                myMissile.drawFire()
            end
        end
    end

    table.insert(myMissile.game.missiles, myMissile)
    table.insert(myMissile.game.sprites, myMissile)
    
    return myMissile
end

-- Factory à missiles
function createMissile(myGame, myTank, myMissileMode)
    local missileConstants = require("missiles/constants")
    if myMissileMode == missileConstants.mini.mode then
        return createMiniMissile(myGame, myTank, createBaseMissile)
    elseif myMissileMode == missileConstants.gun.mode then
        return createGunMissile(myGame, myTank, createBaseMissile)
    elseif myMissileMode == missileConstants.rafale.mode then
        return createRafaleMissile(myGame, myTank, createBaseMissile)
    elseif myMissileMode == missileConstants.rebound.mode then
        return createReboundMissile(myGame, myTank, createBaseMissile)
    end
end