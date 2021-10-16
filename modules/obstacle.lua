require("modules/hitbox")

function createObstacle(myGame, imageIndex, x, y, angle, zoom, stopMissile, stopTank, speedRatio, roundHitBox, radius, width, height)
    local hitboxConstants = require("modules/hitboxConstants")
    local newObstacle = {}
    newObstacle.game = myGame
    -- Impact sur les collisions
    if roundHitBox ~= nil then
        if roundHitBox == true then
            newObstacle.hitbox = createHitbox(newObstacle.game, hitboxConstants.circleType)
            newObstacle.hitbox.radius = radius
        else
            newObstacle.hitbox = createHitbox(newObstacle.game, hitboxConstants.rectangleType)
            newObstacle.hitbox.width = width
            newObstacle.hitbox.height = height
        end
        newObstacle.hitbox.x = x
        newObstacle.hitbox.y = y
    else
        newObstacle.hitbox = createHitbox(newObstacle.game, hitboxConstants.nonetype)
    end

    -- Impact sur le visuel
    newObstacle.center = {}
    newObstacle.visible = imageIndex ~= 0
    if newObstacle.visible == true then
        newObstacle.imageIndex = imageIndex
        newObstacle.image = newObstacle.game.resources.images.obstacles[imageIndex]
        newObstacle.center.x = newObstacle.image:getWidth() / 2
        newObstacle.center.y = newObstacle.image:getWidth() / 2
        newObstacle.zoom = zoom
        newObstacle.hitbox.radius = newObstacle.zoom * newObstacle.image:getWidth() / 2
        newObstacle.x = x
        newObstacle.y = y
        newObstacle.angle = angle
    end

    -- Impact sur le jeu
    newObstacle.stopMissile = stopMissile
    newObstacle.stopTank = stopTank
    newObstacle.speedRatio = speedRatio

    newObstacle.update = function(dt)
    end

    newObstacle.draw = function ()
        if newObstacle.visible == true then
                love.graphics.draw(
                    newObstacle.image, 
                    newObstacle.x + newObstacle.game.offset.x, 
                    newObstacle.y + newObstacle.game.offset.y,
                    newObstacle.angle,
                    newObstacle.zoom,
                    newObstacle.zoom,
                    newObstacle.center.x,
                    newObstacle.center.y) 
        end
    end
    
    return newObstacle
end
