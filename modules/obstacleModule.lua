local this = {}

function this.create(imageIndex, x, y, angle, zoom, stopMissile, stopTank, speedRatio, roundHitBox, radius, width, height)
    local newObstacle = {}

    -- Impact sur les collisions
    if roundHitBox ~= nil then
        if roundHitBox == true then
            newObstacle.hitBox = game.hitbox.create(game.hitbox.constantes.circleType)
            newObstacle.hitBox.radius = radius
        else
            newObstacle.hitBox = game.hitbox.create(game.hitbox.constantes.rectangleType)
            newObstacle.hitBox.width = width
            newObstacle.hitBox.height = height
        end
        newObstacle.hitBox.x = x
        newObstacle.hitBox.y = y
    else
        newObstacle.hitBox = game.hitbox.create(game.hitbox.constantes.nonetype)
    end

    -- Impact sur le visuel
    newObstacle.center = {}
    newObstacle.visible = imageIndex ~= 0
    if newObstacle.visible == true then
        newObstacle.imageIndex = imageIndex
        newObstacle.image = game.images.obstacles[imageIndex]
        newObstacle.center.x = newObstacle.image:getWidth() / 2
        newObstacle.center.y = newObstacle.image:getWidth() / 2
        newObstacle.zoom = zoom
        newObstacle.hitBox.radius = newObstacle.zoom * newObstacle.image:getWidth() / 2
        newObstacle.x = x
        newObstacle.y = y
        newObstacle.angle = angle
    end

    -- Impact sur le jeu
    newObstacle.stopMissile = stopMissile
    newObstacle.stopTank = stopTank
    newObstacle.speedRatio = speedRatio

    -- table.insert(this.obstacles, newObstacle)

    return newObstacle
end

function this.update(dt)
    for i, myObstacle in ipairs(this.obstacles) do
        this.updateObstacle(dt, myObstacle)
    end
end

function this.updateObstacle(dt, myObstacle)
end

function this.draw()
    for i, myObstacle in ipairs(this.obstacles) do
        this.drawObstacle(myObstacle)
    end
end

function this.drawObstacle(myObstacle)
    if myObstacle.visible == true then
            love.graphics.draw(
                myObstacle.image, 
                myObstacle.x + game.offset.x, 
                myObstacle.y + game.offset.y,
                myObstacle.angle,
                myObstacle.zoom,
                myObstacle.zoom,
                myObstacle.center.x,
                myObstacle.center.y) 
    end
end

function this.ManageMissileObstacleCollision(myMissile, myObstacle)
    if myObstacle.hitBox.type ~= game.hitbox.constantes.noneType and myMissile.exploded == false then
        if game.hitbox.IsCollision(myObstacle.hitBox, myMissile.hitBox) then

            -- On replace le missile à l'extérieur de l'obstacle pour son explosion                            
            while game.missile.rewind(myMissile) and game.hitbox.IsCollision(myObstacle.hitBox, myMissile.hitBox) do end
            
            -- Le missile explose
            myMissile.exploded = true
        end
    end
end

function this.ManageMissileTankCollision(myMissile, myTank)
    if myMissile.tank.mode ~= myTank.mode then
        if game.hitbox.IsCollision(myMissile.hitBox, myTank.hitBox) then

            -- On replace le missile à l'extérieur de l'obstacle pour son explosion                            
            while game.missile.rewind(myMissile) and game.hitbox.IsCollision(myMissile.hitBox, myMissile.hitBox) do end
            
            -- Le missile explose
            myMissile.exploded = true

            -- On inflige des dégats au tank
            game.tank.Damage(myTank, myMissile.damage.missile)
        end
    end
end

function this.ManageExplosionTankCollision(myMissile, myTank)
    if myMissile.tank.mode ~= myTank.mode then
        -- On inflige des dégats d'explosion au tank
        local explosionHitbox = game.hitbox.create(game.hitbox.constantes.circleType)
        explosionHitbox.x = myMissile.x
        explosionHitbox.y = myMissile.y
        explosionHitbox.radius = myMissile.explosionZoom * game.images.explosions[1]:getWidth() / 2
        if game.hitbox.IsCollision(explosionHitbox, myTank.hitBox) == true and myMissile.explosionDamageDone == false then
            -- On inflige des dégats au tank
            game.tank.Damage(myTank, myMissile.damage.explosion)
        end
    end
end

function this.ManageTankObstacleCollision(myTank, myObstacle)
    if myObstacle.hitBox.type ~= game.hitbox.constantes.noneType and game.hitbox.IsCollision(myObstacle.hitBox, myTank.hitBox) then

        if myObstacle.stopTank == true then
            -- On replace le tank à l'extérieur de l'obstacle
            while game.tank.rewind(myTank) and game.hitbox.IsCollision(myObstacle.hitBox, myTank.hitBox) do end

            -- Le tank est arrété
            myTank.vector.x = 0
            myTank.vector.y = 0
        else
            myTank.speedFactor = myTank.speedFactor * myObstacle.speedRatio
        end
    end

    return myTank.vector.x == 0 and myTank.vector.y == 0
end

function this.ManageTankTankCollision(myTank, myOtherTank)
    if game.hitbox.IsCollision(myTank.hitBox, myOtherTank.hitBox) then
        -- On replace le tank à l'extérieur de l'obstacle
        while game.hitbox.IsCollision(myTank.hitBox, myOtherTank.hitBox) and game.tank.rewind(myTank) do end

        -- Le tank est arrété
        myTank.vector.x = 0
        myTank.vector.y = 0
    end

    return myTank.vector.x == 0 and myTank.vector.y == 0
end

function this.ManageTankGroundCollision(myTank, myObstacle)
    if myObstacle.hitBox.type ~= game.hitbox.constantes.noneType and game.hitbox.IsCollision(myObstacle.hitBox, myTank.hitBox) then
        -- Les modificateurs de vitesse se cumulent entre eux
        myTank.speedFactor = myTank.speedFactor * myObstacle.speedRatio
    end
end

-- Calculs de collision
function this.ManageCollision()

    -- Gestion des missiles
    for i, myMissile in pairs(game.missile.missiles) do
        
        -- Est-ce que le missile actif rencontre un obstacle
        if myMissile.exploded == false then
            for i, myObstacle in ipairs(this.obstacles) do
                if myObstacle.stopMissile == true then
                    this.ManageMissileObstacleCollision(myMissile, myObstacle)
                    if myMissile.exploded == true then
                        break
                    end
                end
            end
        end
        
        if myMissile.exploded == false then
        -- Est-ce que le missile rencontre un tank
            for i, myTank in ipairs(game.tank.tanks) do
                this.ManageMissileTankCollision(myMissile, myTank)
                if myMissile.exploded == true then
                    break
                end
            end
        else
            -- Est-ce que l'explosion rencontre un tank
            if myMissile.explosionDamageDone == false then
                for i, myTank in ipairs(game.tank.tanks) do
                    this.ManageExplosionTankCollision(myMissile, myTank)
                end
                myMissile.explosionDamageDone = true
            end
        end

        -- TODO, Est-ce que le missile rencontre un autre missile ?
    end

    -- Gestion des tanks
    for i, myTank in pairs(game.tank.tanks) do
        local tankStopped = false
        myTank.speedFactor = 1

        -- Est-ce que le tank rencontre un obstacle
        for i, myObstacle in ipairs(this.obstacles) do
            tankStopped = this.ManageTankObstacleCollision(myTank, myObstacle)
            if tankStopped == true then
                break
            end
        end

        if tankStopped == false then

            -- Est-ce que le tank rencontre un tank
            for i, myOtherTank in ipairs(game.tank.tanks) do
                if myOtherTank ~= myTank then
                    tankStopped = this.ManageTankTankCollision(myOtherTank, myTank)
                end
            end
        end

        if tankStopped == false then
            -- Récupération de la dalle du tank
            local colonne = math.floor(myTank.x / game.map.constantes.tiles.size.x) + 1 
            local ligne = math.floor(myTank.y / game.map.constantes.tiles.size.y) + 1  
            local tile = game.map.tiles[ligne * game.map.constantes.tiles.number.x + colonne]
            if game.map.modifiers[tile] ~= nil then
                myTank.speedFactor = myTank.speedFactor * game.map.modifiers[tile]
            end
            
            -- On applique les changements de vitesse
            myTank.maxSpeed = myTank.speedFactor * myTank.maxSpeedLimit
        end
    end
end

return this