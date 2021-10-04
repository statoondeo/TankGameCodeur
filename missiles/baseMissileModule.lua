local this = {}

this.constantes = {}

-- tir de base 
this.constantes.mode = 1
this.constantes.scope = 350
this.constantes.reload = 0.5
this.constantes.explosionZoom = 1
this.constantes.ttl = 1
this.constantes.easing = modules.tweening.easingOutCirc

-- Factory à missiles
function this.create(myTank)
    local myMissile = modules.missile.createNewMissile(this.constantes.mode, myTank)
    this.init(myMissile)
    return (myMissile)
end

function this.init(myMissile)
    -- Initialisations spécifiques au type demandé
    myMissile.module = this
    myMissile.explosionZoom = this.constantes.explosionZoom
    myMissile.initialTtl = this.constantes.ttl
    myMissile.ttl = myMissile.initialTtl
    myMissile.scope = this.constantes.scope
    myMissile.easing = this.constantes.easing
    myMissile.image = modules.missile.images.missiles[1]
    myMissile.center = {}
    myMissile.center.x = myMissile.image:getWidth() / 2
    myMissile.center.y = myMissile.image:getHeight() / 2
    myMissile.hitBox.radius = myMissile.image:getWidth() / 2
    myMissile.fireSoundStarted = true
    myMissile.octave = 2
    myMissile.reload = this.constantes.reload
    myMissile.fireIndex = 0
    myMissile.fireImage = nil
    myMissile.fireImages = {}
end

function this.update(dt, myMissile)
end

function this.draw(myMissile)
end

return this