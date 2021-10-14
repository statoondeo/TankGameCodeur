local this = {}

this.constantes = {}
this.constantes.noneType = 0      -- N'intervient pas dans le calcul des collision (décor uniquement)
this.constantes.circleType = 1
this.constantes.rectangleType = 2

function this.load()
end

function this.create(myHitboxType)
    local newHitbox = {}
    newHitbox.type = myHitboxType
    newHitbox.x = 0
    newHitbox.y = 0
    newHitbox.radius = 0
    newHitbox.width = 0
    newHitbox.height = 0
    return newHitbox
end

-- Affichage de la hitbox
function this.drawHitbox(myHitbox)
    if myHitbox.type ~= nil then
        if myHitbox.type == this.constantes.rectangleType then
            love.graphics.rectangle(
                "line", 
                myHitbox.x + game.offset.x, 
                myHitbox.y + game.offset.y, 
                myHitbox.width,
                myHitbox.height)    
        elseif myHitbox.type == this.constantes.circleType then
            love.graphics.circle(
                "line", 
                myHitbox.x + game.offset.x, 
                myHitbox.y + game.offset.y, 
                myHitbox.radius)
        end
    end
end

-- Est-ce qu'il y a une collision entre ces 2 hitbox
function this.IsCollision(hitBox1, hitBox2)
    if hitBox1.type == this.constantes.circleType then
        if hitBox2.type == this.constantes.circleType then
            return this.IsCircleInCircle(hitBox1, hitBox2)
        else
            return this.IsCircleInRectangle(hitBox1, hitBox2)
        end
    else
        if hitBox2.type == this.constantes.circleType then
            return this.IsCircleInRectangle(hitBox2, hitBox1)
        else
            return this.IsRectangleInRectangle(hitBox1, hitBox2)
        end
    end
end

-- Calcul de la distance entre 2 points
function this.dist(hitBox1, hitBox2) 
    return ((hitBox1.x - hitBox2.x)^2+(hitBox1.y - hitBox2.y)^2)^0.5 
end

-- Est-ce qu'il y a collision entre ces 2 hitbox circulaires
function this.IsCircleInCircle(hitBox1, hitBox2)
    return this.dist(hitBox1, hitBox2) <= hitBox1.radius + hitBox2.radius
end

function this.IsCircleInArc(circleHitBox, arc)
    local angle = math.atan2(circleHitBox.y - arc.y, circleHitBox.x - arc.x) % (2 * math.pi)
    return  math.abs(arc.angle - angle) <= arc.amplitude and this.dist(circleHitBox, arc) <= arc.radius + circleHitBox.radius
end

-- Est-ce qu'il y a collision entre ces 2 hitbox circulaire (radius = 0) et rectangulaire
function this.IsPointInRectangle(pointHitBox, rectangleHitBox)
    return 
        rectangleHitBox.x <= pointHitBox.x and pointHitBox.x <= rectangleHitBox.x + rectangleHitBox.width and
        rectangleHitBox.y <= pointHitBox.y and pointHitBox.y <= rectangleHitBox.y + rectangleHitBox.height
end

-- Est-ce qu'il y a collision entre ces 2 hitbox circulaire et rectangulaire
function this.IsCircleInRectangle(circleHitBox, rectangleHitBox)
    local nHitBox = {}
    nHitBox.x = circleHitBox.x + circleHitBox.radius
    nHitBox.y = circleHitBox.y
    local sHitBox = {}
    sHitBox.x = circleHitBox.x - circleHitBox.radius
    sHitBox.y = circleHitBox.y                
    local eHitBox = {}
    eHitBox.x = circleHitBox.x
    eHitBox.y = circleHitBox.y - circleHitBox.radius
    local wHitBox = {}
    wHitBox.x = circleHitBox.x
    wHitBox.y = circleHitBox.y + circleHitBox.radius
    return 
        this.IsPointInRectangle(nHitBox, rectangleHitBox) or 
        this.IsPointInRectangle(sHitBox, rectangleHitBox) or 
        this.IsPointInRectangle(eHitBox, rectangleHitBox) or 
        this.IsPointInRectangle(wHitBox, rectangleHitBox)
end

-- Est-ce qu'il y a collision entre ces 2 hitbox rectangulaires
function this.IsRectangleInRectangle(rectangleHitBox1, rectangleHitBox2)
    return 
        rectangleHitBox1.x < rectangleHitBox2.x + rectangleHitBox2.width and
        rectangleHitBox2.x < rectangleHitBox1.x + rectangleHitBox1.width and
        rectangleHitBox1.y < rectangleHitBox2.y + rectangleHitBox2.height and
        rectangleHitBox2.y < rectangleHitBox1.y + rectangleHitBox1.height
end

return this