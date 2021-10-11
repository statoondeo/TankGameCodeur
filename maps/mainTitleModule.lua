local this = {}

function this.load()
    -- Quelle carte sert de fond d'écran
    -- On wrappe la carte demandée pour se transformer en map
    this.map = require("maps/map1Module")
    this.constantes = this.map.constantes
    this.tiles = this.map.tiles
    this.obstacles = this.map.obstacles

    -- Point de départ du joueur
    this.start = nil

    -- Liste des ennemis
    this.ennemis = 
    {
    }

    -- Quel endroit de la map exactement
    this.offset = {}
    this.offset.x = 0
    this.offset.y = 0

    this.constantes.buttonStartBlinkTimerLength = 0.5
    this.constantes.selection = {}
    this.constantes.selection.ttl = 0.5
    this.constantes.selection.modes = {}
    this.constantes.selection.modes.none = 0
    this.constantes.selection.modes.tank = 1
    this.constantes.selection.modes.game = 2
    this.constantes.selection.modes.quit = 3
    this.constantes.difficulties = {}
    this.constantes.difficulties[1] = "(Hard difficulty)"
    this.constantes.difficulties[2] = "(Normal difficulty)"
    this.constantes.difficulties[3] = "(Easy difficulty)"
end

function this.init()
    this.buttonStartBlinkTimer = 0
    this.buttonStartBlinkDelta = 1 
    this.tanks = {}
    this.turrets = {}
    for i = 1, modules.tank.constantes.skins.number.player do
        local myTank = modules.tank.create(modules.tank.constantes.modes.player, i + 1, -100, 5 * love.graphics.getHeight() / 7, 0)
        myTank.drawLife = false
        myTank.label = this.constantes.difficulties[i]
        table.insert(this.tanks, myTank)
        table.insert(this.turrets, myTank.turret)
    end
    this.oldTank = 2
    this.currentTank = 2
    this.selectionWip = this.constantes.selection.modes.tank
    this.selectionDirection = 1
    this.selectionTtl = 0
end

function this.update(dt, mouse)
    -- Clignotement du démarrage
    if this.buttonStartBlinkTimer >= this.constantes.buttonStartBlinkTimerLength then
        this.buttonStartBlinkDelta = -1 
    else
        if this.buttonStartBlinkTimer <= 0 then
            this.buttonStartBlinkDelta = 1 
        end
    end
    this.buttonStartBlinkTimer = this.buttonStartBlinkTimer + this.buttonStartBlinkDelta * dt

    if this.selectionWip == this.constantes.selection.modes.none then
        -- On affiche le tank
        -- Mais il ne peut pas bouger
        this.tanks[this.currentTank].x = love.graphics.getWidth() / 2
        this.tanks[this.currentTank].angle = 0
        modules.tank.updateTank(dt, this.tanks[this.currentTank])
        modules.turret.updateTurret(dt, this.turrets[this.currentTank], mouse)
    elseif this.selectionWip == this.constantes.selection.modes.tank then
        this.selectionTtl = this.selectionTtl + dt
        if this.selectionTtl >= this.constantes.selection.ttl then
            this.selectionWip = this.constantes.selection.modes.none
            this.selectionTtl = 0
        else
            -- On déplace les tanks
            local distance = (100 + love.graphics.getWidth() / 2) * modules.tweening.easingInOutBack(this.selectionTtl / this.constantes.selection.ttl)
            this.tanks[this.oldTank].x = this.tanks[this.oldTank].initialx + distance * this.selectionDirection
            this.tanks[this.currentTank].x = this.tanks[this.currentTank].initialx + distance * this.selectionDirection
            modules.tank.UpdateTurretAnchor(dt, this.tanks[this.oldTank])
            modules.tank.UpdateTurretAnchor(dt, this.tanks[this.currentTank])
            modules.turret.updateTurret(dt, this.tanks[this.oldTank].turret, mouse)
            modules.turret.updateTurret(dt, this.tanks[this.currentTank].turret, mouse)
        end
    end
end

-- function this.initEnded()    
--     local map = require("maps/map1Module")
--     map.playerSkin = this.tanks[this.currentTank].skin
--     modules.game.init(map)
-- end

function this.draw()
    -- Filtre transparent
    love.graphics.setColor(255, 255, 255, 0.75)
    love.graphics.draw(modules.game.images.background, 0, 0)
    love.graphics.setColor(255, 255, 255)

    -- Titre principal
    love.graphics.setFont(modules.game.fonts.giant)
    local font = love.graphics.getFont()
    local label = "Tanks"
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, (love.graphics.getHeight() - font:getHeight(label)) / 7)
    love.graphics.setFont(modules.game.fonts.large)
    font = love.graphics.getFont()
    label = "Battleground"
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, 2 * (love.graphics.getHeight() - font:getHeight(label)) / 7)

    love.graphics.setFont(modules.game.fonts.small)
    font = love.graphics.getFont()
    label = "Raphael DUCHOSSOY (GameCodeur.fr)"
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, 3 * (love.graphics.getHeight() - font:getHeight(label)) / 7)
    label = "\"Click\" to fire, \"Arrows\" to select tank, \"Escape\" to quit"
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, 6 * (love.graphics.getHeight() - font:getHeight(label)) / 7)

    love.graphics.setFont(modules.game.fonts.medium)
    font = love.graphics.getFont()
    label = "\"Enter\" to start"
    love.graphics.setColor(255, 255, 255, modules.tweening.easingInOutCubic(this.buttonStartBlinkTimer / this.constantes.buttonStartBlinkTimerLength))
    love.graphics.print(label, (love.graphics.getWidth() - font:getWidth(label)) / 2, 4 * (love.graphics.getHeight() - font:getHeight(label)) / 7)
    love.graphics.setColor(255, 255, 255)

    -- On affiche les médailles
    for i = 1, 3 do
        love.graphics.draw(
            modules.game.images.medals[i],
            (love.graphics:getWidth() - modules.game.images.medals[i]:getWidth()) / 7,
            150 + 1.5 * (i - 1) * modules.game.images.medals[i]:getHeight(),
            0,
            1 + i / 5,
            1 + i / 5,
            modules.game.images.medals[i]:getWidth() / 2,
            modules.game.images.medals[i]:getHeight() / 2
        )
        love.graphics.draw(
            modules.game.images.medals[i],
            6 * (love.graphics:getWidth() - modules.game.images.medals[i]:getWidth()) / 7,
            150 + 1.5 * (i - 1) * modules.game.images.medals[i]:getHeight(),
            0,
            1 + i / 5,
            1 + i / 5,
            modules.game.images.medals[i]:getWidth() / 2,
            modules.game.images.medals[i]:getHeight() / 2
        )
    end

    if this.selectionWip == this.constantes.selection.modes.none then
        love.graphics.setFont(modules.game.fonts.small)
        font = love.graphics.getFont()
        label = this.tanks[this.currentTank].label
        love.graphics.print(
            label, 
            (love.graphics.getWidth() - font:getWidth(label)) / 2, 
            5.4 * love.graphics.getHeight() / 7)    
    end

    -- On affiche les tank
    modules.tank.drawTank(this.tanks[this.oldTank])
    modules.tank.drawTank(this.tanks[this.currentTank])

    -- On affiche la tourelle
    modules.turret.drawTurret(this.turrets[this.oldTank])
    modules.turret.drawTurret(this.turrets[this.currentTank])
    
    -- On draw les missiles
    modules.missile.draw()
end

function this.mousepressed(x, y, button, istouch, presses)  
    if this.selectionWip == this.constantes.selection.modes.none then
        modules.tank.fire(this.tanks[this.currentTank])
    end
end

function this.keypressed(key, scancode, isrepeat)
    if this.selectionWip == this.constantes.selection.modes.none then
        if key == "left" or key == "right" then
            this.selectionWip = this.constantes.selection.modes.tank
            this.oldTank = this.currentTank
            this.tanks[this.oldTank].initialx = this.tanks[this.oldTank].x
            if key == "left" then
                this.currentTank = this.currentTank - 1
                if this.currentTank <= 0 then
                    this.currentTank = #this.tanks
                end
                this.tanks[this.currentTank].initialx = 100 + love.graphics.getWidth()
                this.selectionDirection = -1
            else
                this.currentTank = this.currentTank + 1
                if this.currentTank > #this.tanks then
                    this.currentTank = 1
                end
                this.tanks[this.currentTank].initialx = -100
                this.selectionDirection = 1
            end
        elseif key == "return" then
            modules.game.sounds.validation:play()
            modules.game.changeScreen(modules.game.loadmap, require("maps/map1Module"), this.tanks[this.currentTank].skin) 
        elseif key == "escape" then
            modules.game.sounds.validation:play()
            modules.game.changeScreen(modules.game.quitApp) 
        end
    end
end

return this