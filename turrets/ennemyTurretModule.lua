local this = {}

this.constantes = {}
this.constantes.detectionRange = 175
this.constantes.arcSpeed = 1
this.constantes.sentinel = {}
this.constantes.sentinel.mode = 1
this.constantes.sentinel.minSpeed = -1
this.constantes.sentinel.maxSpeed = 1
this.constantes.sentinel.color = { 0, 255, 0 }
this.constantes.alert = {}
this.constantes.alert.mode = 2
this.constantes.alert.color = { 255, 69, 0 }
this.constantes.attack = {}
this.constantes.attack.mode = 3
this.constantes.attack.color = { 255, 0, 0 }
this.constantes.dead = {}
this.constantes.dead.mode = 0

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    local newTurret = modules.turret.createNew(myTurretSkin, myTank)
    newTurret.module = this
    newTurret.arc = {}
    newTurret.speed = love.math.random() * 0.8 + 0.4
    newTurret.state = this.constantes.sentinel.mode
    newTurret.angle = 0
    newTurret.stateTtl = 0
    newTurret.arc.amplitude = math.pi / 3    
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
        myTurret.emote = modules.turret.images.emotes[1]

    elseif myTurret.state == this.constantes.alert.mode then
        -- La tourelle est en alerte
        myTurret.angle = math.atan2(myTurret.tank.enemy.y - myTurret.y, myTurret.tank.enemy.x - myTurret.x)
        myTurret.arc.color= this.constantes.alert.color
        myTurret.arc.radius = this.constantes.detectionRange
        myTurret.emote = modules.turret.images.emotes[2]

    elseif myTurret.state == this.constantes.attack.mode then
        -- La tourelle attaque
        myTurret.angle = math.atan2(myTurret.tank.enemy.y - myTurret.y, myTurret.tank.enemy.x - myTurret.x)
        myTurret.arc.color = this.constantes.attack.color
        myTurret.arc.radius = this.constantes.detectionRange
        myTurret.emote = modules.turret.images.emotes[3]

    end
end

function this.Damage(myTurret, damages)
    myTurret.state = this.constantes.alert.mode
end

function this.actionStateData(dt, myTurret)
    myTurret.arc.amplitude = myTurret.arc.amplitude + myTurret.arc.speed * dt
    if myTurret.arc.amplitude  >= math.pi / 3 then
        myTurret.arc.amplitude = math.pi / 3
        myTurret.arc.speed = 0
    elseif myTurret.arc.amplitude  <= math.pi / 12 then
        myTurret.arc.amplitude = math.pi / 12
        myTurret.arc.speed = 0
    end

    if myTurret.state == this.constantes.sentinel.mode then
        -- La tourelle fait la sentinelle
        myTurret.angle = (myTurret.angle + myTurret.speed * dt) % (2 * math.pi)
        -- On check si le tank allié est détecté
        if modules.hitbox.IsCircleInArc(modules.game.playerTank.hitBox, myTurret.arc) == true then
            myTurret.state = this.constantes.alert.mode
            myTurret.arc.speed = -this.constantes.arcSpeed
        end

    elseif myTurret.state == this.constantes.alert.mode then

        if modules.hitbox.IsCircleInArc(modules.game.playerTank.hitBox, myTurret.arc) == true then
            myTurret.arc.speed = -this.constantes.arcSpeed
        else
            myTurret.state = this.constantes.sentinel.mode
            myTurret.arc.speed = this.constantes.arcSpeed
        end                        
            
        if myTurret.arc.amplitude  >= math.pi / 3 then
            myTurret.state = this.constantes.sentinel.mode
        elseif myTurret.arc.amplitude  <= math.pi / 12 then
            myTurret.state = this.constantes.attack.mode
        end

    elseif myTurret.state == this.constantes.attack.mode then
        -- On checke si le joueur est toujours ici
        if modules.hitbox.IsCircleInArc(modules.game.playerTank.hitBox, myTurret.arc) == true then
            -- La tourelle attaque
            modules.tank.fire(myTurret.tank)
        else
            myTurret.state = this.constantes.alert.mode 
            myTurret.arc.speed = this.constantes.arcSpeed
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
        love.graphics.setColor(myTurret.arc.color[1], myTurret.arc.color[2], myTurret.arc.color[3], 0.25)
        love.graphics.arc("fill", myTurret.output.x + modules.game.offset.x, myTurret.output.y + modules.game.offset.y, myTurret.arc.radius, myTurret.angle - myTurret.arc.amplitude, myTurret.angle + myTurret.arc.amplitude)
        love.graphics.setColor(255, 255, 255)

        love.graphics.draw(myTurret.emote, myTurret.tank.x + modules.game.offset.x, myTurret.tank.y - 2 * myTurret.tank.center.y + modules.game.offset.y, 0, 1, 1, myTurret.emote:getWidth() / 2, myTurret.emote:getHeight() / 2)
    end
end

return this