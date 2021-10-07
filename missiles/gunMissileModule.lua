local this = {}

this.constantes = {}

-- Tir groupé
this.constantes.mode = 2
this.constantes.scope = 250
this.constantes.minScope = 150
this.constantes.maxScope = 200
this.constantes.reload = 0.5
this.constantes.explosionZoom = 1.1
this.constantes.ttl = 1
this.constantes.angleAmplitude = math.pi / 24
this.constantes.nbChild = 2
this.constantes.delay = 0.2
this.constantes.easing = modules.tweening.easingOutCirc
this.constantes.childMode = 1
this.constantes.fire = {}
this.constantes.fire.speed = 20
this.constantes.fire.zoom = 1.3
this.constantes.damage = {}
this.constantes.damage.missile = 110
this.constantes.damage.explosion = 55

-- Factory à missiles
function this.create(myTank)
    local myMissile = modules.missile.createNewMissile(this.constantes.mode, myTank)
    this.init(myMissile)
    return (myMissile)
end

-- Initialisations spécifiques au type de missile
function this.init(myMissile)
    -- Initialisations spécifiques au type demandé
    myMissile.module = this
    myMissile.step = 0    
    myMissile.initialTtl = this.constantes.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.explosionZoom = this.constantes.explosionZoom
    myMissile.image = modules.missile.images.missiles[1]
    myMissile.easing = this.constantes.easing
    myMissile.scope = this.constantes.maxScope
    myMissile.center = {}
    myMissile.center.x = 0
    myMissile.center.y = 0
    myMissile.isFired = true
    myMissile.step = 0
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
    myMissile.fireSpeed = this.constantes.fire.speed
    myMissile.fireZoom = this.constantes.fire.zoom 
    myMissile.fireSoundStarted = false
    myMissile.octave = 2
    myMissile.reload = this.constantes.reload
    myMissile.damage = {}
    myMissile.damage.missile = this.constantes.damage.missile
    myMissile.damage.explosion = this.constantes.damage.explosion
    myMissile.explosionHitbox.radius = this.constantes.explosionZoom * modules.missile.images.missiles[1]:getWidth()
    table.insert(modules.missile.missiles, myMissile)
end

function this.createChild(myMissile)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.childMode)

    -- Gestion du scope des obus de la rafale
    newMissile.scope = math.prandom(this.constantes.minScope, this.constantes.maxScope)

    -- Gestion du angle des obus de la rafale
    newMissile.angle = math.prandom(myMissile.angle - this.constantes.angleAmplitude, myMissile.angle + this.constantes.angleAmplitude)

    -- Gestion du ttl des obus de la rafale
    newMissile.initialTtl = newMissile.scope / this.constantes.scope * this.constantes.ttl
    newMissile.ttl = newMissile.initialTtl

    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
    modules.missile.updateFireSound(myMissile)
    return newMissile
end

function this.update(dt, myMissile)
    myMissile.step = myMissile.step + 1
    if myMissile.step <= this.constantes.nbChild then
        this.createChild(myMissile)
    end
end

function this.draw(myMissile)
end

return this