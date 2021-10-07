local this = {}

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    local newTurret = modules.turret.createNew(myTurretSkin, myTank)
    newTurret.module = this
    return newTurret
end

-- Comportement spécifique
function this.updateTurret(dt, myTurret, mouse)
    if myTurret.tank.isFired == false then
        myTurret.angle = math.atan2(mouse.y - modules.game.offset.y - myTurret.y, mouse.x - modules.game.offset.x - myTurret.x)
    end
end

-- Draw spécifique
function this.drawTurret(myTurret)
end

return this