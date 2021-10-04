local this = {}

this.constantes = {}

-- Tir en rafale
this.constantes.mode = 3
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
this.constantes.childMode = 1
this.constantes.fire = {}
this.constantes.fire.speed = 20
this.constantes.fire.frame = 5
this.constantes.fire.zoom = 1.8

-- Factory à missiles
function this.create(myTank)
    local myMissile = modules.missile.createNewMissile(this.constantes.mode, myTank)
    this.init(myMissile)
    return (myMissile)
end

-- Initialisations spécifiques au type de missile
function this.init(myMissile)
    myMissile.module = this
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
    myMissile.fireTtl = 0
    myMissile.octave = 1
    myMissile.reload = this.constantes.reload
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.fireImages[1] = modules.missile.images.fires[1]
    myMissile.fireImages[2] = modules.missile.images.fires[3]
    myMissile.fireImages[3] = myMissile.fireImages[1]
    myMissile.fireImages[4] = myMissile.fireImages[2]
    myMissile.fireImages[5] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.fire.speed
    myMissile.fireZoom = this.constantes.fire.zoom 

    table.insert(modules.missile.missiles, myMissile)
end

function this.createChild(myMissile, index)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.childMode)

    -- Gestion du zoom des obus de la rafale
    newMissile.explosionZoom = (this.constantes.maxExplosionZoom - this.constantes.minExplosionZoom) * index / this.constantes.nbStep + this.constantes.minExplosionZoom

    -- Gestion du scope des obus de la rafale (chaque obus à une portée plus longue)
    newMissile.scope = (this.constantes.maxScope - this.constantes.minScope) * index / this.constantes.nbStep + this.constantes.minScope

    -- Gestion du ttl des obus de la rafale (chaque obus à un ttl plus long)
    newMissile.initialTtl = (this.constantes.maxTtl - this.constantes.minTtl) * index / this.constantes.nbStep + this.constantes.minTtl
    newMissile.ttl = newMissile.initialTtl
    newMissile.octave = myMissile.octave

    if index % 2 == 0 then
        modules.missile.updateFireSound(newMissile)
    end
    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
end

function this.update(dt, myMissile)
    myMissile.step = myMissile.step + 1
    if myMissile.step <= this.constantes.nbStep then
        this.createChild(myMissile, myMissile.step)
    end
end

function this.draw(myMissile)
end

return this