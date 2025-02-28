local EventSystem = lc_api.modules.EventSystem()
local ModelHelper = lc_api.modules.Components.ComponentModelHelper()

---@class Fillable
local Fillable = {}

local liquidLevelField = "liquidLevel"
local maxCapacityField = "maxCapacity"

local function isLiquidContainer(properties)
    if (properties[liquidLevelField] == nil or properties[maxCapacityField] == nil) then
        return false
    end

    return true
end

local function canFill(properties, amount) 
    return properties[liquidLevelField] + amount <= properties[maxCapacityField]
end

local function canDrain(properties, amount)
    return properties[liquidLevelField] - amount >= 0
end

Fillable.create = function (properties, maxCapacity)
    properties[liquidLevelField] = 0
    properties[maxCapacityField] = maxCapacity
end

Fillable.fill = function(properties, amount, actor)
    actor = actor or "system"

    if(isLiquidContainer(properties) == false) then
        return false
    end

    if (canFill(properties, amount) == false) then
        return false
    end

    local allowed = ModelHelper.writeIfAllowedByEvent(properties, "beforeFill", actor, function(copiedProperties) 
        copiedProperties[liquidLevelField] = properties[liquidLevelField] + amount
    end)

    if (not allowed) then
        print ("cancelFill")
        return false
    end

    EventSystem.trigger('filled', {
        nodeProperties = properties,
        actor = actor
    })

    return true
end

Fillable.drain = function(properties, amount, actor)
    actor = actor or "system"
    print("drain1")
    if(isLiquidContainer(properties) == false) then
        return false
    end
    print("drain2")
    if (canDrain(properties, amount) == false) then
        return false
    end
    print("drain3")
    local allowed = ModelHelper.writeIfAllowedByEvent(properties, "beforeDrain", actor, function(copiedProperties)
        copiedProperties[liquidLevelField] = properties[liquidLevelField] - amount
    end)

    print(allowed)

    if (not allowed) then
        print ("cancelDrain")
        return false
    end

    print("drain4")
    EventSystem.trigger('drained', {
        nodeProperties = properties,
        actor = actor
    })
    print("drain5")
    return true
end

return Fillable