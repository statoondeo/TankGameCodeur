local this = {}

this.constantes = {}
this.constantes.detectionRange = 200
this.constantes.arcSpeed = 1
this.constantes.sentinel = {}
this.constantes.sentinel.mode = 1
this.constantes.sentinel.minSpeed = -1
this.constantes.sentinel.maxSpeed = 1
this.constantes.sentinel.color = { 173, 255, 47 }
this.constantes.alert = {}
this.constantes.alert.mode = 2
this.constantes.alert.color = { 255, 165, 0 }
this.constantes.attack = {}
this.constantes.attack.mode = 3
this.constantes.attack.ttl = 5
this.constantes.attack.color = { 139, 0, 0 }
this.constantes.dead = {}
this.constantes.dead.mode = 0
this.constantes.amplitude = {}
this.constantes.amplitude.min = math.pi / 12
this.constantes.amplitude.max = 2 * math.pi / 5

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    local newTurret = game.turret.createNew(myTurretSkin, myTank)
    newTurret.module = this
    newTurret.arc = {}
    newTurret.speed = love.math.random() * 0.8 + 0.4
    newTurret.state = this.constantes.sentinel.mode
    newTurret.angle = 0
    newTurret.stateTtl = 0
    newTurret.arc.amplitude = this.constantes.amplitude.max    
    newTurret.arc.speed = this.constantes.arcSpeed
    this.initStateData(0, newTurret)
    return newTurret
end

function this.initStateData(dt, myTurret)
    myTurret.arc.x =  myTurret.output.x
    myTurret.arc.y =  myTurret.output.y
    if myTurret.state == this.constantes.sentinel.mode then
        -- La tourelle fait la sentinelle
        myTurret.arc.angle = myTurret.angle
        myTurret.arc.color = this.constantes.sentinel.color
        myTurret.arc.radius = this.constantes.detectionRange
        myTurret.emote = game.images.emotes[1]

    elseif myTurret.state == this.constantes.alert.mode then
        -- La tourelle est en alerte
        myTurret.angle = math.atan2(myTurret.tank.enemy.y - myTurret.y, myTurret.tank.enemy.x - myTurret.x)
        myTurret.arc.color= this.constantes.alert.color
        myTurret.arc.radius = this.constantes.detectionRange
        myTurret.emote = game.images.emotes[2]

    elseif myTurret.state == this.constantes.attack.mode then
        -- La tourelle attaque
        myTurret.angle = math.atan2(myTurret.tank.enemy.y - myTurret.y, myTurret.tank.enemy.x - myTurret.x)
        myTurret.arc.color = this.constantes.attack.color
        myTurret.arc.radius = this.constantes.detectionRange
        myTurret.emote = game.images.emotes[3]

    end
end

function this.Damage(myTurret, damages)
    myTurret.state = this.constantes.attack.mode
end

function this.actionStateData(dt, myTurret)
    myTurret.arc.amplitude = myTurret.arc.amplitude + myTurret.arc.speed * dt
    if myTurret.arc.amplitude  >= this.constantes.amplitude.max then
        myTurret.arc.amplitude = this.constantes.amplitude.max
        myTurret.arc.speed = 0
    elseif myTurret.arc.amplitude  <= this.constantes.amplitude.min then
        myTurret.arc.amplitude = this.constantes.amplitude.min
        myTurret.arc.speed = 0
    end

    if myTurret.state == this.constantes.sentinel.mode then
        -- La tourelle fait la sentinelle
        myTurret.angle = (myTurret.angle + myTurret.speed * dt) % (2 * math.pi)
        -- On check si le tank allié est détecté
        if game.hitbox.IsCircleInArc(game.playerTank.hitBox, myTurret.arc) == true then
            myTurret.state = this.constantes.alert.mode
            game.sounds.alert:stop()
            game.sounds.alert:setPitch(1)
            game.sounds.alert:play()
            myTurret.arc.speed = -this.constantes.arcSpeed
        end

    elseif myTurret.state == this.constantes.alert.mode then

        if game.hitbox.IsCircleInArc(game.playerTank.hitBox, myTurret.arc) == true then
            myTurret.arc.speed = -this.constantes.arcSpeed
        else
            myTurret.state = this.constantes.sentinel.mode
            game.sounds.alert:stop()
            game.sounds.alert:setPitch(0.75)
            game.sounds.alert:play()
            myTurret.arc.speed = this.constantes.arcSpeed
        end                        
            
        if myTurret.arc.amplitude >= this.constantes.amplitude.max then
            myTurret.state = this.constantes.sentinel.mode
        elseif myTurret.arc.amplitude <= this.constantes.amplitude.min then
            myTurret.state = this.constantes.attack.mode
            game.sounds.alert:stop()
            game.sounds.alert:setPitch(1.25)
            game.sounds.alert:play()
            myTurret.stateTtl = this.constantes.attack.ttl
        end

    elseif myTurret.state == this.constantes.attack.mode then
        -- La tourelle attaque
        game.tank.fire(myTurret.tank)

        myTurret.stateTtl = myTurret.stateTtl - dt
        if myTurret.stateTtl <= 0 then
            -- On checke si le joueur est toujours ici
            if game.hitbox.IsCircleInArc(game.playerTank.hitBox, myTurret.arc) == true then
                myTurret.stateTtl = this.constantes.attack.ttl
            else
                myTurret.state = this.constantes.alert.mode 
                myTurret.arc.speed = this.constantes.arcSpeed
            end            
        end

    elseif myTurret.state == this.constantes.dead.mode then
        -- La tourelle flambe ...

    end
end

-- Comportement spécifique
function this.updateTurret(dt, myTurret, mouse)
    if myTurret.tank.outDated == true then
        myTurret.state = this.constantes.dead.mode
    end
    -- Comportement suivant l'état
    this.initStateData(dt, myTurret)
    this.actionStateData(dt, myTurret)
end

-- Draw spécifique
function this.drawTurret(myTurret)
    if myTurret.state ~= this.constantes.dead.mode then
        love.graphics.setColor(myTurret.arc.color[1]/255, myTurret.arc.color[2]/255, myTurret.arc.color[3]/255, 0.25)
        love.graphics.arc(
            "fill", 
            math.floor(myTurret.output.x + game.offset.x), 
            math.floor(myTurret.output.y + game.offset.y), 
            myTurret.arc.radius, 
            myTurret.angle - myTurret.arc.amplitude, 
            myTurret.angle + myTurret.arc.amplitude)
        love.graphics.setColor(255, 255, 255)

        love.graphics.draw(
            myTurret.emote, 
            math.floor(myTurret.tank.x + game.offset.x), 
            math.floor(myTurret.tank.y - 2 * myTurret.tank.center.y + game.offset.y), 
            0, 
            1, 
            1, 
            math.floor(myTurret.emote:getWidth() / 2), 
            math.floor(myTurret.emote:getHeight() / 2))
    end
end

return this