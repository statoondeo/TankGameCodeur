-- Factory à tank
function createAllyTank(myGame, myTankMode, myTankSkin, x, y, angle, baseTankFactory)
    local tankConstants = require("tanks/constants")
    local missileConstants = require("missiles/constants")
    local myTank = baseTankFactory(myGame, myTankMode, myTankSkin, x, y, angle)

    myTank.maxSpeedLimit = tankConstants.ally.maxSpeed - myTankSkin * 0.2
    myTank.maxSpeed = myTank.maxSpeedLimit
    myTank.acceleration = tankConstants.ally.acceleration
    myTank.initialLife = tankConstants.ally.initialLife
    myTank.life = myTank.initialLife
    
    if myTankSkin == tankConstants.base.skins.playerRed then
        myTank.missileMode = missileConstants.gun.mode
    elseif myTankSkin == tankConstants.base.skins.playerBlue then
        myTank.missileMode = missileConstants.rafale.mode
    elseif myTankSkin == tankConstants.base.skins.playerGreen then
        myTank.missileMode = missileConstants.rebound.mode
    end

    myTank.initialUpdate = myTank.update
    myTank.update = function (dt)
        myTank.initialUpdate(dt)
        -- Gestion de la poussée
        if love.keyboard.isDown("up") then
             myTank.speed = myTank.speed + myTank.acceleration * dt
             if myTank.speed >= myTank.maxSpeed then
                 myTank.speed = myTank.maxSpeed
             end
         else
             if love.keyboard.isDown("down") then
                 myTank.speed = myTank.speed - myTank.acceleration * dt
                 if myTank.speed <= -myTank.maxSpeed then
                     myTank.speed = -myTank.maxSpeed
                 end
             else
                 -- Si on n'accélère pas, le tank ralenti de lui-même
                 if myTank.speed <= 0 then
                     myTank.speed = myTank.speed + tankConstants.ally.defaultAcceleration * dt
                 else
                     myTank.speed = myTank.speed - tankConstants.ally.defaultAcceleration * dt
                 end
             end
         end
     
         -- Modification de l'angle
         if love.keyboard.isDown("left") then
             myTank.angle = (myTank.angle - tankConstants.ally.angleAcceleration * dt) % (2 * math.pi)
         end
         if love.keyboard.isDown("right") then
             myTank.angle = (myTank.angle + tankConstants.ally.angleAcceleration * dt) % (2 * math.pi)
         end
     end

     myTank.initialDraw = myTank.draw
     myTank.draw = function ()
         myTank.initialDraw()
     end
     
    myTank.initialDamage = myTank.damage
    myTank.damage = function (damages)
        myTank.initialDamage(damages)
        myTank.game.bloodShake = true
    end
    
    myTank.initialfire = myTank.fire
    myTank.fire = function ()
        local myMissile = myTank.initialfire()
        if myMissile ~= nil then
            myTank.game.fireShake = true
            myTank.game.amplitudeShake = myMissile.amplitudeShake
            myTank.game.fireShakeTtl = myMissile.timeShake
            myTank.game.fireShakeAngle = (myTank.turret.angle + math.pi) % (2 * math.pi)
        end
    end

    return myTank
end
