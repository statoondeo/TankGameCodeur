local this = {}

this.constantes = {}

-- Modes de tir à disposition
this.constantes.mode = 4

-- Tir explosif
this.constantes.scope = 450
this.constantes.number = 8
this.constantes.reload = 1.5
this.constantes.minScope = 10
this.constantes.maxScope = 100
this.constantes.explosionZoom = 2
this.constantes.ttl = 2
this.constantes.easing = modules.tweening.easingInExpo

-- tir
this.constantes.fire = {}
this.constantes.fire.speed = 25
this.constantes.fire.frame = 8
this.constantes.fire.zoom = 1.8

-- Ressources
this.images = {}
this.images.missiles = {}
this.images.fires = {}
this.sounds = {}
this.sounds.shots = {}

-- Pour le chargement du module
function this.load()
    -- Chargement des ressources
    this.images.missiles[1] = modules.missile.images.missiles[3]
    this.images.fires[1] = modules.missile.images.fires[1]
    this.images.fires[2] = modules.missile.images.fires[2]
    this.images.fires[3] = modules.missile.images.fires[3]
    this.images.fires[4] = modules.missile.images.fires[4]
    this.images.fires[5] = this.images.fires[4]
    this.images.fires[6] = this.images.fires[3]
    this.images.fires[7] = this.images.fires[2]
    this.images.fires[8] = this.images.fires[1]
    this.sounds.shots[1] = modules.missile.sounds.shots[1]
    this.childMissileModule = require("baseMissileModule")
end

-- Génération d'un missile explosif
function this.init(myMissile)
    -- Initialisation spécifiques au type demandé
    myMissile.explosionZoom = this.constantes.explosionZoom
    myMissile.initialTtl = this.constantes.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = this.constantes.scope
    myMissile.easing = this.constantes.easing
    myMissile.image = this.images.missiles[1]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitBox.radius = myMissile.image:getWidth() / 2
    myMissile.isFired = true
    myMissile.tank.isFired = true
    myMissile.fireTtl = 0
    myMissile.fireSoundStarted = false
end

-- Génération de missile de replique du missile explosif
function this.createChildMissile(myMissile, index)
    local newMissile = modules.missile.create(myMissile.tank, this.childMissileModule.constantes.mode)

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

-- Update des missiles
function this.update(dt, myMissile)
    this.updateFire(dt, myMissile)
    -- Est-ce que le missile doit disparaitre (animation d'explosion terminée)
    if myMissile.outDated == true then
        -- Le missile géant explose en plusieurs missiles standards après l'explosion classique
        for i = 1, this.constantes.number do
            
            -- Génération des missiles enfants
            this.createChildMissile(myMissile, i)
        end
    end
end

function this.updateFireSound(dt, myMissile)
    -- Son d'explosion du missile si pas encore fait
    if this.sounds.shots[1]:isPlaying() then
        this.sounds.shots[1]:stop()
    end
    this.sounds.shots[1]:setPitch(0.5)
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
        print("fireFrame", myMissile.fireFrame, this.constantes.fire.frame)
        -- Est-ce que le tir doit disparaitre
        if myMissile.fireFrame > this.constantes.fire.frame then
            myMissile.isFired = false
            myMissile.tank.isFired = false
        else
            myMissile.fireImage = this.images.fires[myMissile.fireFrame]
        end
    end
end

function this.draw(myMissile)
    if myMissile.isFired == true then
        this.drawFire(myMissile)
    else
        modules.missile.drawMissile(myMissile)
    end
end

function this.drawFire(myMissile)
    love.graphics.draw(
        myMissile.fireImage, 
        myMissile.tank.turret.output.x + modules.battleground.offset.x, 
        myMissile.tank.turret.output.y + modules.battleground.offset.y, 
        myMissile.angle, 
        this.constantes.fire.zoom, 
        this.constantes.fire.zoom, 
        myMissile.fireImage:getWidth() / 2, 
        myMissile.fireImage:getHeight() / 2)
end


function this.drawActiveMissile(myMissile)
    -- Affichage du missile proprement dit
    love.graphics.draw(
        modules.missile.images.fires[1], 
        myMissile.x + modules.battleground.offset.x, 
        myMissile.y + modules.battleground.offset.y, 
        myMissile.angle,
        1,
        -1,
        myMissile.center.x, 
        myMissile.center.y)
end

return this