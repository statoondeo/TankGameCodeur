local this = {}

this.constantes = {}

this.constantes.acceleration = 2
this.constantes.angleAcceleration = 2
this.constantes.defaultAcceleration = 2
this.constantes.maxSpeed = 1
this.constantes.maxSpeedEnnemy = 1
this.constantes.tailLife = 1
this.constantes.tailSpeed = 10
this.constantes.lifeBarHeight = 6

this.constantes.turretAnchorOffset = {}
this.constantes.turretAnchorOffset.x = 5
this.constantes.turretAnchorOffset.y = 0

this.tanks = {}
this.tanksModules = {}
table.insert(this.tanksModules, require("tanks/allyTankModule"))
table.insert(this.tanksModules, require("tanks/ennemyTankModule"))

this.nextId = 1

-- Factory à tank
function this.create(myTankMode, myTankSkin, x, y, angle)
    return (this.tanksModules[myTankMode].create(myTankMode, myTankSkin, x, y, angle))
end

-- Factory à tank
function this.createNew(myTankMode, myTankSkin, x, y, angle)
    local myTank = {}
    myTank.id = this.nextId
    this.nextId = this.nextId + 1
    myTank.mode = myTankMode
    myTank.missileModule = myTankSkin
    myTank.maxSpeedLimit = this.constantes.maxSpeed
    myTank.skin = myTankSkin
    myTank.imageTank = game.images.tanks[myTankSkin - 1]
    myTank.imageTrace = game.images.tanks.trace
    myTank.angle = angle
    myTank.initialx = x
    myTank.initialy = y
    myTank.x = myTank.initialx
    myTank.y = myTank.initialy
    myTank.center = {}
    myTank.center.x = myTank.imageTank:getWidth() / 2
    myTank.center.y = myTank.imageTank:getHeight() / 2
    myTank.speed = 0
    myTank.vector = {}
    myTank.vector.x = 0
    myTank.vector.y = 0
    myTank.lastShot = 0
    myTank.turretAnchor = {}
    myTank.turretAnchor.x = myTank.x + this.constantes.turretAnchorOffset.x
    myTank.turretAnchor.y = myTank.y
    myTank.tailFrame = 0
    myTank.tails = {}
    myTank.hitBox = game.hitbox.create(game.hitbox.constantes.circleType)
    myTank.hitBox.x = myTank.x
    myTank.hitBox.y = myTank.y
    myTank.hitBox.radius = myTank.imageTank:getWidth() / 2
    myTank.turret = game.turret.create(myTankSkin - 1, myTank)
    myTank.isFired = false
    myTank.outDated = false
    myTank.drawLife = true
    return myTank
end

function this.Damage(myTank, damages)
    myTank.life = myTank.life - damages
    if myTank.life <= 0 then
        myTank.life = 0
        myTank.outDated = true
    end

    -- Spécificités du tank
    myTank.module.Damage(myTank, damages)
end

-- Gestion des traces
function this.updateTails(dt, myTank)
    for i = #myTank.tails, 1, -1 do
        local myTail = myTank.tails[i]
        myTail.ttl = myTail.ttl - dt
        if myTail.ttl <= 0 then
            table.remove(myTank.tails, i)
        end
    end

    if (myTank.tailFrame % this.constantes.tailSpeed) == 0 then
        local newTail = {}
        newTail.x = myTank.x
        newTail.y = myTank.y
        newTail.angle = myTank.angle
        newTail.ttl = this.constantes.tailLife
        table.insert(myTank.tails, newTail)
    end
    myTank.tailFrame = (myTank.tailFrame + 1) % 60
end

function this.UpdateTurretAnchor(dt, myTank)
    -- Le point d'ancrage de la tourelle a changé
    myTank.turretAnchor.x = myTank.x + math.cos(myTank.angle) * this.constantes.turretAnchorOffset.x
    myTank.turretAnchor.y = myTank.y + math.sin(myTank.angle) * this.constantes.turretAnchorOffset.y
end

-- Mise à jour des infos du tank
function this.updateData(dt, myTank)
    myTank.vector.x = math.cos(myTank.angle) * myTank.speed
    myTank.vector.y = math.sin(myTank.angle) * myTank.speed
    myTank.x = myTank.x + myTank.vector.x
    myTank.y = myTank.y + myTank.vector.y
    
    -- Modification de la hitBox
    myTank.hitBox.x = myTank.x
    myTank.hitBox.y = myTank.y

    -- Le point d'ancrage de la tourelle a changé
    this.UpdateTurretAnchor(dt, myTank)

    -- Temps de recharge des obus
    if myTank.lastShot >= 0 then
        myTank.lastShot = myTank.lastShot - dt
    else
        myTank.isFired = false
    end
end

-- rafraichissement du tank
function this.updateTank(dt, myTank, mouse)   
    if myTank.outDated == false then
        -- Mouvements du tank
        myTank.module.updateTank(dt, myTank)

        -- Mise à jour des informations
        this.updateData(dt, myTank)
        
        -- Mise à jour des traces
        this.updateTails(dt, myTank)
    end
end

function this.update(dt)
    for i, myTank in ipairs(this.tanks) do
        this.updateTank(dt, myTank)
    end
end

-- Permet de sortir le tank d'un obstacle lors d'une collision
function this.rewind(myTank)
    if myTank.outDated == false then
        myTank.x = myTank.x - myTank.vector.x
        myTank.y = myTank.y - myTank.vector.y
        myTank.hitBox.x = myTank.x
        myTank.hitBox.y = myTank.y
    end
    return myTank.vector.x ~= 0 or myTank.vector.x ~= 0
    -- return false
end

function this.drawTails(myTank)
    -- Affichage des traces du tank
    for i, myTail in ipairs(myTank.tails) do
        this.drawtail(myTank, myTail)
    end
    love.graphics.setColor(255, 255, 255)
end

function this.drawtail(myTank, myTail)
    love.graphics.setColor(255, 255, 255, myTail.ttl)
    love.graphics.draw(
        myTank.imageTrace, 
        math.floor(myTail.x + game.offset.x), 
        math.floor(myTail.y + game.offset.y), 
        myTail.angle, 
        1, 
        1, 
        math.floor(myTank.imageTrace:getWidth() / 2), 
        math.floor(myTank.imageTrace:getHeight() / 2))
end

function this.draw() 
    for i, myTank in ipairs(this.tanks) do
        this.drawTank(myTank)
    end
end

function this.drawTank(myTank)
    -- Affichage des traces du tank
    this.drawTails(myTank)

    -- Affichage du tank
    love.graphics.draw(
        myTank.imageTank, 
        math.floor(myTank.x + game.offset.x), 
        math.floor(myTank.y + game.offset.y), 
        myTank.angle, 
        1, 
        1, 
        math.floor(myTank.center.x), 
        math.floor(myTank.center.y))

    if myTank.drawLife == true then
        -- On dessine la barre de vie des tanks
        love.graphics.setColor(255, 0, 0)
        love .graphics.rectangle(
            "fill", 
            math.floor(myTank.x - myTank.center.x + game.offset.x), 
            math.floor(myTank.y - 1.5 * myTank.center.y + game.offset.y), 
            math.floor(2 * myTank.center.x), 
            this.constantes.lifeBarHeight)
        love.graphics.setColor(0, 255, 0)
        love .graphics.rectangle(
            "fill", 
            math.floor(myTank.x - myTank.center.x + game.offset.x), 
            math.floor(myTank.y - 1.5 * myTank.center.y + game.offset.y), 
            math.floor(2 * myTank.center.x * myTank.life / myTank.initialLife), 
            this.constantes.lifeBarHeight)
        love.graphics.setColor(255, 255, 255)
        love .graphics.rectangle(
            "line", 
            math.floor(myTank.x - myTank.center.x + game.offset.x), 
            math.floor(myTank.y - 1.5 * myTank.center.y + game.offset.y), 
            math.floor(2 * myTank.center.x), 
            this.constantes.lifeBarHeight)
    end

    -- Spécificités du tank
    myTank.module.drawTank(myTank)
end

function this.fire(myTank)
    if myTank.lastShot <= 0 then
        local myMissile = game.missile.create(myTank, myTank.missileModule)
        myTank.lastShot = myMissile.reload
        myTank.module.fire(myTank)
        myTank.isFired = true
        if myTank.mode == game.constantes.tank.modes.player then
            game.fireShake = true
            game.amplitudeShake = myMissile.amplitudeShake
            game.fireShakeTtl = myMissile.timeShake
        end
    end
end

return this