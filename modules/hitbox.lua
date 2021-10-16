function createHitbox(myGame, myHitboxType)
    local hitboxConstants = require("modules/hitboxConstants")
    local newHitbox = {}

    newHitbox.game = myGame
    newHitbox.type = myHitboxType
    newHitbox.x = 0
    newHitbox.y = 0
    newHitbox.radius = 0
    newHitbox.width = 0
    newHitbox.height = 0

    -- Affichage de la hitbox
    newHitbox.draw = function ()
        if newHitbox.type ~= nil then
            if newHitbox.type == hitboxConstants.rectangleType then
                love.graphics.rectangle(
                    "line", 
                    newHitbox.x + newHitbox.game.offset.x, 
                    newHitbox.y + newHitbox.game.offset.y, 
                    newHitbox.width,
                    newHitbox.height)    
            elseif newHitbox.type == hitboxConstants.circleType then
                love.graphics.circle(
                    "line", 
                    newHitbox.x + newHitbox.game.offset.x, 
                    newHitbox.y + newHitbox.game.offset.y, 
                    newHitbox.radius)
            end
        end
    end

    -- Est-ce qu'il y a une collision
    newHitbox.IsCollision = function (hitboxToTest)
        if newHitbox.type == hitboxConstants.circleType then
            if hitboxToTest.type == hitboxConstants.circleType then
                return newHitbox.IsCircleInCircle(hitboxToTest)
            else
                return newHitbox.IsCircleInRectangle(hitboxToTest)
            end
        else
            if hitboxToTest.type == hitboxConstants.circleType then
                return hitboxToTest.IsCircleInRectangle(newHitbox)
            else
                return newHitbox.IsRectangleInRectangle(hitboxToTest)
            end
        end
    end

    -- Calcul de la distance entre 2 points
    newHitbox.dist = function (hitbox) 
        return ((newHitbox.x - hitbox.x)^2+(newHitbox.y - hitbox.y)^2)^0.5 
    end

    -- Est-ce qu'il y a collision entre ces 2 hitbox circulaires
    newHitbox.IsCircleInCircle = function (hitbox)
        return newHitbox.dist(hitbox) <= newHitbox.radius + hitbox.radius
    end

    newHitbox.IsCircleInArc = function (arc)
        local angle = math.atan2(newHitbox.y - arc.y, newHitbox.x - arc.x) % (2 * math.pi)
        return  math.abs(arc.angle - angle) <= arc.amplitude and newHitbox.dist(arc) <= arc.radius + newHitbox.radius
    end

    -- Est-ce qu'il y a collision entre ces 2 hitbox circulaire (radius = 0) et rectangulaire
    newHitbox.IsPointInRectangle = function(rectangleHitBox)
        return 
            rectangleHitBox.x <= newHitbox.x and newHitbox.x <= rectangleHitBox.x + rectangleHitBox.width and
            rectangleHitBox.y <= newHitbox.y and newHitbox.y <= rectangleHitBox.y + rectangleHitBox.height
    end

    -- Est-ce qu'il y a collision entre ces 2 hitbox circulaire et rectangulaire
    newHitbox.IsCircleInRectangle = function (rectangleHitBox)
        local nHitBox = createHitbox(newHitbox.game, hitboxConstants.circleType)
        nHitBox.x = newHitbox.x + newHitbox.radius
        nHitBox.y = newHitbox.y
        nHitBox.radius = 1
        local sHitBox = createHitbox(newHitbox.game, hitboxConstants.circleType)
        sHitBox.x = newHitbox.x - newHitbox.radius
        sHitBox.y = newHitbox.y                
        sHitBox.radius = 1
        local eHitBox = createHitbox(newHitbox.game, hitboxConstants.circleType)
        eHitBox.x = newHitbox.x
        eHitBox.y = newHitbox.y - newHitbox.radius
        eHitBox.radius = 1
        local wHitBox = createHitbox(newHitbox.game, hitboxConstants.circleType)
        wHitBox.x = newHitbox.x
        wHitBox.y = newHitbox.y + newHitbox.radius
        wHitBox.radius = 1
        return 
            nHitBox.IsPointInRectangle(rectangleHitBox) or 
            sHitBox.IsPointInRectangle(rectangleHitBox) or 
            eHitBox.IsPointInRectangle(rectangleHitBox) or 
            wHitBox.IsPointInRectangle(rectangleHitBox)
    end

    -- Est-ce qu'il y a collision entre ces 2 hitbox rectangulaires
    newHitbox.IsRectangleInRectangle = function(rectangleHitbox)
        return 
            newHitbox.x < rectangleHitbox.x + rectangleHitbox.width and
            rectangleHitbox.x < newHitbox.x + newHitbox.width and
            newHitbox.y < rectangleHitbox.y + rectangleHitbox.height and
            rectangleHitbox.y < newHitbox.y + newHitbox.height
    end

    return newHitbox
end
