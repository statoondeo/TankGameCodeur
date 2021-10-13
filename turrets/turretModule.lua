local this = {}

this.constantes = {}

-- Point de pivot de la tourelle
this.constantes.offset = {}
this.constantes.offset.x = 8
this.constantes.offset.y = 0
this.constantes.skins = {}
this.constantes.skins.count = 6
this.constantes.emotes = {}
this.constantes.emotes.count = 3
this.constantes.flames = {}
this.constantes.flames.count = 5
this.constantes.flames.speed = 15
this.images = {}
this.images.turrets = {}
this.images.flames = {}
this.images.emotes = {}
this.sounds = {}

this.turrets = {}
this.turretsmodules = {}

function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.skins.count do
        this.images.turrets[i] = love.graphics.newImage("images/turret_" .. i .. ".png")
    end 
    for i = 1, this.constantes.flames.count do
        this.images.flames[i] = love.graphics.newImage("images/flame_" .. i .. ".png")
    end  
    for i = 1, this.constantes.emotes.count do
        this.images.emotes[i] = love.graphics.newImage("images/emote_" .. i .. ".png")
    end  
    this.sounds.alert = love.audio.newSource("sounds/tindeck.mp3", "static")

    -- Chargement des modules
    table.insert(this.turretsmodules, require("turrets/allyTurretModule"))
    table.insert(this.turretsmodules, this.turretsmodules[1])
    table.insert(this.turretsmodules, this.turretsmodules[1])
    table.insert(this.turretsmodules, require("turrets/ennemyTurretModule"))
    table.insert(this.turretsmodules, this.turretsmodules[4])
    table.insert(this.turretsmodules, this.turretsmodules[4])
end

-- Factory à tourelles
function this.create(myTurretSkin, myTank)
    return (this.turretsmodules[myTurretSkin].create(myTurretSkin, myTank))
end

function this.createNew(myTurretSkin, myTank)
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
    newTurret.fireTtl = 0
    newTurret.fireIndex = 0
    newTurret.fireImage = nil
    newTurret.fireImages = {}
    newTurret.fireImages[1] = this.images.flames[1]
    newTurret.fireImages[2] = this.images.flames[2]
    newTurret.fireImages[3] = this.images.flames[3]
    newTurret.fireImages[4] = this.images.flames[4]
    newTurret.fireImages[5] = this.images.flames[5]
    return newTurret
end

function this.update(dt, mouse)
    for i, myTurret in ipairs(this.turrets) do
        this.updateTurret(dt, myTurret, mouse)
    end
end

function this.updateTurret(dt, myTurret, mouse)
    if myTurret.tank.outDated == true then
        -- On avance dans l'animation de feu
        myTurret.fireTtl = myTurret.fireTtl + this.constantes.flames.speed * dt
        myTurret.fireIndex = math.floor(myTurret.fireTtl) + 1

        if myTurret.fireIndex > #myTurret.fireImages then
            myTurret.fireTtl = 0
            myTurret.fireIndex = math.floor(myTurret.fireTtl) + 1
        end
        myTurret.fireImage = myTurret.fireImages[myTurret.fireIndex]
    else
        myTurret.x = myTurret.tank.turretAnchor.x + math.cos(myTurret.angle)
        myTurret.y = myTurret.tank.turretAnchor.y + math.sin(myTurret.angle)
        myTurret.output.x = myTurret.x + math.cos(myTurret.angle) * myTurret.image:getWidth()
        myTurret.output.y = myTurret.y + math.sin(myTurret.angle) * myTurret.image:getWidth()
    end
    myTurret.module.updateTurret(dt, myTurret, mouse)
end

function this.draw()
    for i, myTurret in ipairs(this.turrets) do
        this.drawTurret( myTurret)
    end
end

function this.drawTurret(myTurret)
    if myTurret.tank.outDated == true then
        local sens = 1
        if myTurret.fireIndex >= 3 then
            sens = -1
        end
        -- Affichage de la flamme
        love.graphics.draw(
            myTurret.fireImage, 
            math.floor(myTurret.x + modules.game.offset.x), 
            math.floor(myTurret.y +  modules.game.offset.y),
            0, 
            sens, 
            1, 
            math.floor(myTurret.fireImage:getWidth() / 2), 
            math.floor(myTurret.fireImage:getHeight()))
    else
        -- Affichage de la tourelle
        love.graphics.draw(
            myTurret.image, 
            math.floor(myTurret.x + modules.game.offset.x), 
            math.floor(myTurret.y +  modules.game.offset.y),
            myTurret.angle, 
            1, 
            1, 
            math.floor(myTurret.center.x), 
            math.floor(myTurret.center.y))
    end
    myTurret.module.drawTurret(myTurret)
end

return this