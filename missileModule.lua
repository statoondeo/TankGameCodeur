local this = {}

this.constantes = {}

-- tir de base 
this.constantes.base = {}
this.constantes.base.mode = 1
this.constantes.base.scope = 350
this.constantes.base.reload = 0.5
this.constantes.base.explosionZoom = 1
this.constantes.base.ttl = 1
this.constantes.base.easing = modules.tweening.easingOutCirc

-- Tir groupé
this.constantes.gun = {}
this.constantes.gun.mode = 2
this.constantes.gun.scope = 350
this.constantes.gun.minScope = 250
this.constantes.gun.maxScope = 325
this.constantes.gun.reload = 0.5
this.constantes.gun.explosionZoom = 1
this.constantes.gun.ttl = 1
this.constantes.gun.angleAmplitude = math.pi / 24
this.constantes.gun.nbChild = 5
this.constantes.gun.delay = 0.2
this.constantes.gun.easing = modules.tweening.easingOutCirc
this.constantes.gun.childMode = this.constantes.base.mode
this.constantes.gun.fire = {}
this.constantes.gun.fire.speed = 20
this.constantes.gun.fire.zoom = 1.3

-- Tir en rafale
this.constantes.rafale = {}
this.constantes.rafale.mode = 3
this.constantes.rafale.minScope = 50
this.constantes.rafale.maxScope = 350
this.constantes.rafale.intervalScope = 25
this.constantes.rafale.reload = 1
this.constantes.rafale.minExplosionZoom = 0.75
this.constantes.rafale.maxExplosionZoom = 1.5
this.constantes.rafale.minTtl = 0.5
this.constantes.rafale.maxTtl = 1.5
this.constantes.rafale.nbStep = (this.constantes.rafale.maxScope - this.constantes.rafale.minScope) / this.constantes.rafale.intervalScope
this.constantes.rafale.easing = modules.tweening.easingOutCirc
this.constantes.rafale.delay = 0.2
this.constantes.rafale.childMode = this.constantes.base.mode
this.constantes.rafale.fire = {}
this.constantes.rafale.fire.speed = 20
this.constantes.rafale.fire.frame = 5
this.constantes.rafale.fire.zoom = 1.8

-- Tir explosif
this.constantes.rebound = {}
this.constantes.rebound.mode = 4
this.constantes.rebound.scope = 450
this.constantes.rebound.number = 8
this.constantes.rebound.reload = 1.5
this.constantes.rebound.minScope = 10
this.constantes.rebound.maxScope = 100
this.constantes.rebound.explosionZoom = 2
this.constantes.rebound.ttl = 2
this.constantes.rebound.easing = modules.tweening.easingInExpo
this.constantes.rebound.fire = {}
this.constantes.rebound.fire.speed = 25
this.constantes.rebound.fire.zoom = 1.8
this.constantes.rebound.childMode = this.constantes.base.mode

-- Explosion
this.constantes.explosion = {}
this.constantes.explosion.speed = 12
this.constantes.explosion.frame = 5

-- Missiles
this.constantes.missile = {}
this.constantes.missile.frame = 3

-- Tirs
this.constantes.fire = {}
this.constantes.fire.frame = 4

-- Ressources
this.images = {}
this.images.explosions = {}
this.images.fires = {}
this.images.missiles = {}
this.sounds = {}
this.sounds.explosions = {}
this.sounds.shots = {}

-- Stockage des missiles créés
this.missiles = {}

this.missilesModules = {}

-- Pour le chargement du module
function this.load()
    -- Chargement des ressources
    -- Sons
    table.insert(this.sounds.explosions, love.audio.newSource("sounds/explosion.mp3", "static"))
    -- Missiles
    for i = 1, this.constantes.missile.frame do
        this.images.missiles[i] = love.graphics.newImage("images/missile_" .. i .. ".png")
    end
    -- Explosion
    for i = 1, this.constantes.explosion.frame do
        this.images.explosions[i] = love.graphics.newImage("images/explosion_" .. i .. ".png")
    end
    -- tirs
    for i = 1, this.constantes.fire.frame do
        this.images.fires[i] = love.graphics.newImage("images/shot_" .. i .. ".png")
    end
    this.sounds.shots[1] = love.audio.newSource("sounds/shot.wav", "static")
end

-- Factory à missiles
function this.create(myTank, myMissileMode)
    local myMissile = this.createNewMissile(myMissileMode, myTank)
    if myMissileMode == this.constantes.base.mode then
        this.initBase(myMissile)
    elseif myMissileMode == this.constantes.gun.mode then
        this.initGun(myMissile)
    elseif myMissileMode == this.constantes.rafale.mode then
        this.initRafale(myMissile)
    elseif myMissileMode == this.constantes.rebound.mode then
        this.initRebound(myMissile)
    end
    return (myMissile)
end

-- Création d'un missile
function this.createNewMissile(myMissileMode, myTank)
    local myMissile = {}
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
    myMissile.hitBox = modules.hitbox.create(modules.hitbox.constantes.circleType)
    myMissile.hitBox.x = myMissile.x
    myMissile.hitBox.y = myMissile.y
    myMissile.ExplosionSoundStarted = false   
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    return myMissile
end

function this.initBase(myMissile)
    -- Initialisations spécifiques au type demandé
    myMissile.explosionZoom = this.constantes.base.explosionZoom
    myMissile.initialTtl = this.constantes.base.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = this.constantes.base.scope
    myMissile.easing = this.constantes.base.easing
    myMissile.image = this.images.missiles[1]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitBox.radius = myMissile.image:getWidth() / 2
    myMissile.fireSoundStarted = true
    myMissile.octave = 2
    myMissile.reload = this.constantes.base.reload
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
end

-- Initialisations spécifiques au type de missile
function this.initGun(myMissile)
    -- Initialisations spécifiques au type demandé
    myMissile.hitBox.type = modules.hitbox.constantes.noneType
    myMissile.step = 0    
    myMissile.initialTtl = this.constantes.gun.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.easing = this.constantes.gun.easing
    myMissile.scope = this.constantes.gun.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.fireImages[1] = modules.missile.images.fires[1]
    myMissile.fireImages[2] = modules.missile.images.fires[2]
    myMissile.fireImages[3] = myMissile.fireImages[1]
    myMissile.fireImages[4] = myMissile.fireImages[2]
    myMissile.fireImages[5] = myMissile.fireImages[1]
    myMissile.fireImages[6] = myMissile.fireImages[2]
    myMissile.fireImages[7] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.gun.fire.speed
    myMissile.fireZoom = this.constantes.gun.fire.zoom 
    myMissile.fireSoundStarted = false
    myMissile.octave = 2
    myMissile.reload = this.constantes.gun.reload
    table.insert(modules.missile.missiles, myMissile)
    local newMissile
    for i = 1, this.constantes.gun.nbChild do
        newMissile = this.createGunChildMissile(myMissile)
    end
    newMissile.angle = myMissile.angle
    newMissile.scope = this.constantes.gun.scope
end

-- Initialisations spécifiques au type de missile
function this.initRafale(myMissile)
    myMissile.hitBox.type = modules.hitbox.constantes.noneType
    myMissile.step = 0    
    myMissile.initialTtl = this.constantes.rafale.maxTtl
    myMissile.ttl = myMissile.initialTtl
    myMissile.easing = this.constantes.rafale.easing
    myMissile.scope = this.constantes.rafale.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.fireTtl = 0
    myMissile.octave = 1
    myMissile.reload = this.constantes.rafale.reload
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.fireImages[1] = modules.missile.images.fires[1]
    myMissile.fireImages[2] = modules.missile.images.fires[3]
    myMissile.fireImages[3] = myMissile.fireImages[1]
    myMissile.fireImages[4] = myMissile.fireImages[2]
    myMissile.fireImages[5] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.rafale.fire.speed
    myMissile.fireZoom = this.constantes.rafale.fire.zoom 

    for i = 1, this.constantes.rafale.nbStep do
        this.createRafaleChildMissile(myMissile, i)
    end
    table.insert(modules.missile.missiles, myMissile)
end

-- Génération d'un missile explosif
function this.initRebound(myMissile)
    -- Initialisation spécifiques au type demandé
    myMissile.explosionZoom = this.constantes.rebound.explosionZoom
    myMissile.initialTtl = this.constantes.rebound.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = this.constantes.rebound.scope
    myMissile.easing = this.constantes.rebound.easing
    myMissile.image = this.images.missiles[3]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitBox.radius = myMissile.image:getWidth() / 2
    myMissile.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireSoundStarted = false
    myMissile.octave = 0.5
    myMissile.reload = this.constantes.rebound.reload
    myMissile.fireImages = {}
    myMissile.fireImages[1] = modules.missile.images.fires[1]
    myMissile.fireImages[2] = modules.missile.images.fires[2]
    myMissile.fireImages[3] = modules.missile.images.fires[3]
    myMissile.fireImages[4] = modules.missile.images.fires[4]
    myMissile.fireImages[5] = myMissile.fireImages[4]
    myMissile.fireImages[6] = myMissile.fireImages[3]
    myMissile.fireImages[7] = myMissile.fireImages[2]
    myMissile.fireImages[8] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.rebound.fire.speed
    myMissile.fireZoom = this.constantes.rebound.fire.zoom 
    table.insert(modules.missile.missiles, myMissile)
end

-- Génération de missile de replique du missile explosif
function this.createReboundChildMissile(myMissile, index)
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.rebound.childMode)

    newMissile.scope = love.math.random(this.constantes.rebound.minScope, this.constantes.rebound.maxScope)
    newMissile.initialTtl = newMissile.scope / this.constantes.rebound.maxScope * newMissile.initialTtl
    newMissile.ttl = newMissile.initialTtl
    newMissile.angle = 2 * math.pi / this.constantes.rebound.number * index
    newMissile.initialx = myMissile.x
    newMissile.initialy = myMissile.y
    newMissile.hitBox.x = newMissile.initialxx
    newMissile.hitBox.y = newMissile.initialy

    table.insert(modules.missile.missiles, newMissile)
end

function this.createGunChildMissile(myMissile)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.gun.childMode)

    -- Gestion du scope des obus de la rafale
    newMissile.scope = math.prandom(this.constantes.gun.minScope, this.constantes.gun.maxScope)

    -- Gestion du angle des obus de la rafale
    newMissile.angle = math.prandom(myMissile.angle - this.constantes.gun.angleAmplitude, myMissile.angle + this.constantes.gun.angleAmplitude)

    -- Gestion du ttl des obus de la rafale
    newMissile.initialTtl = newMissile.scope / this.constantes.gun.scope * this.constantes.gun.ttl
    newMissile.ttl = newMissile.initialTtl

    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
    this.updateFireSound(myMissile)
    return newMissile
end

function this.createRafaleChildMissile(myMissile, index)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.rafale.childMode)

    -- Gestion du zoom des obus de la rafale
    newMissile.explosionZoom = (this.constantes.rafale.maxExplosionZoom - this.constantes.rafale.minExplosionZoom) * index / this.constantes.rafale.nbStep + this.constantes.rafale.minExplosionZoom

    -- Gestion du scope des obus de la rafale (chaque obus à une portée plus longue)
    newMissile.scope = (this.constantes.rafale.maxScope - this.constantes.rafale.minScope) * index / this.constantes.rafale.nbStep + this.constantes.rafale.minScope

    -- Gestion du ttl des obus de la rafale (chaque obus à un ttl plus long)
    newMissile.initialTtl = (this.constantes.rafale.maxTtl - this.constantes.rafale.minTtl) * index / this.constantes.rafale.nbStep + this.constantes.rafale.minTtl
    newMissile.ttl = newMissile.initialTtl
    newMissile.octave = myMissile.octave

    if index % 2 == 0 then
        this.updateFireSound(newMissile)
    end
    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
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
    if this.sounds.explosions[1]:isPlaying() then
        this.sounds.explosions[1]:stop()
    end
    this.sounds.explosions[1]:setPitch(myMissile.octave)
    this.sounds.explosions[1]:play()
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

        if myMissile.mode == this.constantes.base.mode then
        elseif myMissile.mode == this.constantes.gun.mode then
        elseif myMissile.mode == this.constantes.rafale.mode then
        elseif myMissile.mode == this.constantes.rebound.mode then
            this.updateRebound(dt, myMissile)
        end
    end
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
        -- On accorde la hitbox
        myMissile.hitBox.x = myMissile.x
        myMissile.hitBox.y = myMissile.y
    end
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

function this.updateRebound(dt, myMissile)
    if myMissile.exploded == true then
        -- Le missile géant explose en plusieurs missiles standards après l'explosion classique
        for i = 1, this.constantes.rebound.number do
            
            -- Génération des missiles enfants
            this.createReboundChildMissile(myMissile, i)
        end
    end
end

function this.updateExplosion(dt, myMissile)
    -- Son de l'explosion
    if myMissile.ExplosionSoundStarted == false then
        this.updateExplosionSound(dt, myMissile)
    end

    -- On avance dans l'animation de l'explosion du missile
    myMissile.explosionTimeLife = myMissile.explosionTimeLife + this.constantes.explosion.speed * dt

    -- Est-ce que le missile doit disparaitre (animation d'explosion terminée)
    local frame = math.floor(myMissile.explosionTimeLife) + 1
    if frame > #this.images.explosions then
        myMissile.outDated = true
    else
        if myMissile.hitBox.type ~= modules.hitbox.constantes.noneType then
            myMissile.explosionImage = this.images.explosions[frame]
        end
    end
end

-- En cas de collision, on affiche le missile au point de contact
function this.rewind(myMissile)
    -- On remonte dans le temps pour sortir des obstacles
    myMissile.ttl = myMissile.ttl - 0.1
    local easingFactor = myMissile.easing((myMissile.initialTtl - myMissile.ttl) / myMissile.initialTtl)
    myMissile.x = myMissile.initialx + myMissile.scope * math.cos(myMissile.angle) * easingFactor
    myMissile.y = myMissile.initialy + myMissile.scope * math.sin(myMissile.angle) * easingFactor
    return myMissile.ttl >= 0
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
            myMissile.hitBox.x + modules.battleground.offset.x, 
            myMissile.hitBox.y + modules.battleground.offset.y, 
            myMissile.angle, 
            myMissile.explosionZoom, 
            myMissile.explosionZoom, 
            myMissile.explosionImage:getWidth() / 2, 
            myMissile.explosionImage:getHeight() / 2)
    end
end

function this.drawActiveMissile(myMissile)
    -- Affichage du missile proprement dit
    if myMissile.image ~= nil then
        love.graphics.draw(
            myMissile.image, 
            myMissile.x + modules.battleground.offset.x, 
            myMissile.y + modules.battleground.offset.y, 
            myMissile.angle,
            1,
            1,
            myMissile.center.x, 
            myMissile.center.y)
    end
end

function this.drawFire(myMissile)
    love.graphics.draw(
        myMissile.fireImage, 
        myMissile.tank.turret.output.x + modules.battleground.offset.x, 
        myMissile.tank.turret.output.y + modules.battleground.offset.y, 
        myMissile.angle, 
        myMissile.fireZoom, 
        myMissile.fireZoom, 
        0, 
        myMissile.fireImage:getHeight() / 2)
end

-- Affichage d'un missile
function this.drawMissile(myMissile)
    if myMissile.exploded then
        this.drawExplosion(myMissile)
    else
        if myMissile.isFired == true then
            this.drawFire(myMissile)
        else
            this.drawActiveMissile(myMissile)
        end
    end
end

return this