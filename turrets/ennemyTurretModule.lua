local this = {}

this.constantes = {}
this.constantes.detectionRange = 175
this.constantes.sentinel = {}
this.constantes.sentinel.mode = 1
this.constantes.sentinel.minSpeed = -1
this.constantes.sentinel.maxSpeed = 1
this.constantes.sentinel.color = { 0, 255, 0 }
this.constantes.attack = {}
this.constantes.attack.mode = 2
this.constantes.attack.ttl = 3
this.constantes.attack.color = { 255, 0, 0 }
this.constantes.dead = {}
this.constantes.dead.mode = 0

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    local newTurret = modules.turret.createNew(myTurretSkin, myTank)
    newTurret.module = this
    newTurret.arc = {}
    newTurret.speed = love.math.random() * 0.4 +0.8
    newTurret.state = this.constantes.sentinel.mode
    newTurret.angle = 0
    newTurret.stateTtl = 0
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
        myTurret.arc.amplitude = math.pi / 3
    elseif myTurret.state == this.constantes.attack.mode then
        -- La tourelle attaque
        myTurret.angle = math.atan2(myTurret.tank.enemy.y - myTurret.y, myTurret.tank.enemy.x - myTurret.x)
        -- local angle = math.atan2(myTurret.tank.enemy.y - myTurret.y, myTurret.tank.enemy.x - myTurret.x)
        -- if angle - myTurret.angle >= 0 then
        --     myTurret.angle = myTurret.angle - myTurret.speed * dt
        -- else
        --     myTurret.angle = myTurret.angle + myTurret.speed * dt
        -- end
        myTurret.arc.color = this.constantes.attack.color
        myTurret.arc.radius = this.constantes.detectionRange
        myTurret.arc.amplitude = math.pi / 12
    end
end

function this.Damage(myTurret, damages)
    myTurret.state = this.constantes.attack.mode
end

function this.actionStateData(dt, myTurret)
    if myTurret.state == this.constantes.sentinel.mode then
        -- La tourelle fait la sentinelle
        myTurret.angle = (myTurret.angle + myTurret.speed * dt) % (2 * math.pi)
        -- On check si le tyank allié est détecté
        if modules.hitbox.IsCircleInArc(modules.game.playerTank.hitBox, myTurret.arc) then
            myTurret.state = this.constantes.attack.mode
            myTurret.stateTtl = this.constantes.attack.ttl
        end

    elseif myTurret.state == this.constantes.attack.mode then
        -- La tourelle attaque
        modules.tank.fire(myTurret.tank)

        -- On checke si le joueur est toujours ici
        -- si ou on continue à shooter
        -- si non on arrete le tank et on repasse en sentinelle
        myTurret.stateTtl = myTurret.stateTtl - dt
        if myTurret.stateTtl <= 0 then

            if modules.hitbox.IsCircleInArc(modules.game.playerTank.hitBox, myTurret.arc) then
                myTurret.stateTtl = this.constantes.attack.ttl
            else
                myTurret.state = this.constantes.sentinel.mode 
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
        love.graphics.setColor(myTurret.arc.color[1], myTurret.arc.color[2], myTurret.arc.color[3], 0.25)
        love.graphics.arc("fill", myTurret.output.x + modules.game.offset.x, myTurret.output.y + modules.game.offset.y, myTurret.arc.radius, myTurret.angle - myTurret.arc.amplitude, myTurret.angle + myTurret.arc.amplitude)
        love.graphics.setColor(255, 255, 255)
    end
end

return this