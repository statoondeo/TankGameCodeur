local this = {}

this.constantes = {}

-- Mode de tir
this.constantes.mode = 3

-- Tir en rafale
this.constantes.minScope = 50
this.constantes.maxScope = 350
this.constantes.intervalScope = 25
this.constantes.reload = 1
this.constantes.minExplosionZoom = 0.75
this.constantes.maxExplosionZoom = 1.5
this.constantes.minTtl = 0.5
this.constantes.maxTtl = 1.5
this.constantes.nbStep = (this.constantes.maxScope - this.constantes.minScope) / this.constantes.intervalScope
this.constantes.easing = modules.tweening.easingOutCirc
this.constantes.delay = 0.2

-- tir
this.constantes.fire = {}
this.constantes.fire.speed = 20
this.constantes.fire.frame = 5
this.constantes.fire.zoom = 1.8

-- Ressources
this.images = {}
this.images.missiles = {}
this.images.fires = {}
this.sounds = {}
this.sounds.shots = {}

-- Stockage des missiles créés
this.missiles = {}

-- Pour le chargement du module
function this.load()
    -- Chargement des ressources
    this.images.missiles[1] = modules.missile.images.missiles[2]
    this.images.fires[1] = modules.missile.images.fires[1]
    this.images.fires[2] = modules.missile.images.fires[3]
    this.images.fires[3] = this.images.fires[1]
    this.images.fires[4] = this.images.fires[2]
    this.images.fires[5] = this.images.fires[1]
    this.sounds.shots[1] = modules.missile.sounds.shots[1]
    this.childMissileModule = require("baseMissileModule")
end

function this.createChildMissile(myTank, index)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myTank, this.childMissileModule.constantes.mode)

    -- Gestion du zoom des obus de la rafale
    newMissile.explosionZoom = (this.constantes.maxExplosionZoom - this.constantes.minExplosionZoom) * index / this.constantes.nbStep + this.constantes.minExplosionZoom

    -- Gestion du scope des obus de la rafale (chaque obus à une portée plus longue)
    newMissile.scope = (this.constantes.maxScope - this.constantes.minScope) * index / this.constantes.nbStep + this.constantes.minScope

    -- Gestion du ttl des obus de la rafale (chaque obus à un ttl plus long)
    newMissile.initialTtl = (this.constantes.maxTtl - this.constantes.minTtl) * index / this.constantes.nbStep + this.constantes.minTtl
    newMissile.ttl = (this.constantes.maxTtl - this.constantes.minTtl) * index / this.constantes.nbStep + this.constantes.minTtl

    -- type de déplacement
    newMissile.easing = this.constantes.easing

    this.updateFireSound(0, newMissile)
    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
end

-- Initialisations spécifiques au type de missile
function this.init(myMissile)
    myMissile.hitBox.type = modules.hitbox.constantes.noneType
    myMissile.step = 0    
    myMissile.initialTtl = this.constantes.maxTtl
    myMissile.ttl = myMissile.initialTtl
    myMissile.easing = this.constantes.easing
    myMissile.scope = this.constantes.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.tank.isFired = true
    myMissile.fireTtl = 0
    this.createChildMissile(myMissile.tank, myMissile.step)
end

-- Update spécifique des missiles
function this.update(dt, myMissile)
    this.updateFire(dt, myMissile)
    myMissile.step = myMissile.step + 1
    if myMissile.step > this.constantes.nbStep then
        if myMissile.isFired == false then
            myMissile.outDated = true
        end
    else
        this.createChildMissile(myMissile.tank, myMissile.step)
    end
end

function this.updateFireSound(dt, myMissile)
    -- Son d'explosion du missile si pas encore fait
    if this.sounds.shots[1]:isPlaying() then
        this.sounds.shots[1]:stop()
    end
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

function this.drawFire(myMissile)
    if myMissile.tank.isFired == true then -- and myMissile.fireFrame <= this.constantes.fire.frame then
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

-- Affichage spécifique des missiles
function this.draw(myMissile)
    this.drawFire(myMissile)
end

return this