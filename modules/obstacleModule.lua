local this = {}

this.constantes = {}
this.constantes.nbObstacleResource = 12
this.images = {}
this.obstacles = {}

function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.nbObstacleResource do
        this.images[i] = love.graphics.newImage("images/obstacle_" .. i .. ".png")
    end
end

function this.create(imageIndex, x, y, angle, zoom, stopMissile, stopTank, speedRatio, roundHitBox, radius, width, height)
    local newObstacle = {}

    -- Impact sur les collisions
    if roundHitBox ~= nil then
        if roundHitBox == true then
            newObstacle.hitBox = modules.hitbox.create(modules.hitbox.constantes.circleType)
            newObstacle.hitBox.radius = radius
        else
            newObstacle.hitBox = modules.hitbox.create(modules.hitbox.constantes.rectangleType)
            newObstacle.hitBox.width = width
            newObstacle.hitBox.height = height
        end
        newObstacle.hitBox.x = x
        newObstacle.hitBox.y = y
    else
        newObstacle.hitBox = modules.hitbox.create(modules.hitbox.constantes.nonetype)
    end

    -- Impact sur le visuel
    newObstacle.center = {}
    newObstacle.visible = imageIndex ~= 0
    if newObstacle.visible == true then
        newObstacle.imageIndex = imageIndex
        newObstacle.image = this.images[imageIndex]
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
            myObstacle.x + modules.game.offset.x, 
            myObstacle.y + modules.game.offset.y,
            myObstacle.angle,
            myObstacle.zoom,
            myObstacle.zoom,
            myObstacle.center.x,
            myObstacle.center.y) 
    end

    -- love.graphics.setFont(modules.game.fonts.tiny)
    -- local font = love.graphics.getFont()
    -- local label
    -- if myObstacle.hitBox.type == modules.hitbox.constantes.circleType then
    --     love.graphics.circle("line", myObstacle.hitBox.x + modules.game.offset.x, myObstacle.hitBox.y + modules.game.offset.y, myObstacle.hitBox.radius)
    --     label = myObstacle.hitBox.x .. "/" .. myObstacle.hitBox.y .. "/" .. myObstacle.hitBox.radius
    --     -- love.graphics.print(
    --     --     label,
    --     --     myObstacle.hitBox.x + modules.game.offset.x - font:getWidth(label) / 2,
    --     --     myObstacle.hitBox.y + modules.game.offset.y - font:getHeight(label) / 2)
    -- elseif myObstacle.hitBox.type == modules.hitbox.constantes.rectangleType then
    --     love.graphics.rectangle("line", myObstacle.hitBox.x + modules.game.offset.x, myObstacle.hitBox.y + modules.game.offset.y, myObstacle.hitBox.width, myObstacle.hitBox.height)
    --     label = myObstacle.hitBox.x .. "/" .. myObstacle.hitBox.y .. "/" .. myObstacle.hitBox.width .. "/" .. myObstacle.hitBox.height
    --     -- love.graphics.print(
    --     --     label,
    --     --     myObstacle.hitBox.x + modules.game.offset.x + (myObstacle.hitBox.width - font:getWidth(label)) / 2,
    --     --     myObstacle.hitBox.y + modules.game.offset.y + (myObstacle.hitBox.height - font:getHeight(label)) / 2)
    -- end
end

function this.ManageMissileObstacleCollision(myMissile, myObstacle)
    if myObstacle.hitBox.type ~= modules.hitbox.constantes.noneType and myMissile.exploded == false then
        if modules.hitbox.IsCollision(myObstacle.hitBox, myMissile.hitBox) then

            -- On replace le missile à l'extérieur de l'obstacle pour son explosion                            
            while modules.missile.rewind(myMissile) and modules.hitbox.IsCollision(myObstacle.hitBox, myMissile.hitBox) do end
            
            -- Le missile explose
            myMissile.exploded = true
        end
    end
end

function this.ManageMissileTankCollision(myMissile, myTank)
    if myMissile.tank ~= myTank then
        if modules.hitbox.IsCollision(myMissile.hitBox, myTank.hitBox) then

            -- On replace le missile à l'extérieur de l'obstacle pour son explosion                            
            while modules.missile.rewind(myMissile) and modules.hitbox.IsCollision(myMissile.hitBox, myMissile.hitBox) do end
            
            -- Le missile explose
            myMissile.exploded = true

            -- On inflige des dégats au tank
            modules.tank.Damage(myTank, myMissile.damage.missile)
        end
    end
end

function this.ManageExplosionTankCollision(myMissile, myTank)
    if myMissile.tank ~= myTank then
        -- On inflige des dégats d'explosion au tank
        local explosionHitbox = modules.hitbox.create(modules.hitbox.constantes.circleType)
        explosionHitbox.x = myMissile.x
        explosionHitbox.y = myMissile.y
        explosionHitbox.radius = myMissile.explosionZoom * modules.missile.images.explosions[1]:getWidth() / 2
        if modules.hitbox.IsCollision(explosionHitbox, myTank.hitBox) == true and myMissile.explosionDamageDone == false then
            -- On inflige des dégats au tank
            modules.tank.Damage(myTank, myMissile.damage.explosion)
        end
    end
end

function this.ManageTankObstacleCollision(myTank, myObstacle)
    if myObstacle.hitBox.type ~= modules.hitbox.constantes.noneType and modules.hitbox.IsCollision(myObstacle.hitBox, myTank.hitBox) then

        if myObstacle.stopTank == true then
            -- On replace le tank à l'extérieur de l'obstacle
            while modules.tank.rewind(myTank) and modules.hitbox.IsCollision(myObstacle.hitBox, myTank.hitBox) do end

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
    if modules.hitbox.IsCollision(myTank.hitBox, myOtherTank.hitBox) then
        -- On replace le tank à l'extérieur de l'obstacle
        while modules.hitbox.IsCollision(myTank.hitBox, myOtherTank.hitBox) and modules.tank.rewind(myTank) do end

        -- Le tank est arrété
        myTank.vector.x = 0
        myTank.vector.y = 0
    end

    return myTank.vector.x == 0 and myTank.vector.y == 0
end

function this.ManageTankGroundCollision(myTank, myObstacle)
    local speedModifier = 1
    if myObstacle.hitBox.type ~= modules.hitbox.constantes.noneType and modules.hitbox.IsCollision(myObstacle.hitBox, myTank.hitBox) then
        -- Les modificateurs de vitesse se cumulent entre eux
        speedModifier = myObstacle.speedRatio
    end
    return speedModifier
end

-- Calculs de collision
function this.ManageCollision()

    -- Gestion des missiles
    for i, myMissile in pairs(modules.missile.missiles) do
        
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
            for i, myTank in ipairs(modules.tank.tanks) do
                this.ManageMissileTankCollision(myMissile, myTank)
                if myMissile.exploded == true then
                    break
                end
            end
        else
            -- Est-ce que l'explosion rencontre un tank
            if myMissile.explosionDamageDone == false then
                for i, myTank in ipairs(modules.tank.tanks) do
                    this.ManageExplosionTankCollision(myMissile, myTank)
                end
                myMissile.explosionDamageDone = true
            end
        end

        -- TODO, Est-ce que le missile rencontre un autre missile ?
    end

    -- Gestion des tanks
    for i, myTank in pairs(modules.tank.tanks) do
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
            -- On applique les changements de vitesse
            myTank.maxSpeed = myTank.speedFactor * myTank.maxSpeedLimit

            -- Est-ce que le tank rencontre un tank
            for i, myOtherTank in ipairs(modules.tank.tanks) do
                if myOtherTank ~= myTank then
                    tankStopped = this.ManageTankTankCollision(myOtherTank, myTank)
                end
            end
        end
    end
end

return this