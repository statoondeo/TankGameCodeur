local this = {}

function this.easingInOutCubic(x)
    if x < 0.5 then
        return 4 * x^3
    else
        return 1 - (-2 * x + 2)^3 / 2
    end
end

function this.easingOutCirc(x)
    return (1 - (x - 1)^2)^0.5
end

function this.easingInExpo(x)
    return 2^(10 * x - 10)
end

function this.easingLin(x)
    return x
end

function this.easingInOutBack(x)
    local c1 = 1.70158
    local c2 = c1 * 1.525
    
    if x < 0.5 then
        return ((2 * x)^2 * ((c2 + 1) * 2 * x - c2)) / 2
    else
        return ((2 * x - 2)^2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
end

return this