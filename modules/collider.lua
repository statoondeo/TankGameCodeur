function createCollider()
    local hitboxConstants = require("modules/hitboxConstants")
    local newcollider = {}

    newcollider.manageMissileObstacleCollision = function (myMissile, myObstacle)
        if myObstacle.hitbox.type ~= hitboxConstants.noneType and myMissile.exploded == false then
            if myMissile.hitbox.IsCollision(myObstacle.hitbox) then

                -- On replace le missile à l'extérieur de l'obstacle pour son explosion                            
                while myMissile.rewind() and myMissile.hitbox.IsCollision(myObstacle.hitbox) do end
                
                -- Le missile explose
                myMissile.exploded = true
            end
        end
    end

    newcollider.ManageMissileTankCollision = function (myMissile, myTank)
        if myMissile.tank.mode ~= myTank.mode then
            if myMissile.hitbox.IsCollision(myTank.hitbox) then

                -- On replace le missile à l'extérieur de l'obstacle pour son explosion                            
                while myMissile.rewind() and myMissile.hitbox.IsCollision(myMissile.hitbox) do end
                
                -- Le missile explose
                myMissile.exploded = true

                -- On inflige des dégats au tank
                myTank.damage(myMissile.damage.missile)
            end
        end
    end

    newcollider.ManageExplosionTankCollision = function (myMissile, myTank)
        if myMissile.tank.mode ~= myTank.mode then

            -- On inflige des dégats d'explosion au tank
            myMissile.explosionHitbox.x = myMissile.x
            myMissile.explosionHitbox.y = myMissile.y
            if myMissile.explosionHitbox.IsCollision(myTank.hitbox) == true and myMissile.explosionDamageDone == false then
                -- On inflige des dégats au tank
                myTank.damage(myMissile.damage.explosion)
            end
        end
    end

    newcollider.ManageTankObstacleCollision = function (myTank, myObstacle)
        if myObstacle.hitbox.type ~= hitboxConstants.noneType and myObstacle.hitbox.IsCollision(myTank.hitbox) then

            if myObstacle.stopTank == true then
                -- On replace le tank à l'extérieur de l'obstacle
                while myTank.rewind() and myObstacle.hitbox.IsCollision(myTank.hitbox) do end

                -- Le tank est arrété
                myTank.vector.x = 0
                myTank.vector.y = 0
            else
                myTank.speedFactor = myTank.speedFactor * myObstacle.speedRatio
            end
        end

        return myTank.vector.x == 0 and myTank.vector.y == 0
    end

    newcollider.ManageTankTankCollision = function (myTank, myOtherTank)
        if myTank.hitbox.IsCollision(myOtherTank.hitbox) then
            -- On replace le tank à l'extérieur de l'obstacle
            while myTank.rewind() and myTank.hitbox.IsCollision(myOtherTank.hitbox) do end

            -- Le tank est arrété
            myTank.vector.x = 0
            myTank.vector.y = 0
        end

        return myTank.vector.x == 0 and myTank.vector.y == 0
    end

    newcollider.ManageTankGroundCollision = function (myTank, myObstacle)
        if myObstacle.hitbox.type ~= hitboxConstants.noneType and myObstacle.hitbox.IsCollision(myTank.hitbox) then
            -- Les modificateurs de vitesse se cumulent entre eux
            myTank.speedFactor = myTank.speedFactor * myObstacle.speedRatio
        end
    end

    -- Calculs de collision
    newcollider.ManageCollision = function (myMissiles, myObstacles, myTanks)
        -- Gestion des missiles
        for i, myMissile in pairs(myMissiles) do
            
            -- Est-ce que le missile actif rencontre un obstacle
            if myMissile.exploded == false then
                for i, myObstacle in ipairs(myObstacles) do
                    if myObstacle.stopMissile == true then
                        newcollider.ManageMissileObstacleCollision(myMissile, myObstacle)
                        if myMissile.exploded == true then
                            break
                        end
                    end
                end
            end
            
            if myMissile.exploded == false then
                -- Est-ce que le missile rencontre un tank
                for i, myTank in ipairs(myTanks) do
                    newcollider.ManageMissileTankCollision(myMissile, myTank)
                    if myMissile.exploded == true then
                        break
                    end
                end
            else
                -- Est-ce que l'explosion rencontre un tank
                if myMissile.explosionDamageDone == false then
                    for i, myTank in ipairs(myTanks) do
                        newcollider.ManageExplosionTankCollision(myMissile, myTank)
                    end
                    myMissile.explosionDamageDone = true
                end
            end

            -- TODO, Est-ce que le missile rencontre un autre missile ?
        end

        -- Gestion des tanks
        for i, myTank in pairs(myTanks) do

            -- On en traite que les tanks actifs
            if myTank.outDated == false then
                
                local tankStopped = myTank.vector.x == 0 and myTank.vector.y == 0
                myTank.speedFactor = 1

                if tankStopped == false then
                    -- Est-ce que le tank rencontre un obstacle
                    for i, myObstacle in ipairs(myObstacles) do
                        tankStopped = newcollider.ManageTankObstacleCollision(myTank, myObstacle)
                        if tankStopped == true then
                            break
                        end
                    end
                end

                if tankStopped == false then
                    -- Est-ce que le tank rencontre un tank
                    for i, myOtherTank in ipairs(myTanks) do
                        if myOtherTank ~= myTank then
                            tankStopped = newcollider.ManageTankTankCollision(myOtherTank, myTank)
                        end
                    end
                end

                if tankStopped == false then
                    -- Récupération de la dalle du tank
                    local colonne = math.floor(myTank.x / myTank.game.map.constantes.tiles.size.x) + 1 
                    local ligne = math.floor(myTank.y / myTank.game.map.constantes.tiles.size.y) + 1  
                    local tile = myTank.game.map.tiles[ligne * myTank.game.map.constantes.tiles.number.x + colonne]
                    if myTank.game.map.modifiers[tile] ~= nil then
                        myTank.speedFactor = myTank.speedFactor * myTank.game.map.modifiers[tile]
                    end
                    
                    -- On applique les changements de vitesse
                    myTank.maxSpeed = myTank.speedFactor * myTank.maxSpeedLimit
                end
            end
        end
    end

    return newcollider
end