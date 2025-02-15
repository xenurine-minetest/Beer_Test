local liquidLevelField = "liquidLevel"
local maxCapacityField = "maxCapacity"

---@class Fillable
local Fillable = {}

local function isLiquidContainer(properties)
    if (properties[liquidLevelField] == nil or properties[maxCapacityField] == nil) then
        return false
    end

    return true
end

Fillable.create = function (properties, maxCapacity)
    properties[liquidLevelField] = 0
    properties[maxCapacityField] = maxCapacity
end

Fillable.fill = function(properties, amount)
    if(isLiquidContainer(properties) == false) then
        return false
    end

    if (properties[liquidLevelField] + amount > properties[maxCapacityField]) then
        return false
    end

    properties[liquidLevelField] = properties[liquidLevelField] + amount

    return true
end

Fillable.drain = function(properties, amount)
    if(isLiquidContainer(properties) == false) then
        return false
    end

    if (properties[liquidLevelField] - amount < 0) then
        return false
    end

    properties[liquidLevelField] = properties[liquidLevelField] - amount

    return true
end

return Fillable