local this = {}

this.constantes = {}

this.constantes.modes = {}
this.constantes.modes.player = 1
this.constantes.modes.ennemy = 2

this.constantes.acceleration = 3
this.constantes.angleAcceleration = 2
this.constantes.angleTolerance = math.pi / 36
this.constantes.defaultAcceleration = 1  
this.constantes.maxSpeed = 1
this.constantes.maxSpeedEnnemy = 1
this.constantes.tailLife = 1
this.constantes.tailSpeed = 10
this.constantes.initialLife = 1000

this.constantes.states = {}
this.constantes.states.goAhead = 0
this.constantes.states.checkTtl = 3
this.constantes.states.moveUp = 1
this.constantes.states.moveRight = 2
this.constantes.states.moveDown = 3
this.constantes.states.moveLeft = 4
this.constantes.states.moveStop = 5
this.constantes.states.moveBack = 6
this.constantes.states.magneticTtl = 1

-- Factory à tank
function this.create(myTankMode, myTankSkin, x, y, angle)
    local myTank = game.tank.createNew(myTankMode, myTankSkin, x, y, angle)
    myTank.maxSpeedLimit = this.constantes.maxSpeed
    myTank.maxSpeed = myTank.maxSpeedLimit
    myTank.acceleration = this.constantes.acceleration
    myTank.module = this
    myTank.lastBeacon = 0
    myTank.speed = 0
    myTank.initialLife = this.constantes.initialLife
    myTank.life = myTank.initialLife
    myTank.state = this.constantes.states.goAhead
    myTank.checkTtl = this.constantes.states.checkTtl
    myTank.beaconTtl = this.constantes.states.magneticTtl
    return myTank
end

function this.updateTank(dt, myTank)
    -- Est-ce que le tank rencontre une balise directionnelle?
    local myTankHitbox = game.hitbox.create(game.hitbox.constantes.circleType)
    myTankHitbox.x = myTank.hitBox.x
    myTankHitbox.y = myTank.hitBox.y
    myTankHitbox.radius = 2
    for i, myBeacon in ipairs(game.map.beacons) do
        -- Préparation à la rencontre avec une balise, on ralentit
        if game.hitbox.IsCollision(myTank.hitBox, myBeacon) and myBeacon.id ~= myTank.lastBeacon and myTank.state ~= this.constantes.states.moveStop then
            myTank.state = this.constantes.states.moveStop
            -- tank pris en charge par la balise
            myTank.beaconTtl = 0
            myTank.beacon = myBeacon
            myTank.beaconX = myTank.x
            myTank.beaconDistX = myBeacon.x - myTank.x
            myTank.beaconY = myTank.y
            myTank.beaconDistY = myBeacon.y - myTank.y
        end
    end

    myTank.checkTtl = myTank.checkTtl - dt
    if myTank.checkTtl <= 0 then
        local collision
        --Est-ce que le tank rencontre un tank
        for i, myOtherTank in ipairs(game.tank.tanks) do
            if myOtherTank ~= myTank then
                collision = game.hitbox.IsCollision(myTank.hitBox, myOtherTank.hitBox)
                if collision == true then
                    break
                end
            end
        end

        if collision == false then
            --Est-ce que le tank rencontre un obstacle
            for i, myObstacle in ipairs(game.obstacle.obstacles) do
                if myObstacle.stopTank == true then
                    collision = game.hitbox.IsCollision(myTank.hitBox, myObstacle.hitBox)
                    if collision == true then
                        break
                    end
                end
            end
        end

        -- dans ce cas il fait demi tour
        if collision == true then
            myTank.state = this.constantes.states.moveBack
            myTank.lastBeacon = 0
            myTank.checkTtl = this.constantes.states.checkTtl
        end
    end

    -- Comportement par état
    if myTank.state == this.constantes.states.goAhead then
        this.moveAheadState(dt, myTank)
    elseif myTank.state == this.constantes.states.moveUp then
        this.moveUpState(dt, myTank)
    elseif myTank.state == this.constantes.states.moveRight then
        this.moveRightState(dt, myTank)
    elseif myTank.state == this.constantes.states.moveDown then
        this.moveDownState(dt, myTank)
    elseif myTank.state == this.constantes.states.moveLeft then
        this.moveLeftState(dt, myTank)
    elseif myTank.state == this.constantes.states.moveStop then
        this.moveStopState(dt, myTank)
    elseif myTank.state == this.constantes.states.moveBack then
        this.moveBackState(dt, myTank)
    end
end

function this.Damage(myTank, damages)
    myTank.turret.module.Damage(myTank.turret, damages)
end

function this.moveAheadState(dt, myTank)
    myTank.speed = myTank.speed + myTank.acceleration * dt
    if myTank.speed >= myTank.maxSpeed then
        myTank.speed = myTank.maxSpeed
    end
end

function this.moveStopState(dt, myTank)
    myTank.beaconTtl = myTank.beaconTtl + dt
    if myTank.beaconTtl >= this.constantes.states.magneticTtl then
        myTank.lastBeacon = myTank.beacon.id
        myTank.state = myTank.beacon.directions[love.math.random(1, #myTank.beacon.directions)]
        myTank.x = myTank.beacon.x
        myTank.y = myTank.beacon.y
        myTank.beacon = nil
        myTank.beaconTtl = this.constantes.states.magneticTtl
    else
        myTank.x = myTank.beaconX + myTank.beaconDistX * game.tweening.easingLin(myTank.beaconTtl / this.constantes.states.magneticTtl)
        myTank.y = myTank.beaconY + myTank.beaconDistY * game.tweening.easingLin(myTank.beaconTtl / this.constantes.states.magneticTtl)
    end
end

function this.rotate(dt, myTank, myAngle)
    myTank.speed = 0
    local diffAngle = myAngle - myTank.angle
    if math.abs(diffAngle) <= this.constantes.angleTolerance then
        myTank.angle = myAngle
        myTank.state = this.constantes.states.goAhead
    else
        diffAngle = (diffAngle + 2 * math.pi) % (2 * math.pi)
        if diffAngle > math.pi then
            myTank.angle = (myTank.angle - this.constantes.angleAcceleration * dt) % (2 * math.pi)
        else
            myTank.angle = (myTank.angle + this.constantes.angleAcceleration * dt) % (2 * math.pi)
        end
    end
end

function this.moveUpState(dt, myTank)
    this.rotate(dt, myTank, 3 * math.pi / 2)
end

function this.moveBackState(dt, myTank)
    if math.abs(myTank.angle - 0) <= this.constantes.angleTolerance then 
        myTank.state = this.constantes.states.moveLeft
    elseif math.abs(myTank.angle - math.pi / 2) <= this.constantes.angleTolerance then 
        myTank.state = this.constantes.states.moveUp
    elseif math.abs(myTank.angle - math.pi) <= this.constantes.angleTolerance then 
        myTank.state = this.constantes.states.moveRight
    elseif math.abs(myTank.angle - 3 * math.pi / 2) <= this.constantes.angleTolerance then 
        myTank.state = this.constantes.states.moveDown
    end
end

function this.moveRightState(dt, myTank)
    this.rotate(dt, myTank, 2 * math.pi)
end

function this.moveDownState(dt, myTank)
    this.rotate(dt, myTank, math.pi / 2)
end

function this.moveLeftState(dt, myTank)
    this.rotate(dt, myTank, math.pi)
end

function this.drawTank(myTank)
end

function this.fire(myTank)
    myTank.lastShot = myTank.lastShot * 2
end

return this