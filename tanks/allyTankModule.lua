local this = {}

this.constantes = {}

this.constantes.modes = {}
this.constantes.modes.player = 1
this.constantes.modes.ennemy = 2

this.constantes.acceleration = 3
this.constantes.angleAcceleration = 2
this.constantes.defaultAcceleration = 2
this.constantes.maxSpeed = 3
this.constantes.maxSpeedEnnemy = 1
this.constantes.tailLife = 1
this.constantes.tailSpeed = 10
this.constantes.initialLife = 1000

-- Factory à tank
function this.create(myTankMode, myTankSkin, x, y, angle)
    local myTank = modules.tank.createNew(myTankMode, myTankSkin, x, y, angle)
    myTank.maxSpeedLimit = this.constantes.maxSpeed - myTankSkin * 0.2
    myTank.maxSpeed = myTank.maxSpeedLimit
    myTank.acceleration = this.constantes.acceleration
    myTank.module = this
    myTank.initialLife = this.constantes.initialLife
    myTank.life = myTank.initialLife
    return myTank
end

function this.updateTank(dt, myTank)
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

function this.drawTank(myTank)
end

function this.Damage(myTank, damages)
end

function this.fire(myTank)
end

return this