local this = {}

-- tourelle
this.base= {}
this.base.offset = {}
this.base.offset.x = 8
this.base.offset.y = 0
this.base.skins = {}
this.base.skins.count = 6
this.base.emotes = {}
this.base.emotes.count = 3
this.base.flames = {}
this.base.flames.count = 5
this.base.flames.speed = 15

this.enemy = {}
this.enemy.detectionRange = 160
this.enemy.arcSpeed = 1
this.enemy.sentinel = {}
this.enemy.sentinel.mode = 1
this.enemy.sentinel.minSpeed = -1
this.enemy.sentinel.maxSpeed = 1
this.enemy.sentinel.color = { 173, 255, 47 }
this.enemy.alert = {}
this.enemy.alert.mode = 2
this.enemy.alert.color = { 255, 165, 0 }
this.enemy.attack = {}
this.enemy.attack.mode = 3
this.enemy.attack.ttl = 5
this.enemy.attack.color = { 139, 0, 0 }
this.enemy.dead = {}
this.enemy.dead.mode = 0
this.enemy.amplitude = {}
this.enemy.amplitude.min = math.pi / 12
this.enemy.amplitude.max = 2 * math.pi / 5

return this