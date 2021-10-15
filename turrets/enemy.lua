-- Factory à tourelles
function createEnemyTurret(myGame, myTurretSkin, myTank)
    local turretConstants = require("turrets/constants")
    local newTurret = createBaseTurret(myGame, myTurretSkin, myTank)
    newTurret.arc = {}
    newTurret.speed = love.math.random() * 0.8 + 0.4
    newTurret.state = turretConstants.enemy.sentinel.mode
    newTurret.angle = 0
    newTurret.stateTtl = 0
    newTurret.arc.amplitude = turretConstants.enemy.amplitude.max    
    newTurret.arc.speed = turretConstants.enemy.arcSpeed

    newTurret.initSentinel = function(dt)
        -- La tourelle fait la sentinelle
        newTurret.arc.angle = newTurret.angle
        newTurret.arc.color = turretConstants.enemy.sentinel.color
        newTurret.arc.radius = turretConstants.enemy.detectionRange
        newTurret.emote = newTurret.game.resources.images.emotes[1]
    end

    newTurret.initAlert = function(dt)
        -- La tourelle est en alerte
        newTurret.angle = math.atan2(newTurret.tank.enemy.y - newTurret.y, newTurret.tank.enemy.x - newTurret.x)
        newTurret.arc.color= turretConstants.enemy.alert.color
        newTurret.arc.radius = turretConstants.enemy.detectionRange
        newTurret.emote = newTurret.game.resources.images.emotes[2]
    end

    newTurret.initAttack = function(dt)
        -- La tourelle attaque
        newTurret.angle = math.atan2(newTurret.tank.enemy.y - newTurret.y, newTurret.tank.enemy.x - newTurret.x)
        newTurret.arc.color = turretConstants.enemy.attack.color
        newTurret.arc.radius = turretConstants.enemy.detectionRange
        newTurret.emote = newTurret.game.resources.images.emotes[3]
    end

    newTurret.initState = function (dt)
        newTurret.arc.x =  newTurret.output.x
        newTurret.arc.y =  newTurret.output.y

        if newTurret.state == turretConstants.enemy.sentinel.mode then
            newTurret.initSentinel(dt)
    
        elseif newTurret.state == turretConstants.enemy.alert.mode then
            newTurret.initAlert(dt)
    
        elseif newTurret.state == turretConstants.enemy.attack.mode then
            newTurret.initAttack(dt)
    
        end
    end

    newTurret.executeSentinel = function (dt)
        -- La tourelle fait la sentinelle
        newTurret.angle = (newTurret.angle + newTurret.speed * dt) % (2 * math.pi)
        -- On check si le tank allié est détecté
        if newTurret.game.playerTank.hitbox.IsCircleInArc(newTurret.arc) == true then
            newTurret.state = turretConstants.enemy.alert.mode
            newTurret.game.resources.sounds.alert:stop()
            newTurret.game.resources.sounds.alert:setPitch(1)
            newTurret.game.resources.sounds.alert:play()
            newTurret.arc.speed = -turretConstants.enemy.arcSpeed
        end
    end

    newTurret.executeAlert = function (dt)
        if newTurret.game.playerTank.hitbox.IsCircleInArc(newTurret.arc) == true then
            newTurret.arc.speed = -turretConstants.enemy.arcSpeed
        else
            newTurret.state = turretConstants.enemy.sentinel.mode
            newTurret.game.resources.sounds.alert:stop()
            newTurret.game.resources.sounds.alert:setPitch(0.75)
            newTurret.game.resources.sounds.alert:play()
            newTurret.arc.speed = turretConstants.enemy.arcSpeed
        end                        
            
        if newTurret.arc.amplitude >= turretConstants.enemy.amplitude.max then
            newTurret.state = turretConstants.enemy.sentinel.mode
        elseif newTurret.arc.amplitude <= turretConstants.enemy.amplitude.min then
            newTurret.state = turretConstants.enemy.attack.mode
            newTurret.game.resources.sounds.alert:stop()
            newTurret.game.resources.sounds.alert:setPitch(1.25)
            newTurret.game.resources.sounds.alert:play()
            newTurret.stateTtl = turretConstants.enemy.attack.ttl
        end
    end

    newTurret.executeAttack = function (dt)
        -- La tourelle attaque
        newTurret.tank.fire()

        newTurret.stateTtl = newTurret.stateTtl - dt
        if newTurret.stateTtl <= 0 then
            -- On checke si le joueur est toujours ici
            if newTurret.game.hitbox.IsCircleInArc(newTurret.game.playerTank.hitbox, newTurret.arc) == true then
                newTurret.stateTtl = turretConstants.enemy.attack.ttl
            else
                newTurret.state = turretConstants.enemy.alert.mode 
                newTurret.arc.speed = turretConstants.enemy.arcSpeed
            end            
        end
    end

    newTurret.executeState = function (dt)
        newTurret.arc.amplitude = newTurret.arc.amplitude + newTurret.arc.speed * dt
        if newTurret.arc.amplitude  >= turretConstants.enemy.amplitude.max then
            newTurret.arc.amplitude = turretConstants.enemy.amplitude.max
            newTurret.arc.speed = 0
        elseif newTurret.arc.amplitude  <= turretConstants.enemy.amplitude.min then
            newTurret.arc.amplitude = turretConstants.enemy.amplitude.min
            newTurret.arc.speed = 0
        end
    
        if newTurret.state == turretConstants.enemy.sentinel.mode then
            newTurret.executeSentinel(dt)
    
        elseif newTurret.state == turretConstants.enemy.alert.mode then
            newTurret.executeAlert(dt)
    
        elseif newTurret.state == turretConstants.enemy.attack.mode then
            newTurret.executeAttack(dt)
    
        elseif newTurret.state == turretConstants.enemy.dead.mode then
            -- La tourelle flambe ...
    
        end
    end

    -- Comportement spécifique
    newTurret.initialDamage = newTurret.damage
    newTurret.damage = function (damages)
        newTurret.state = turretConstants.enemy.attack.mode
        newTurret.initialDamage()
    end

    -- Comportement spécifique
    newTurret.initialUpdate = newTurret.update
    newTurret.update = function (dt)
        newTurret.initialUpdate(dt)
        if newTurret.tank.outDated == true then
            newTurret.state = turretConstants.enemy.dead.mode
        end
        -- Comportement suivant l'état
        newTurret.initState(dt)
        newTurret.executeState(dt)
    end

    -- Draw spécifique
    newTurret.initialDraw = newTurret.draw
    newTurret.draw = function ()
        newTurret.initialDraw()
        if newTurret.state ~= turretConstants.enemy.dead.mode then
            -- Dessin de l'arc de détection
            love.graphics.setColor(newTurret.arc.color[1]/255, newTurret.arc.color[2]/255, newTurret.arc.color[3]/255, 0.25)
            love.graphics.arc(
                "fill", 
                math.floor(newTurret.output.x + newTurret.game.offset.x), 
                math.floor(newTurret.output.y + newTurret.game.offset.y), 
                newTurret.arc.radius, 
                newTurret.angle - newTurret.arc.amplitude, 
                newTurret.angle + newTurret.arc.amplitude)
            love.graphics.setColor(255, 255, 255)

            -- Dessin de l'émote indiquant le degré d'alerte
            love.graphics.draw(
                newTurret.emote, 
                math.floor(newTurret.tank.x + newTurret.game.offset.x), 
                math.floor(newTurret.tank.y - 2 * newTurret.tank.center.y + newTurret.game.offset.y), 
                0, 
                1, 
                1, 
                math.floor(newTurret.emote:getWidth() / 2), 
                math.floor(newTurret.emote:getHeight() / 2))
        end
    end

    newTurret.initState(0)

    return newTurret
end
