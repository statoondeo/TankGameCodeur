local this = {}

this.constantes = {}

-- Tir explosif
this.constantes.mode = 4
this.constantes.scope = 450
this.constantes.number = 8
this.constantes.reload = 1.5
this.constantes.minScope = 10
this.constantes.maxScope = 100
this.constantes.explosionZoom = 2
this.constantes.ttl = 2
this.constantes.easing = modules.tweening.easingInExpo
this.constantes.fire = {}
this.constantes.fire.speed = 25
this.constantes.fire.zoom = 1.8
this.constantes.childMode = 1

-- Factory à missiles
function this.create(myTank)
    local myMissile = modules.missile.createNewMissile(this.constantes.mode, myTank)
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
    myMissile.image = modules.missile.images.missiles[3]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitBox.radius = myMissile.image:getWidth() / 2
    myMissile.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireSoundStarted = false
    myMissile.octave = 0.5
    myMissile.reload = this.constantes.reload
    myMissile.fireImages = {}
    myMissile.fireImages[1] = modules.missile.images.fires[1]
    myMissile.fireImages[2] = modules.missile.images.fires[2]
    myMissile.fireImages[3] = modules.missile.images.fires[3]
    myMissile.fireImages[4] = modules.missile.images.fires[4]
    myMissile.fireImages[5] = myMissile.fireImages[4]
    myMissile.fireImages[6] = myMissile.fireImages[3]
    myMissile.fireImages[7] = myMissile.fireImages[2]
    myMissile.fireImages[8] = myMissile.fireImages[1]
    myMissile.fireSpeed = this.constantes.fire.speed
    myMissile.fireZoom = this.constantes.fire.zoom 
    myMissile.rocketImage = modules.missile.images.fires[1]
    table.insert(modules.missile.missiles, myMissile)
end

-- Génération de missile de replique du missile explosif
function this.createChild(myMissile, index)
    local newMissile = modules.missile.create(myMissile.tank, this.constantes.childMode)

    newMissile.scope = love.math.random(this.constantes.minScope, this.constantes.maxScope)
    newMissile.initialTtl = newMissile.scope / this.constantes.maxScope * newMissile.initialTtl
    newMissile.ttl = newMissile.initialTtl
    newMissile.angle = 2 * math.pi / this.constantes.number * index
    newMissile.initialx = myMissile.x
    newMissile.initialy = myMissile.y
    newMissile.hitBox.x = newMissile.initialxx
    newMissile.hitBox.y = newMissile.initialy

    table.insert(modules.missile.missiles, newMissile)
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
        myMissile.x + modules.battleground.offset.x, 
        myMissile.y + modules.battleground.offset.y, 
        myMissile.angle, 
        -1, 
        1, 
        0, 
        myMissile.rocketImage:getHeight() / 2)
end

return this