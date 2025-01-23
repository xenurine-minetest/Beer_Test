local EventSystem = beer_test.modules.EventSystem()
local Storage = beer_test.modules.Storage()

local liquidLevelField = "liquidLevel"
local maxCapacityField = "maxCapacity"

local Fillable = {}

local function isLiquidContainer(properties) 
    if (properties[liquidLevelField] == nil or properties[maxCapacityField] == nil) then
        return false
    end

    return true
end

Fillable.create = function (pos, maxCapacity) 
    local meta = minetest.get_meta(pos)
    local properties = Storage.get(meta) or {}

    properties[liquidLevelField] = 0
    properties[maxCapacityField] = maxCapacity

    Storage.set(properties, meta)
end

Fillable.fill = function(pos, amount) 
    local meta = minetest.get_meta(pos)
    local properties = Storage.get(meta)

    if(isLiquidContainer(properties) == false) then
        return false
    end

    if (properties[liquidLevelField] + amount > properties[maxCapacityField]) then
        return false
    end

    properties[liquidLevelField] = properties[liquidLevelField] + amount
    Storage.set(properties, meta)
    EventSystem.triggerEvent('fillStateChanged', pos, properties)

    return true
end

Fillable.drain = function(pos, amount) 
    local meta = minetest.get_meta(pos)
    local properties = Storage.get(meta)

    if(isLiquidContainer(properties) == false) then
        return false
    end

    if (properties[liquidLevelField] - amount < 0) then
        return false
    end

    properties[liquidLevelField] = properties[liquidLevelField] - amount
    Storage.set(properties, meta)
    EventSystem.triggerEvent('fillStateChanged', pos, properties)

    return true
end

return Fillable