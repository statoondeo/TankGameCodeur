require("tanks/ally")
require("tanks/enemy")
require("turrets/base")
require("modules/hitbox")
require("missiles/base")

function createBasetank(myGame, myTankMode, myTankSkin, x, y, angle)
    local tankConstants = require("tanks/constants")
    local hitboxConstants = require("modules/hitboxConstants")
    local myTank = {}
    myTank.game = myGame
    myTank.mode = myTankMode
    myTank.skin = myTankSkin
    myTank.imageTank = myTank.game.resources.images.tanks[myTankSkin - 1]
    myTank.imageTrace = myTank.game.resources.images.tanks.trace
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
    myTank.turretAnchor.x = myTank.x + tankConstants.base.turretAnchorOffset.x
    myTank.turretAnchor.y = myTank.y
    myTank.tailFrame = 0
    myTank.tails = {}
    myTank.hitbox = createHitbox(myTank.game, hitboxConstants.circleType)
    myTank.hitbox.x = myTank.x
    myTank.hitbox.y = myTank.y
    myTank.hitbox.radius = myTank.imageTank:getWidth() / 2
    myTank.turret = createTurret(myTank.game, myTankSkin - 1, myTank)
    myTank.isFired = false
    myTank.outDated = false
    myTank.drawLife = true

    myTank.damage = function (damages)
        myTank.life = myTank.life - damages
        if myTank.life <= 0 then
            myTank.life = 0
            myTank.outDated = true
        end
    end

    -- Gestion des traces
    myTank.updateTails = function (dt)
        for i = #myTank.tails, 1, -1 do
            local myTail = myTank.tails[i]
            myTail.ttl = myTail.ttl - dt
            if myTail.ttl <= 0 then
                table.remove(myTank.tails, i)
            end
        end

        if (myTank.tailFrame % tankConstants.base.tailSpeed) == 0 then
            local newTail = {}
            newTail.x = myTank.x
            newTail.y = myTank.y
            newTail.angle = myTank.angle
            newTail.ttl = tankConstants.base.tailLife
            table.insert(myTank.tails, newTail)
        end
        myTank.tailFrame = (myTank.tailFrame + 1) % 60
    end

    myTank.UpdateTurretAnchor = function(dt)
        -- Le point d'ancrage de la tourelle a changé
        myTank.turretAnchor.x = myTank.x + math.cos(myTank.angle) * tankConstants.base.turretAnchorOffset.x
        myTank.turretAnchor.y = myTank.y + math.sin(myTank.angle) * tankConstants.base.turretAnchorOffset.y
    end

    -- Mise à jour des infos du tank
    myTank.updateData = function(dt)
        myTank.vector.x = math.cos(myTank.angle) * myTank.speed
        myTank.vector.y = math.sin(myTank.angle) * myTank.speed
        myTank.x = myTank.x + myTank.vector.x
        myTank.y = myTank.y + myTank.vector.y
        
        -- Modification de la hitbox
        myTank.hitbox.x = myTank.x
        myTank.hitbox.y = myTank.y

        -- Le point d'ancrage de la tourelle a changé
        myTank.UpdateTurretAnchor(dt)

        -- Temps de recharge des obus
        if myTank.lastShot > 0 then
            myTank.lastShot = myTank.lastShot - dt
        else
            myTank.isFired = false
            myTank.lastShot = 0
        end
    end

    -- rafraichissement du tank
    myTank.update = function(dt)   
        if myTank.outDated == false then
            -- Mise à jour des informations
            myTank.updateData(dt)
            
            -- Mise à jour des traces
            myTank.updateTails(dt)
        end
    end

    -- Permet de sortir le tank d'un obstacle lors d'une collision
    myTank.rewind = function()
        if myTank.outDated == false then
            myTank.x = myTank.x - myTank.vector.x
            myTank.y = myTank.y - myTank.vector.y
            myTank.hitbox.x = myTank.x
            myTank.hitbox.y = myTank.y
            return myTank.vector.x ~= 0 or myTank.vector.y ~= 0
        end
        return false
    end

    myTank.drawTails = function()
        -- Affichage des traces du tank
        for i, myTail in ipairs(myTank.tails) do
            myTank.drawtail(myTail)
        end
        love.graphics.setColor(255, 255, 255)
    end
    
    myTank.drawtail = function(myTail)
        love.graphics.setColor(255, 255, 255, myTail.ttl)
        love.graphics.draw(
            myTank.imageTrace, 
            math.floor(myTail.x + myTank.game.offset.x), 
            math.floor(myTail.y + myTank.game.offset.y), 
            myTail.angle, 
            1, 
            1, 
            math.floor(myTank.imageTrace:getWidth() / 2), 
            math.floor(myTank.imageTrace:getHeight() / 2))
    end

    myTank.draw = function()
        -- Affichage des traces du tank
        myTank.drawTails()
    
        -- Affichage du tank
        love.graphics.draw(
            myTank.imageTank, 
            math.floor(myTank.x + myTank.game.offset.x), 
            math.floor(myTank.y + myTank.game.offset.y), 
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
                math.floor(myTank.x - myTank.center.x + myTank.game.offset.x), 
                math.floor(myTank.y - 1.5 * myTank.center.y + myTank.game.offset.y), 
                math.floor(2 * myTank.center.x), 
                tankConstants.base.lifeBarHeight)
            love.graphics.setColor(0, 255, 0)
            love .graphics.rectangle(
                "fill", 
                math.floor(myTank.x - myTank.center.x + myTank.game.offset.x), 
                math.floor(myTank.y - 1.5 * myTank.center.y + myTank.game.offset.y), 
                math.floor(2 * myTank.center.x * myTank.life / myTank.initialLife), 
                tankConstants.base.lifeBarHeight)
            love.graphics.setColor(255, 255, 255)
            love .graphics.rectangle(
                "line", 
                math.floor(myTank.x - myTank.center.x + myTank.game.offset.x), 
                math.floor(myTank.y - 1.5 * myTank.center.y + myTank.game.offset.y), 
                math.floor(2 * myTank.center.x), 
                tankConstants.base.lifeBarHeight)
        end
    end

    myTank.fire = function()
        if myTank.lastShot <= 0 then
            local myMissile = createMissile(myTank.game, myTank, myTank.missileMode)
            myTank.lastShot = myMissile.reload
            -- myTank.fire(myMissile)
            myTank.isFired = true
            return myMissile
        end
        return nil
    end

    return myTank
end

-- Factory à tank
function createTank(myGame, myTankMode, myTankSkin, x, y, angle)
    local tankConstants = require("tanks/constants")
    if myTankMode == tankConstants.modes.player then
        return createAllyTank(myGame, myTankMode, myTankSkin, x, y, angle, createBasetank)
    elseif myTankMode == tankConstants.modes.enemy then
        return createEnemyTank(myGame, myTankMode, myTankSkin, x, y, angle, createBasetank)
    end
end