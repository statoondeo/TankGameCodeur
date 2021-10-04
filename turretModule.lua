local this = {}

this.constantes = {}

-- Point de pivot de la tourelle
this.constantes.offset = {}
this.constantes.offset.x = 8
this.constantes.offset.y = 0
this.constantes.skins = {}
this.constantes.skins.count = 6

this.images = {}
this.images.turrets = {}

this.turrets = {}

function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.skins.count do
        this.images.turrets[i] = love.graphics.newImage("images/turret_" .. i .. ".png")
    end  
end

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    local newTurret = {}
    newTurret.skin = myTurretSkin
    newTurret.image = this.images.turrets[newTurret.skin]
    newTurret.tank = myTank
    newTurret.angle = 0
    newTurret.x = newTurret.tank.turretAnchor.x
    newTurret.y = newTurret.tank.turretAnchor.y
    newTurret.center = {}
    newTurret.center.x = this.constantes.offset.x
    newTurret.center.y = newTurret.image:getHeight() / 2 + this.constantes.offset.y
    newTurret.output = {}
    newTurret.output.x = newTurret.x + math.cos(newTurret.angle) * newTurret.image:getWidth()
    newTurret.output.y = newTurret.x + math.sin(newTurret.angle) * newTurret.image:getHeight()
    return newTurret
end

function this.update(dt, mouse)
    for i, myTurret in ipairs(this.turrets) do
        this.updateTurret(dt, myTurret, mouse)
    end
end

function this.updateTurret(dt, myTurret, mouse)
    myTurret.x = myTurret.tank.turretAnchor.x + math.cos(myTurret.angle)
    myTurret.y = myTurret.tank.turretAnchor.y + math.sin(myTurret.angle)
    if myTurret.tank.isFired == false then
        myTurret.angle = math.atan2(mouse.y - myTurret.y, mouse.x - myTurret.x)
    end
    myTurret.output.x = myTurret.x + math.cos(myTurret.angle) * myTurret.image:getWidth()
    myTurret.output.y = myTurret.y + math.sin(myTurret.angle) * myTurret.image:getWidth()
end

function this.draw()
    for i, myTurret in ipairs(this.turrets) do
        this.drawTurret( myTurret)
    end
end

function this.drawTurret(myTurret)
    -- Affichage de la tourelle
    love.graphics.draw(
        myTurret.image, 
        myTurret.x + modules.battleground.offset.x, 
        myTurret.y +  modules.battleground.offset.y,
        myTurret.angle, 
        1, 
        1, 
        myTurret.center.x, 
        myTurret.center.y)
end

return this