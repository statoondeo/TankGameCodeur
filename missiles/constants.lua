local this = {}

this.base = {}
this.base.frame = 3
this.base.fire = {}
this.base.fire.frame = 4

-- Explosion
this.explosion = {}
this.explosion.speed = 12
this.explosion.frame = 5

-- tir de base 
this.mini = {}
this.mini.mode = 1
this.mini.scope = 350
this.mini.reload = 0.5
this.mini.explosionZoom = 1
this.mini.ttl = 1
this.mini.easing = easingOutCirc
this.mini.damage = {}
this.mini.damage.missile = 100 
this.mini.damage.explosion = 50

-- Tir groupé
this.gun = {}
this.gun.mode = 2
this.gun.scope = 225
this.gun.minScope = 150
this.gun.maxScope = 200
this.gun.reload = 0.5
this.gun.explosionZoom = 1.1
this.gun.ttl = 1
this.gun.angleAmplitude = math.pi / 24
this.gun.nbChild = 2
this.gun.delay = 0.2
this.gun.easing = easingOutCirc
this.gun.childMode = 1
this.gun.fire = {}
this.gun.fire.speed = 20
this.gun.fire.zoom = 1.3
this.gun.damage = {}
this.gun.damage.missile = 110
this.gun.damage.explosion = 55
this.gun.shake = {}
this.gun.shake.amplitude = 15
this.gun.shake.time = 0.15

-- Tir en rafale
this.rafale = {}
this.rafale.mode = 3
this.rafale.minScope = 50
this.rafale.maxScope = 250
this.rafale.intervalScope = 25
this.rafale.reload = 1
this.rafale.explosionZoom = 1.5
this.rafale.ttl = 2
this.rafale.nbStep = 0.25
this.rafale.easing = easingLin
this.rafale.delay = 0.2
this.rafale.childMode = 1
this.rafale.fire = {}
this.rafale.fire.speed = 20
this.rafale.fire.frame = 5
this.rafale.fire.zoom = 1.8
this.rafale.childMinScope = 40
this.rafale.childMaxScope = 120
this.rafale.damage = {}
this.rafale.damage.missile = 150
this.rafale.damage.explosion = 75
this.rafale.childDamage = 75
this.rafale.shake = {}
this.rafale.shake.amplitude = 20
this.rafale.shake.time = 0.2

-- Tir explosif
this.rebound = {}
this.rebound.mode = 4
this.rebound.scope = 275
this.rebound.number = 16
this.rebound.reload = 1.5
this.rebound.minScope = 25
this.rebound.maxScope = 150
this.rebound.explosionZoom = 2
this.rebound.ttl = 2
this.rebound.easing = easingInExpo
this.rebound.fire = {}
this.rebound.fire.speed = 25
this.rebound.fire.zoom = 1.8
this.rebound.childMode = 1
this.rebound.childDamage = 50
this.rebound.damage = {}
this.rebound.damage.missile = 200
this.rebound.damage.explosion = 100
this.rebound.shake = {}
this.rebound.shake.amplitude = 25
this.rebound.shake.time = 0.25

return this