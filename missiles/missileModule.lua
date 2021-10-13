local this = {}

-- Stockage des missiles créés
this.missiles = {}

this.missilesModules = {}

-- Id des missiles
this.nextId = 1

-- Chargement des modules 
table.insert(this.missilesModules, require("missiles/baseMissileModule"))
table.insert(this.missilesModules, require("missiles/gunMissileModule"))
table.insert(this.missilesModules, require("missiles/rafaleMissileModule"))
table.insert(this.missilesModules, require("missiles/reboundMissileModule"))
table.insert(this.missilesModules, this.missilesModules[2])
table.insert(this.missilesModules, this.missilesModules[3])
table.insert(this.missilesModules, this.missilesModules[4])

-- Factory à missiles
function this.create(myTank, myMissileMode)
    return (this.missilesModules[myMissileMode].create(myTank))
end

-- Création d'un missile
function this.createNewMissile(myMissileMode, myTank)
    local myMissile = {}
    myMissile.id = this.nextId
    this.nextId = this.nextId + 1
    myMissile.mode = myMissileMode
    myMissile.tank = myTank
    myMissile.angle = myMissile.tank.turret.angle
    myMissile.initialx = myMissile.tank.turret.output.x
    myMissile.initialy = myMissile.tank.turret.output.y
    myMissile.x = myMissile.initialx
    myMissile.y = myMissile.initialy
    myMissile.exploded = false
    myMissile.explosionTimeLife = 0
    myMissile.outDated = false
    myMissile.hitBox = game.hitbox.create(game.hitbox.constantes.circleType)
    myMissile.hitBox.x = myMissile.x
    myMissile.hitBox.y = myMissile.y
    myMissile.ExplosionSoundStarted = false   
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.explosionImageIndex = 0
    myMissile.explosionDamageDone = false
    myMissile.explosionHitbox = game.hitbox.create(game.hitbox.constantes.circleType)
    return myMissile
end

function this.updateFireSound(myMissile)
    -- Son d'explosion du missile si pas encore fait
    if this.sounds.shots[1]:isPlaying() then
        this.sounds.shots[1]:stop()
    end
    this.sounds.shots[1]:setPitch(myMissile.octave)
    this.sounds.shots[1]:play()
    myMissile.fireSoundStarted = true
end

function this.updateExplosionSound(dt, myMissile)
    -- Son d'explosion du missile si pas encore fait
    game.sounds.explosion:stop()
    game.sounds.explosion:setPitch(myMissile.octave)
    game.sounds.explosion:play()
    myMissile.ExplosionSoundStarted = true
end

-- Update des missiles
function this.update(dt)
    for i, myMissile in ipairs(this.missiles) do
        this.updateMissile(dt, myMissile)
    end

    -- Si des missiles doivent disparaitre on les traite ici
    for i = #this.missiles, 1, -1 do
        if this.missiles[i].outDated == true then
            local myMissile = this.missiles[i]
            table.remove(this.missiles, i)
        end
    end
end

-- Mise à jour des infos du missile
function this.updateMissile(dt, myMissile)
    if myMissile.exploded == true then
        this.updateExplosion(dt, myMissile)
    else
        this.updateFire(dt, myMissile)
        this.updateMovingMissile(dt, myMissile)
    end

    -- Update spécifique au type de missile
    myMissile.module.update(dt, myMissile)
end

function this.updateMovingMissile(dt, myMissile)
    -- Mouvement du missile
    myMissile.ttl = myMissile.ttl - dt

    if (myMissile.ttl <= 0) then
        -- Un missile en bout de course explose
        myMissile.exploded = true
    else
        -- Déplacement du missile
        local easingFactor = myMissile.easing((myMissile.initialTtl - myMissile.ttl) / myMissile.initialTtl)
        myMissile.x = myMissile.initialx + myMissile.scope * math.cos(myMissile.angle) * easingFactor
        myMissile.y = myMissile.initialy + myMissile.scope * math.sin(myMissile.angle) * easingFactor
        -- On accorde les hitbox
        myMissile.hitBox.x = myMissile.x
        myMissile.hitBox.y = myMissile.y
    end
end

function this.updateFireSound(myMissile)
    -- Son d'explosion du missile si pas encore fait
    game.sounds.shot:stop()
    game.sounds.shot:setPitch(myMissile.octave)
    game.sounds.shot:play()
    myMissile.fireSoundStarted = true
end

function this.updateFire(dt, myMissile)
    if myMissile.isFired == true then
        -- Son de l'explosion
        if myMissile.fireSoundStarted == false then
            this.updateFireSound(myMissile)
        end

        -- On avance dans l'animation du tir
        myMissile.fireTtl = myMissile.fireTtl + myMissile.fireSpeed * dt
        myMissile.fireIndex = math.floor(myMissile.fireTtl) + 1

        -- Est-ce que le tir doit disparaitre
        if myMissile.fireIndex > #myMissile.fireImages then
            myMissile.isFired = false
        else
            myMissile.fireImage = myMissile.fireImages[myMissile.fireIndex]
        end
    end
end

function this.updateExplosion(dt, myMissile)
    -- Son de l'explosion
    if myMissile.ExplosionSoundStarted == false then
        this.updateExplosionSound(dt, myMissile)
    end

    -- On avance dans l'animation de l'explosion du missile
    myMissile.explosionTimeLife = myMissile.explosionTimeLife + game.constantes.explosion.speed * dt

    -- Est-ce que le missile doit disparaitre (animation d'explosion terminée)
    myMissile.explosionImageIndex = math.floor(myMissile.explosionTimeLife) + 1
    if myMissile.explosionImageIndex > #game.images.explosions then
        myMissile.outDated = true
    else
        if myMissile.hitBox.type ~= game.hitbox.constantes.noneType then
            myMissile.explosionImage = game.images.explosions[myMissile.explosionImageIndex]
        end
    end
end

-- En cas de collision, on affiche le missile au point de contact
function this.rewind(myMissile)
    -- On remonte dans le temps pour sortir des obstacles
    -- myMissile.ttl = myMissile.ttl - 0.1
    -- local easingFactor = myMissile.easing((myMissile.initialTtl - myMissile.ttl) / myMissile.initialTtl)
    -- myMissile.x = myMissile.initialx + myMissile.scope * math.cos(myMissile.angle) * easingFactor
    -- myMissile.y = myMissile.initialy + myMissile.scope * math.sin(myMissile.angle) * easingFactor
    -- return myMissile.ttl >= 0
    return false
end

-- Affichage des missiles
function this.draw()
    for i, myMissile in ipairs(this.missiles) do

        -- Si le missile est actif
        this.drawMissile(myMissile)
    end
end

-- Affichage de l'explosion
function this.drawExplosion(myMissile)
    if myMissile.explosionImage ~= nil then
        love.graphics.draw(
            myMissile.explosionImage, 
            math.floor(myMissile.hitBox.x + game.offset.x), 
            math.floor(myMissile.hitBox.y + game.offset.y), 
            myMissile.angle, 
            myMissile.explosionZoom, 
            myMissile.explosionZoom, 
            math.floor(myMissile.explosionImage:getWidth() / 2), 
            math.floor(myMissile.explosionImage:getHeight() / 2))
    end
end

function this.drawActiveMissile(myMissile)
    -- Affichage du missile proprement dit
    if myMissile.hitBox.type ~= game.hitbox.constantes.noneType then
        love.graphics.draw(
            myMissile.image, 
            math.floor(myMissile.x + game.offset.x), 
            math.floor(myMissile.y + game.offset.y), 
            myMissile.angle,
            1,
            1,
            math.floor(myMissile.center.x), 
            math.floor(myMissile.center.y))
    end
end

function this.drawFire(myMissile)
    if myMissile.fireImage ~= nil then
        love.graphics.draw(
            myMissile.fireImage, 
            math.floor(myMissile.tank.turret.output.x + game.offset.x), 
            math.floor(myMissile.tank.turret.output.y + game.offset.y), 
            myMissile.angle, 
            myMissile.fireZoom, 
            myMissile.fireZoom, 
            0, 
            math.floor(myMissile.fireImage:getHeight() / 2))
    end
end

-- Affichage d'un missile
function this.drawMissile(myMissile)
    if myMissile.exploded then
        this.drawExplosion(myMissile)
    else
        this.drawActiveMissile(myMissile)
        if myMissile.isFired == true then
            this.drawFire(myMissile)
        end
    end
        
    -- draw spécifique au type de missile
    myMissile.module.draw(myMissile)
end

return this