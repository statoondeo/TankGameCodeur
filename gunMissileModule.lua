local this = {}

this.constantes = {}

-- Mode de tir 
this.constantes.mode = 2

-- Tir de base
this.constantes.scope = 350
this.constantes.minScope = 250
this.constantes.maxScope = 325
this.constantes.reload = 0.5
this.constantes.explosionZoom = 1
this.constantes.ttl = 1
this.constantes.angleAmplitude = math.pi / 24
this.constantes.nbChild = 2
this.constantes.delay = 0.2
this.constantes.easing = modules.tweening.easingOutCirc

-- Explosion
this.constantes.explosion = {}
this.constantes.explosion.speed = 12
this.constantes.explosion.frame = 5

-- tir
this.constantes.fire = {}
this.constantes.fire.speed = 20
this.constantes.fire.frame = 7
this.constantes.fire.zoom = 1.3

-- Ressources
this.images = {}
this.images.missiles = {}
this.images.fires = {}
this.sounds = {}
this.sounds.shots = {}

-- Pour le chargement du module
function this.load()
    -- Chargement des ressources
    this.images.missiles[1] = modules.missile.images.missiles[1]
    this.images.fires[1] = modules.missile.images.fires[1]
    this.images.fires[2] = modules.missile.images.fires[2]
    this.images.fires[3] = this.images.fires[1]
    this.images.fires[4] = this.images.fires[2]
    this.images.fires[5] = this.images.fires[1]
    this.images.fires[6] = this.images.fires[2]
    this.images.fires[7] = this.images.fires[1]
    this.sounds.shots[1] = modules.missile.sounds.shots[1]
    this.childMissileModule = require("baseMissileModule")
end

function this.createChildMissile(myTank, myMissile)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myTank, this.childMissileModule.constantes.mode)

    -- Gestion du scope des obus de la rafale
    newMissile.scope = math.prandom(this.constantes.minScope, this.constantes.maxScope)

    -- Gestion du angle des obus de la rafale
    newMissile.angle = math.prandom(myMissile.angle - this.constantes.angleAmplitude, myMissile.angle + this.constantes.angleAmplitude)

    -- Gestion du ttl des obus de la rafale
    newMissile.initialTtl = newMissile.scope / this.constantes.scope * this.constantes.ttl
    newMissile.ttl = newMissile.initialTtl

    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
    this.updateFireSound(0, newMissile)
    return newMissile
end

-- Initialisations spécifiques au type de missile
function this.init(myMissile)
    -- Initialisations spécifiques au type demandé
    myMissile.hitBox.type = modules.hitbox.constantes.noneType
    myMissile.step = 0    
    myMissile.initialTtl = this.constantes.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.easing = this.constantes.easing
    myMissile.scope = this.constantes.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.tank.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireFrame = 1
    myMissile.nbStep = this.constantes.nbChild
    myMissile.stepTtl = this.constantes.delay
    myMissile.fireSoundStarted = false
    local newMissile = this.createChildMissile(myMissile.tank, myMissile)
    newMissile.angle = myMissile.angle
    newMissile.scope = this.constantes.scope
end

function this.updateFireSound(dt, myMissile)
    -- Son d'explosion du missile si pas encore fait
    if this.sounds.shots[1]:isPlaying() then
        this.sounds.shots[1]:stop()
    end
    this.sounds.shots[1]:setPitch(2)
    this.sounds.shots[1]:play()
    myMissile.fireSoundStarted = true
end

function this.updateFire(dt, myMissile)
    if myMissile.isFired == true then
        -- Son de l'explosion
        if myMissile.fireSoundStarted == false then
            this.updateFireSound(dt, myMissile)
        end

        -- On avance dans l'animation du tir
        myMissile.fireTtl = myMissile.fireTtl + this.constantes.fire.speed * dt
        myMissile.fireFrame = math.floor(myMissile.fireTtl) + 1
        -- Est-ce que le tir doit disparaitre
        if myMissile.fireFrame > this.constantes.fire.frame then
            myMissile.isFired = false
            myMissile.tank.isFired = false
        end
    end
end

-- Update spécifique du missile
function this.update(dt, myMissile)
    this.updateFire(dt, myMissile)

    if myMissile.nbStep > 0 then
        myMissile.stepTtl = myMissile.stepTtl - dt
        if myMissile.stepTtl < 0 then
            myMissile.nbStep = myMissile.nbStep - 1
            myMissile.stepTtl = this.constantes.delay
            this.createChildMissile(myMissile.tank, myMissile)
        end
    end
end

function this.drawFire(myMissile)
    if myMissile.isFired == true and myMissile.fireFrame <= this.constantes.fire.frame then
        love.graphics.draw(
            this.images.fires[myMissile.fireFrame], 
            myMissile.tank.turret.output.x + modules.battleground.offset.x, 
            myMissile.tank.turret.output.y + modules.battleground.offset.y, 
            myMissile.angle, 
            this.constantes.fire.zoom, 
            this.constantes.fire.zoom, 
            this.images.fires[myMissile.fireFrame]:getWidth() / 2, 
            this.images.fires[myMissile.fireFrame]:getHeight() / 2)
    end
end

-- Affichage spécifique du missile
function this.drawMissile(myMissile)
    if myMissile.isFired == true then
        this.drawFire(myMissile)
    else
        modules.missile.drawMissile(myMissile)
    end
end

return this