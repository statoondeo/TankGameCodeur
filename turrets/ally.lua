-- Factory à tourelles
function createAllyTurret(myGame, myTurretSkin, myTank)
    local newTurret = createBaseTurret(myGame, myTurretSkin, myTank)

    -- Comportement spécifique
    newTurret.initialDamage = newTurret.damage
    newTurret.damage = function (damages)
        newTurret.initialDamage()
    end

    -- Comportement spécifique
    newTurret.initialUpdate = newTurret.update;
    newTurret.update = function (dt)
        newTurret.initialUpdate(dt)
        local mouse = {}
        mouse.x, mouse.y = love.mouse.getPosition()
        if newTurret.tank.isFired == false then
            newTurret.angle = math.atan2(
                mouse.y - newTurret.game.offset.y - newTurret.y, 
                mouse.x - newTurret.game.offset.x - newTurret.x)
        end
    end

    -- Comportement spécifique
    newTurret.initialDraw = newTurret.draw;
    newTurret.draw = function ()
        newTurret.initialDraw()
    end

    return newTurret
end
