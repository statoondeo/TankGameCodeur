local this = {}

this.constantes = {}
-- TODO Le point d'accroche de la tourelle n'est pas à la base
this.constantes.offset = {}
this.constantes.offset.x = 0
this.constantes.offset.y = 0
this.constantes.angleAcceleration = 1
this.constantes.skins = {}
this.constantes.skins.count = 6
-- this.constantes.fireAnimationImagesCount = 2
-- this.constantes.fireAnimation = {}
-- this.constantes.fireAnimation.shotLarge = 6
-- this.constantes.fireAnimation.shotThin = 4
this.constantes.detectionDelay = 1
this.constantes.detectionRangeFactor = 10
this.images = {}
this.images.turrets = {}
-- this.images.fires = {}
-- this.sounds = {}
-- this.sounds.shots = {}

this.turrets = {}

function this.load()
    -- Chargement des ressources
    for i = 1, this.constantes.skins.count do
        this.images.turrets[i] = love.graphics.newImage("images/turret_" .. i .. ".png")
    end
    -- for i = 1, this.constantes.fireAnimationImagesCount do
    --     this.images.fires[i] = love.graphics.newImage("images/shot" .. i .. ".png")
    -- end
    -- this.sounds.shots[1] = love.audio.newSource("sounds/shot.wav", "static")   
end

-- Factory à tourelles
function this.create(myTurretSkin)
    local newTurret = {}
    newTurret.skin = myTurretSkin
    newTurret.image = this.images.turrets[newTurret.skin]
    newTurret.tank = myTank
    newTurret.lastShot = 0
    newTurret.angle = love.math.random(2 * math.pi)
    newTurret.x = newTurret.tank.turretAnchor.x + this.constantes.offset.x
    newTurret.y = newTurret.tank.turretAnchor.y + this.constantes.offset.y
    newTurret.center = {}
    -- TODO : Le point de rotation de la tourelle n'est pas sa base
    newTurret.center.x = this.constantes.offset.x
    newTurret.center.y = newTurret.image:getHeight() / 2
    newTurret.output = {}
    newTurret.output.x = newTurret.x + math.cos(newTurret.angle) * newTurret.image:getWidth()
    newTurret.output.y = newTurret.x + math.sin(newTurret.angle) * newTurret.image:getWidth()
    newTurret.isFired = false
    newTurret.fireframe = 0
    local sens = 1
    if love.math.random(2) == 2 then
        sens = -1
    end
    newTurret.speed = this.constantes.angleAcceleration * (love.math.random(10)/10 + 0.5) * sens
    -- Gestion de l'arc de détection
    newTurret.arc = {}
    newTurret.arc.colorR = 0
    newTurret.arc.colorG = 0
    newTurret.arc.colorB = 0
    newTurret.arc.amplitude = 0
    newTurret.arc.radius = 0
    newTurret.arc.x = 0
    newTurret.arc.y = 0
    newTurret.arc.angle = 0
    newTurret.arc.detectionDelay = 0    
    table.insert(this.turrets, newTurret)
    return newTurret
end

-- Comportement de la tourelle du joueur
function this.updateAlly(dt, myTurret, mouse)
    myTurret.angle = math.atan2(mouse.y - myTurret.y, mouse.x - myTurret.x)
end

-- Comportement de la tourelle de l'ennemi
function this.updateEnnemy(dt, myTurret)
    -- Comportement suivant l'état
    if myTurret.tank.state == 0 then
        -- La tourelle fait la sentinelle
        myTurret.angle = (myTurret.angle + myTurret.speed * dt) % (2 * math.pi)
        myTurret.arc.colorR = 130
        myTurret.arc.colorG = 224
        myTurret.arc.colorB = 170
        myTurret.arc.radius = this.constantes.detectionRangeFactor * myTurret.tank.range
        myTurret.arc.amplitude = math.pi / 3
    elseif myTurret.tank.state == 1 then
        this.updateEnnemyAngle(dt, myTurret)
        myTurret.arc.colorR = 230
        myTurret.arc.colorG = 126
        myTurret.arc.colorB = 34
        myTurret.arc.radius = modules.hitbox.dist(myTurret.arc, myTurret.tank.ennemy.hitBox) + myTurret.tank.ennemy.imageTank:getWidth()
        if myTurret.arc.radius > this.constantes.detectionRangeFactor * myTurret.tank.range then
            myTurret.arc.radius = this.constantes.detectionRangeFactor * myTurret.tank.range
        end
        myTurret.arc.amplitude = math.pi / 6
    elseif myTurret.tank.state == 2 then
        this.updateEnnemyAngle(dt, myTurret)
        myTurret.arc.colorR = 231
        myTurret.arc.colorG = 76
        myTurret.arc.colorB = 60
        myTurret.arc.radius = modules.hitbox.dist(myTurret.arc, myTurret.tank.ennemy.hitBox) + myTurret.tank.ennemy.imageTank:getWidth()
        if myTurret.arc.radius > this.constantes.detectionRangeFactor * myTurret.tank.range then
            myTurret.arc.radius = this.constantes.detectionRangeFactor * myTurret.tank.range
        end
        myTurret.arc.amplitude = math.pi / 36
    end
    myTurret.arc.x =  myTurret.output.x
    myTurret.arc.y =  myTurret.output.y
    myTurret.arc.angle = myTurret.angle
    myTurret.arc.radius = myTurret.arc.radius - myTurret.tank.imageTank:getWidth() / 2
    myTurret.arc.detectionDelay = myTurret.arc.detectionDelay - dt
    if myTurret.arc.detectionDelay <= 0 then
        myTurret.arc.detectionDelay = 0
    end
end

function this.updateEnnemyAngle(dt, myTurret)
    -- La tourelle se tourne vers le joueur
    local angle = math.atan2(myTurret.tank.ennemy.y - myTurret.tank.y, myTurret.tank.ennemy.x - myTurret.tank.x) % (2 * math.pi)
    if math.abs(angle - myTurret.angle) >= this.constantes.angleAcceleration * dt then
        if myTurret.angle - angle >= 0 then
            myTurret.angle = (myTurret.angle - myTurret.speed * dt) % (2 * math.pi)
        else
            myTurret.angle = (myTurret.angle + myTurret.speed * dt) % (2 * math.pi)
        end
    end   
end

function this.updateData(dt, myTurret)
    myTurret.lastShot = myTurret.lastShot - dt
    myTurret.x = myTurret.tank.turretAnchor.x + math.cos(myTurret.angle) * modules.turret.constantes.offset.x
    myTurret.y = myTurret.tank.turretAnchor.y + math.sin(myTurret.angle) * modules.turret.constantes.offset.y
    myTurret.output.x = myTurret.x + math.cos(myTurret.angle) * myTurret.image:getWidth()
    myTurret.output.y = myTurret.y + math.sin(myTurret.angle) * myTurret.image:getWidth()
    if myTurret.isFired then
        myTurret.fireframe = myTurret.fireframe + 1
        if myTurret.fireframe > (modules.turret.constantes.fireAnimation.shotLarge + modules.turret.constantes.fireAnimation.shotThin) then
            myTurret.isFired = false
        end
    end
end

function this.update(dt, myTurret, mouse)
    -- Mise à jour des infos de la tourelle
    this.updateData(dt, myTurret)
    
    if myTurret.tank.mode == modules.tank.constantes.modes.player then
        -- Gestion du joueur
        this.updateAlly(dt, myTurret, mouse)
    else
        -- Gestion de l'ennemy
        this.updateEnnemy(dt, myTurret)
    end
end

function this.draw(myTurret, myOffset, showHitBox)
    -- Affichage de la tourelle
    love.graphics.draw(myTurret.image, myTurret.x + myOffset.x, myTurret.y + myOffset.y, myTurret.angle, 1, 1, myTurret.center.x, myTurret.center.y)
    if myTurret.isFired == true then
        if myTurret.fireframe <= this.constantes.fireAnimation.shotLarge then
            love.graphics.draw(this.images.fires[1], myTurret.output.x + myOffset.x, myTurret.output.y + myOffset.y, myTurret.angle, 1, 1, 0, this.images.fires[1]:getHeight() / 2)
        else
            love.graphics.draw(this.images.fires[2], myTurret.output.x + myOffset.x, myTurret.output.y + myOffset.y, myTurret.angle, 1, 1, 0, this.images.fires[2]:getHeight() / 2)
        end
    end

    -- Affichage du champ de détection
    if myTurret.tank.mode == modules.tank.constantes.modes.ennemy then
        love.graphics.setColor(myTurret.arc.colorR/255, myTurret.arc.colorG/255, myTurret.arc.colorB/255, 0.5)
        love.graphics.arc("fill", myTurret.output.x + myOffset.x, myTurret.output.y + myOffset.y, myTurret.arc.radius, myTurret.angle - myTurret.arc.amplitude, myTurret.angle + myTurret.arc.amplitude)
        love.graphics.setColor(255, 255, 255)
    end
end

function this.fire(myTurret)
    if myTurret.lastShot <= 0 then
        myTurret.isFired = true;
        myTurret.fireframe = 0

        -- Gestion du missile
        modules.missile.create(myTurret.tank)
        if myTurret.mode == modules.turret.constantes.standardMode then
            myTurret.lastShot = modules.turret.constantes.standardModeFireLimit
        elseif myTurret.mode == modules.turret.constantes.quickMode then
            myTurret.lastShot = modules.turret.constantes.quickModeFireLimit
        elseif myTurret.mode == modules.turret.constantes.giantMode then
            myTurret.lastShot = modules.turret.constantes.giantModeFireLimit
        end

        -- Gestion du son

        if this.sounds.shots[1]:isPlaying() then
            this.sounds.shots[1]:stop()
        end
        this.sounds.shots[1]:play()
    end
end

return this