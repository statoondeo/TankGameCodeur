require("turrets/ally")
require("turrets/enemy")

-- Factory à tourelles
function createTurret(myGame, myTurretSkin, myTank)
    local tankConstants = require("tanks/constants")
    if myTank.mode == tankConstants.modes.player then
        return createAllyTurret(myGame, myTurretSkin, myTank)
    elseif myTank.mode == tankConstants.modes.enemy then
        return createEnemyTurret(myGame, myTurretSkin, myTank)
    end
end

function createBaseTurret(myGame, myTurretSkin, myTank)
    local turretConstants = require("turrets/constants")
    local newTurret = {}
    newTurret.game = myGame
    newTurret.skin = myTurretSkin
    newTurret.image = newTurret.game.resources.images.turrets[newTurret.skin]
    newTurret.tank = myTank
    newTurret.angle = 0
    newTurret.x = newTurret.tank.turretAnchor.x
    newTurret.y = newTurret.tank.turretAnchor.y
    newTurret.center = {}
    newTurret.center.x = turretConstants.base.offset.x
    newTurret.center.y = newTurret.image:getHeight() / 2 + turretConstants.base.offset.y
    newTurret.output = {}
    newTurret.output.x = newTurret.x + math.cos(newTurret.angle) * newTurret.image:getWidth()
    newTurret.output.y = newTurret.x + math.sin(newTurret.angle) * newTurret.image:getHeight()
    newTurret.fireTtl = 0
    newTurret.fireIndex = 0
    newTurret.fireImage = nil
    newTurret.fireImages = {}
    newTurret.fireImages[1] = newTurret.game.resources.images.flames[1]
    newTurret.fireImages[2] = newTurret.game.resources.images.flames[2]
    newTurret.fireImages[3] = newTurret.game.resources.images.flames[3]
    newTurret.fireImages[4] = newTurret.game.resources.images.flames[4]
    newTurret.fireImages[5] = newTurret.game.resources.images.flames[5]

    newTurret.damage = function (damages)
    end

    newTurret.update = function (dt)
        if newTurret.tank.outDated == true then
            -- On avance dans l'animation de feu
            newTurret.fireTtl = newTurret.fireTtl + turretConstants.base.flames.speed * dt
            newTurret.fireIndex = math.floor(newTurret.fireTtl) + 1
    
            if newTurret.fireIndex > #newTurret.fireImages then
                newTurret.fireTtl = 0
                newTurret.fireIndex = math.floor(newTurret.fireTtl) + 1
            end
            newTurret.fireImage = newTurret.fireImages[newTurret.fireIndex]
        else
            newTurret.x = newTurret.tank.turretAnchor.x + math.cos(newTurret.angle)
            newTurret.y = newTurret.tank.turretAnchor.y + math.sin(newTurret.angle)
            newTurret.output.x = newTurret.x + math.cos(newTurret.angle) * newTurret.image:getWidth()
            newTurret.output.y = newTurret.y + math.sin(newTurret.angle) * newTurret.image:getWidth()
        end
    end

    newTurret.draw = function ()
        if newTurret.tank.outDated == true then
            local sens = 1
            if newTurret.fireIndex >= 3 then
                sens = -1
            end
            -- Affichage de la flamme
            love.graphics.draw(
                newTurret.fireImage, 
                math.floor(newTurret.x + newTurret.game.offset.x), 
                math.floor(newTurret.y +  newTurret.game.offset.y),
                0, 
                sens, 
                1, 
                math.floor(newTurret.fireImage:getWidth() / 2), 
                math.floor(newTurret.fireImage:getHeight()))
        else
            -- Affichage de la tourelle
            love.graphics.draw(
                newTurret.image, 
                math.floor(newTurret.x + newTurret.game.offset.x), 
                math.floor(newTurret.y +  newTurret.game.offset.y),
                newTurret.angle, 
                1, 
                1, 
                math.floor(newTurret.center.x), 
                math.floor(newTurret.center.y))
        end
    end

    return newTurret
end
