-- Factory à tank
function createEnemyTank(myGame, myTankMode, myTankSkin, x, y, angle, baseTankFactory)
    local hitboxConstants = require("modules/hitboxConstants")
    local tankConstants = require("tanks/constants")
    local missileConstants = require("missiles/constants")
    local myTank = baseTankFactory(myGame, myTankMode, myTankSkin, x, y, angle)

    myTank.maxSpeedLimit = tankConstants.enemy.maxSpeed
    myTank.maxSpeed = myTank.maxSpeedLimit
    myTank.acceleration = tankConstants.enemy.acceleration
    myTank.module = tankConstants
    myTank.lastBeacon = 0
    myTank.speed = 0
    myTank.initialLife = tankConstants.enemy.initialLife
    myTank.life = myTank.initialLife
    myTank.state = tankConstants.enemy.states.goAhead
    myTank.checkTtl = tankConstants.enemy.states.checkTtl
    myTank.beaconTtl = tankConstants.enemy.states.magneticTtl

    if myTankSkin == tankConstants.base.skins.enemySmall then
        myTank.missileMode = missileConstants.gun.mode
    elseif myTankSkin == tankConstants.base.skins.enemyMedium then
        myTank.missileMode = missileConstants.rafale.mode
    elseif myTankSkin == tankConstants.base.skins.enemyLarge then
        myTank.missileMode = missileConstants.rebound.mode
    end

    myTank.initialUpdate = myTank.update
    myTank.update = function (dt)
        myTank.initialUpdate(dt)
        if myTank.outDated == false then
            for i, myBeacon in ipairs(myTank.game.map.beacons) do

                -- Est-ce que le tank rencontre une balise directionnelle?
                if myTank.hitbox.IsCollision(myBeacon) and 
                        myBeacon.id ~= myTank.lastBeacon and 
                        myTank.state ~= tankConstants.enemy.states.moveStop then

                    -- tank pris en charge par la balise
                    myTank.state = tankConstants.enemy.states.moveStop
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
                for i, myOtherTank in ipairs(myTank.game.tanks) do
                    if myOtherTank ~= myTank then
                        collision = myTank.hitbox.IsCollision(myOtherTank.hitbox)
                        if collision == true then
                            break
                        end
                    end
                end
        
                if collision == false then
                    --Est-ce que le tank rencontre un obstacle
                    for i, myObstacle in ipairs(myTank.game.obstacles) do
                        if myObstacle.stopTank == true then
                            collision = myTank.hitbox.IsCollision(myObstacle.hitbox)
                            if collision == true then
                                break
                            end
                        end
                    end
                end
        
                -- dans ce cas il fait demi tour
                if collision == true then
                    myTank.state = tankConstants.enemy.states.moveBack
                    myTank.lastBeacon = 0
                    myTank.checkTtl = tankConstants.enemy.states.checkTtl
                end
            end
        
            -- Comportement par état
            if myTank.state == tankConstants.enemy.states.goAhead then
                myTank.moveAheadState(dt)
            elseif myTank.state == tankConstants.enemy.states.moveUp then
                myTank.moveUpState(dt)
            elseif myTank.state == tankConstants.enemy.states.moveRight then
                myTank.moveRightState(dt)
            elseif myTank.state == tankConstants.enemy.states.moveDown then
                myTank.moveDownState(dt)
            elseif myTank.state == tankConstants.enemy.states.moveLeft then
                myTank.moveLeftState(dt)
            elseif myTank.state == tankConstants.enemy.states.moveStop then
                myTank.moveStopState(dt)
            elseif myTank.state == tankConstants.enemy.states.moveBack then
                myTank.moveBackState(dt)
            end
        end
    end

    myTank.initialDamage = myTank.damage
    myTank.damage = function (damages)
        myTank.initialDamage(damages)
        myTank.turret.damage(damages)
    end
    
    myTank.moveAheadState = function (dt)
        myTank.speed = myTank.speed + myTank.acceleration * dt
        if myTank.speed >= myTank.maxSpeed then
            myTank.speed = myTank.maxSpeed
        end
    end
    
    myTank.moveStopState = function (dt)
        myTank.beaconTtl = myTank.beaconTtl + dt
        if myTank.beaconTtl >= tankConstants.enemy.states.magneticTtl then
            myTank.lastBeacon = myTank.beacon.id
            myTank.state = myTank.beacon.directions[love.math.random(1, #myTank.beacon.directions)]
            myTank.x = myTank.beacon.x
            myTank.y = myTank.beacon.y
            myTank.beacon = nil
            myTank.beaconTtl = tankConstants.enemy.states.magneticTtl
        else
            myTank.x = myTank.beaconX + myTank.beaconDistX * easingLin(myTank.beaconTtl / tankConstants.enemy.states.magneticTtl)
            myTank.y = myTank.beaconY + myTank.beaconDistY * easingLin(myTank.beaconTtl / tankConstants.enemy.states.magneticTtl)
        end
    end
    
    myTank.rotate = function (dt, myAngle)
        myTank.speed = 0
        local diffAngle = myAngle - myTank.angle
        if math.abs(diffAngle) <= tankConstants.enemy.angleTolerance then
            myTank.angle = myAngle
            myTank.state = tankConstants.enemy.states.goAhead
        else
            diffAngle = (diffAngle + 2 * math.pi) % (2 * math.pi)
            if diffAngle > math.pi then
                myTank.angle = (myTank.angle - tankConstants.enemy.angleAcceleration * dt) % (2 * math.pi)
            else
                myTank.angle = (myTank.angle + tankConstants.enemy.angleAcceleration * dt) % (2 * math.pi)
            end
        end
    end
    
    myTank.moveUpState = function (dt)
        myTank.rotate(dt, 3 * math.pi / 2)
    end
    
    myTank.moveBackState = function (dt)
        if myTank.angle == 0 then 
            myTank.state = tankConstants.enemy.states.moveLeft
        elseif myTank.angle == math.pi / 2 then 
            myTank.state = tankConstants.enemy.states.moveUp
        elseif myTank.angle == math.pi then 
            myTank.state = tankConstants.enemy.states.moveRight
        elseif myTank.angle == 3 * math.pi / 2 then 
            myTank.state = tankConstants.enemy.states.moveDown
        end
    end
    
    myTank.moveRightState = function (dt)
        myTank.rotate(dt, 2 * math.pi)
    end
    
    myTank.moveDownState = function (dt)
        myTank.rotate(dt, math.pi / 2)
    end
    
    myTank.moveLeftState = function (dt)
        myTank.rotate(dt, math.pi)
    end
    
    myTank.initialDraw = myTank.draw
    myTank.draw = function ()
        myTank.initialDraw()
    end
    
    myTank.initialFire = myTank.fire
    myTank.fire = function (myMissile)
        local previousFire = myTank.isFired
        myTank.initialFire()
        if previousFire ~= myTank.isFired then
            myTank.lastShot = myTank.lastShot * 2
        end
    end

    return myTank
end
