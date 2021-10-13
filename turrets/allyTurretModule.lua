local this = {}

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    local newTurret = game.turret.createNew(myTurretSkin, myTank)
    newTurret.module = this
    return newTurret
end

-- Comportement spécifique
function this.updateTurret(dt, myTurret, mouse)
    if myTurret.tank.isFired == false then
        myTurret.angle = math.atan2(mouse.y - game.offset.y - myTurret.y, mouse.x - game.offset.x - myTurret.x)
    end
end

-- Draw spécifique
function this.drawTurret(myTurret)
end

return this