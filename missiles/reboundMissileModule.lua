local this = {}

this.constantes = {}

-- Tir explosif
this.constantes.mode = 4
this.constantes.scope = 275
this.constantes.number = 16
this.constantes.reload = 1.5
this.constantes.minScope = 25
this.constantes.maxScope = 150
this.constantes.explosionZoom = 2
this.constantes.ttl = 2
this.constantes.easing = game.tweening.easingInExpo
this.constantes.fire = {}
this.constantes.fire.speed = 25
this.constantes.fire.zoom = 1.8
this.constantes.childMode = 1
this.constantes.childDamage = 50
this.constantes.damage = {}
this.constantes.damage.missile = 200
this.constantes.damage.explosion = 100
this.constantes.shake = {}
this.constantes.shake.amplitude = 25
this.constantes.shake.time = 0.25

-- Factory à missiles
function this.create(myTank)
    local myMissile = game.missile.createNewMissile(this.constantes.mode, myTank)
    this.init(myMissile)
    return (myMissile)
end

-- Génération d'un missile explosif
function this.init(myMissile)
    -- Initialisation spécifiques au type demandé
    myMissile.module = this
    myMissile.explosionZoom = this.constantes.explosionZoom
    myMissile.initialTtl = this.constantes.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = this.constantes.scope
    myMissile.easing = this.constantes.easing
    myMissile.image = game.images.missiles[3]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitBox.radius = myMissile.image:getWidth() / 2
    myMissile.isFired = true
    myMissile.tank.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireSoundStarted = false
    myMissile.octave = 0.5
    myMissile.reload = this.constantes.reload
    myMissile.fireImages = {}
    myMissile.fireImages[1] = game.images.fires[1]
    myMissile.fireImages[2] = game.images.fires[2]
    myMissile.fireImages[3] = game.images.fires[3]
    myMissile.fireImages[4] = game.images.fires[4]
    myMissile.fireImages[5] = myMissile.fireImages[4]
    myMissile.fireImages[6] = myMissile.fireImages[3]
    myMissile.fireImages[7] = myMissile.fireImages[2]
    myMissile.fireImages[8] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.fire.speed
    myMissile.fireZoom = this.constantes.fire.zoom 
    myMissile.rocketImage = game.images.fires[1]
    myMissile.damage = {}
    myMissile.damage.missile = this.constantes.damage.missile
    myMissile.damage.explosion = this.constantes.damage.explosion
    myMissile.explosionHitbox.radius = this.constantes.explosionZoom * game.images.missiles[1]:getWidth()
    myMissile.amplitudeShake = this.constantes.shake.amplitude
    myMissile.timeShake = this.constantes.shake.time
    table.insert(game.missile.missiles, myMissile)
end

-- Génération de missile de replique du missile explosif
function this.createChild(myMissile, index)
    local newMissile = game.missile.create(myMissile.tank, this.constantes.childMode)

    newMissile.scope = love.math.random(this.constantes.minScope, this.constantes.maxScope)
    newMissile.initialTtl = newMissile.scope / this.constantes.maxScope * newMissile.initialTtl
    newMissile.ttl = newMissile.initialTtl
    newMissile.angle = 2 * math.pi / this.constantes.number * index
    newMissile.initialx = myMissile.x
    newMissile.initialy = myMissile.y
    newMissile.hitBox.x = newMissile.initialx
    newMissile.hitBox.y = newMissile.initialy
    myMissile.damage.missile = this.constantes.childDamage
    myMissile.damage.explosion = this.constantes.childDamage / 2

    table.insert(game.missile.missiles, newMissile)
end

function this.update(dt, myMissile)
    if myMissile.outDated == true then
        -- Le missile géant explose en plusieurs missiles standards après l'explosion classique
        for i = 1, this.constantes.number do
            
            -- Génération des missiles enfants
            this.createChild(myMissile, i)
        end
    end
end

function this.draw(myMissile)
    love.graphics.draw(
        myMissile.rocketImage, 
        math.floor(myMissile.x + game.offset.x), 
        math.floor(myMissile.y + game.offset.y), 
        myMissile.angle, 
        -1, 
        1, 
        0, 
        math.floor(myMissile.rocketImage:getHeight() / 2))
end

return this