local this = {}

this.constantes = {}

this.constantes.skins = {}
this.constantes.skins.number = {}
this.constantes.skins.number.player = 3
this.constantes.skins.number.ennemy = 3
this.constantes.skins.number.total = 6
this.constantes.skins.playerRed = 2
this.constantes.skins.playerBlue = 3
this.constantes.skins.playerGreen = 4
this.constantes.skins.ennemySmall = 5
this.constantes.skins.ennemyMedium = 6
this.constantes.skins.ennemyLarge = 7

this.constantes.modes = {}
this.constantes.modes.player = 1
this.constantes.modes.ennemy = 2

this.constantes.acceleration = 2
this.constantes.angleAcceleration = 2
this.constantes.defaultAcceleration = 2
this.constantes.maxSpeed = 1
this.constantes.maxSpeedEnnemy = 1
this.constantes.tailLife = 1
this.constantes.tailSpeed = 10
this.constantes.defaulRange = 30


this.constantes.turretAnchorOffset = {}
this.constantes.turretAnchorOffset.x = 5
this.constantes.turretAnchorOffset.y = 0

this.images = {}
this.images.tanks = {}

this.tanks = {}

-- Chargement du module
function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.skins.number.total do
        this.images.tanks[i] = love.graphics.newImage("images/tank_" .. i .. ".png")
    end
    this.images.trace = love.graphics.newImage("images/trace.png")
end

-- Factory à tank
function this.create(myTankMode, myTankSkin, x, y, angle)
    local myTank = {}
    myTank.mode = myTankMode
    myTank.missileModule = myTankSkin
    myTank.maxSpeedLimit = this.constantes.maxSpeed
    myTank.skin = myTankSkin
    myTank.imageTank = this.images.tanks[myTankSkin - 1]
    myTank.imageTrace = this.images.trace
    myTank.angle = angle
    myTank.initialx = x
    myTank.initialy = y
    myTank.x = myTank.initialx
    myTank.y = myTank.initialy
    myTank.center = {}
    myTank.center.x = myTank.imageTank:getWidth() / 2
    myTank.center.y = myTank.imageTank:getHeight() / 2
    myTank.speed = 0
    myTank.maxSpeed = myTank.maxSpeedLimit
    myTank.acceleration = this.constantes.acceleration
    myTank.vector = {}
    myTank.vector.x = 0
    myTank.vector.y = 0
    myTank.lastShot = 0
    myTank.turretAnchor = {}
    myTank.turretAnchor.x = myTank.x + this.constantes.turretAnchorOffset.x
    myTank.turretAnchor.y = myTank.y
    myTank.tailFrame = 0
    myTank.tails = {}
    myTank.hitBox = modules.hitbox.create(modules.hitbox.constantes.circleType)
    myTank.hitBox.x = myTank.x
    myTank.hitBox.y = myTank.y
    myTank.hitBox.radius = myTank.imageTank:getWidth() / 2
    myTank.turret = modules.turret.create(myTankSkin - 1, myTank)
    myTank.isFired = false
    return myTank
end

function this.updateMove(dt, myTank)
   -- Gestion de la poussée
   if love.keyboard.isDown("up") then
        myTank.speed = myTank.speed + myTank.acceleration * dt
        if myTank.speed >= myTank.maxSpeed then
            myTank.speed = myTank.maxSpeed
        end
    else
        if love.keyboard.isDown("down") then
            myTank.speed = myTank.speed - myTank.acceleration
            if myTank.speed <= -this.constantes.maxSpeed then
                myTank.speed = -this.constantes.maxSpeed
            end
        else
            -- Si on n'accélère pas, le tank ralenti de lui-même
            if myTank.speed <= 0 then
                myTank.speed = myTank.speed + this.constantes.defaultAcceleration * dt
            else
                myTank.speed = myTank.speed - this.constantes.defaultAcceleration * dt
            end
        end
    end

    -- Modification de l'angle
    if love.keyboard.isDown("left") then
        myTank.angle = (myTank.angle - this.constantes.angleAcceleration * dt) % (2 * math.pi)
    end
    if love.keyboard.isDown("right") then
        myTank.angle = (myTank.angle + this.constantes.angleAcceleration * dt) % (2 * math.pi)
    end
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
    end
end

-- rafraichissement du tank
function this.updateTank(dt, myTank, mouse)   
    -- Mouvements du tank
    this.updateMove(dt, myTank)

    -- Mise à jour des informations
    this.updateData(dt, myTank)
    
    -- Mise à jour des traces
    this.updateTails(dt, myTank)
end

function this.update(dt)
    for i, myTank in ipairs(this.tanks) do
        this.updateTank(dt, myTank)
    end
end

-- Permet de sortir le tank d'un obstacle lors d'une collision
function this.rewind(myTank)
    myTank.x = myTank.x - myTank.vector.x
    myTank.y = myTank.y - myTank.vector.y
    myTank.hitBox.x = myTank.x
    myTank.hitBox.y = myTank.y
    return myTank.vector.x ~= 0 or myTank.vector.x ~= 0
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
        myTail.x + modules.battleground.offset.x, 
        myTail.y + modules.battleground.offset.y, 
        myTail.angle, 
        1, 
        1, 
        myTank.imageTrace:getWidth() / 2, 
        myTank.imageTrace:getHeight() / 2)
end

function this.draw() 
    for i, myTank in ipairs(this.tanks) do
        this.drawTank(myTank)
    end
end

function this.drawTank(myTank, myOffset, showHitBox)
    -- Affichage des traces du tank
    this.drawTails(myTank)

    -- Affichage du tank
    love.graphics.draw(
        myTank.imageTank, 
        myTank.x + modules.battleground.offset.x, 
        myTank.y + modules.battleground.offset.y, 
        myTank.angle, 
        1, 
        1, 
        myTank.center.x, myTank.center.y)
end

function this.fire(myTank)
    if myTank.lastShot <= 0 then
        local myMissile = modules.missile.create(myTank, myTank.missileModule)
        myTank.lastShot = myMissile.reload
    end
end

return this