local this = {}

this.constantes = {}

-- Tir en rafale
this.constantes.mode = 3
this.constantes.minScope = 50
this.constantes.maxScope = 350
this.constantes.intervalScope = 25
this.constantes.reload = 1
this.constantes.explosionZoom = 1.5
this.constantes.ttl = 2
this.constantes.nbStep = 0.25
this.constantes.easing = modules.tweening.easingLin
this.constantes.delay = 0.2
this.constantes.childMode = 1
this.constantes.fire = {}
this.constantes.fire.speed = 20
this.constantes.fire.frame = 5
this.constantes.fire.zoom = 1.8
this.constantes.childMinScope = 40
this.constantes.childMaxScope = 120
this.constantes.damage = {}
this.constantes.damage.missile = 150
this.constantes.damage.explosion = 75

-- Factory à missiles
function this.create(myTank)
    local myMissile = modules.missile.createNewMissile(this.constantes.mode, myTank)
    this.init(myMissile)
    return (myMissile)
end

-- Initialisations spécifiques au type de missile
function this.init(myMissile)
    myMissile.module = this
    myMissile.image = modules.missile.images.missiles[2]
    myMissile.explosionZoom = this.constantes.explosionZoom
    myMissile.step = 0    
    myMissile.initialTtl = this.constantes.ttl
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
    myMissile.lastShot = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
    myMissile.fireImages[1] = modules.missile.images.fires[1]
    myMissile.fireImages[2] = modules.missile.images.fires[3]
    myMissile.fireImages[3] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.fire.speed
    myMissile.fireZoom = this.constantes.fire.zoom 
    myMissile.fireSoundStarted = false
    myMissile.damage = {}
    myMissile.damage.missile = this.constantes.damage.missile
    myMissile.damage.explosion = this.constantes.damage.explosion
    myMissile.explosionHitbox.radius = this.constantes.explosionZoom * modules.missile.images.missiles[1]:getWidth()
    table.insert(modules.missile.missiles, myMissile)
end

function this.createChild(myMissile, index)
    -- Création et initialisation du nouveau missile
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.childMode)

    newMissile.scope = love.math.random(this.constantes.childMinScope, this.constantes.childMaxScope)
    newMissile.initialTtl = newMissile.scope / this.constantes.maxScope * newMissile.initialTtl
    newMissile.ttl = newMissile.initialTtl
    newMissile.angle = love.math.random(0, 2 * math.pi)
    newMissile.initialx = myMissile.x
    newMissile.initialy = myMissile.y
    newMissile.hitBox.x = newMissile.initialx
    newMissile.hitBox.y = newMissile.initialy
    modules.missile.updateFireSound(newMissile)

    -- Ajout à la collection de missiles
    table.insert(modules.missile.missiles, newMissile)
end

function this.update(dt, myMissile)
    if myMissile.exploded == false then
        myMissile.lastShot = myMissile.lastShot + dt
        if myMissile.lastShot >= this.constantes.nbStep then
            myMissile.lastShot = 0
            myMissile.step = myMissile.step + 1
            for i = 1, myMissile.step do
                this.createChild(myMissile, myMissile.step)           
            end
        end
    end
end

function this.draw(myMissile)
end

return this