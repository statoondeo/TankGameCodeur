local this = {}

this.modes = {}
this.modes.player = 1
this.modes.enemy = 2

this.base = {}
this.base.tailLife = 1
this.base.tailSpeed = 10
this.base.lifeBarHeight = 6
this.base.turretAnchorOffset = {}
this.base.turretAnchorOffset.x = 5
this.base.turretAnchorOffset.y = 0
this.base.skins = {}
this.base.skins.number = {}
this.base.skins.number.player = 3
this.base.skins.number.enemy = 3
this.base.skins.number.total = 6
this.base.skins.playerRed = 2
this.base.skins.playerBlue = 3
this.base.skins.playerGreen = 4
this.base.skins.enemySmall = 5
this.base.skins.enemyMedium = 6
this.base.skins.enemyLarge = 7

this.ally = {}
this.ally.acceleration = 3
this.ally.angleAcceleration = 2
this.ally.defaultAcceleration = 2
this.ally.maxSpeed = 2.5
this.ally.maxSpeedEnemy = 1
this.ally.tailLife = 1
this.ally.tailSpeed = 10
this.ally.initialLife = 1200

this.enemy = {}
this.enemy.acceleration = 3
this.enemy.angleAcceleration = 2
this.enemy.angleTolerance = math.pi / 36
this.enemy.defaultAcceleration = 1  
this.enemy.maxSpeed = 1
this.enemy.maxSpeedEnemy = 1
this.enemy.tailLife = 1
this.enemy.tailSpeed = 10
this.enemy.initialLife = 1000

this.enemy.states = {}
this.enemy.states.goAhead = 0
this.enemy.states.checkTtl = 3
this.enemy.states.moveUp = 1
this.enemy.states.moveRight = 2
this.enemy.states.moveDown = 3
this.enemy.states.moveLeft = 4
this.enemy.states.moveStop = 5
this.enemy.states.moveBack = 6
this.enemy.states.magneticTtl = 1

return this