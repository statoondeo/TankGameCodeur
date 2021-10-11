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
this.constantes.lifeBarHeight = 6

this.constantes.turretAnchorOffset = {}
this.constantes.turretAnchorOffset.x = 5
this.constantes.turretAnchorOffset.y = 0

this.images = {}
this.images.tanks = {}

this.tanks = {}
this.tanksModules = {}

this.nextId = 1

-- Chargement du module
function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.skins.number.total do
        this.images.tanks[i] = love.graphics.newImage("images/tank_" .. i .. ".png")
    end
    this.images.trace = love.graphics.newImage("images/trace.png")

    -- Chargement des modules 
    table.insert(this.tanksModules, require("tanks/allyTankModule"))
    table.insert(this.tanksModules, require("tanks/ennemyTankModule"))
end

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
    myTank.x = myTank.x - myTank.vector.x
    myTank.y = myTank.y - myTank.vector.y
    myTank.hitBox.x = myTank.x
    myTank.hitBox.y = myTank.y
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
        myTail.x + modules.game.offset.x, 
        myTail.y + modules.game.offset.y, 
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

function this.drawTank(myTank)
    -- Affichage des traces du tank
    this.drawTails(myTank)

    -- Affichage du tank
    love.graphics.draw(
        myTank.imageTank, 
        myTank.x + modules.game.offset.x, 
        myTank.y + modules.game.offset.y, 
        myTank.angle, 
        1, 
        1, 
        myTank.center.x, myTank.center.y)

    if myTank.drawLife == true then
        -- On dessine la barre de vie des tanks
        love.graphics.setColor(255, 0, 0)
        love .graphics.rectangle("fill", myTank.x - myTank.center.x + modules.game.offset.x, myTank.y - 1.5 * myTank.center.y + modules.game.offset.y, 2 * myTank.center.x, this.constantes.lifeBarHeight)
        love.graphics.setColor(0, 255, 0)
        love .graphics.rectangle("fill", myTank.x - myTank.center.x + modules.game.offset.x, myTank.y - 1.5 * myTank.center.y + modules.game.offset.y, 2 * myTank.center.x * myTank.life / myTank.initialLife, this.constantes.lifeBarHeight)
        love.graphics.setColor(255, 255, 255)
        love .graphics.rectangle("line", myTank.x - myTank.center.x + modules.game.offset.x, myTank.y - 1.5 * myTank.center.y + modules.game.offset.y, 2 * myTank.center.x, this.constantes.lifeBarHeight)
    end

    -- Spécificités du tank
    myTank.module.drawTank(myTank)
end

function this.fire(myTank)
    if myTank.lastShot <= 0 then
        local myMissile = modules.missile.create(myTank, myTank.missileModule)
        myTank.lastShot = myMissile.reload
        myTank.module.fire(myTank)
        myTank.isFired = true
    end
end

return this