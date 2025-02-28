local EventSystem = lc_api.modules.EventSystem()
local ModelHelper = lc_api.modules.Components.ComponentModelHelper() 

---@class Sealable
local Sealable = {}

local sealedField = "sealed"

local function isSealable(properties)
    if(properties[sealedField] == nil) then
        return false
    end

    return true
end

Sealable.create = function (properties)
    properties[sealedField] = false
end

Sealable.seal = function (properties, actor)
    actor = actor or "system"

    if(isSealable(properties) == false) then
        return false
    end

    if(properties[sealedField] == true) then
        return false
    end

    local allowed = ModelHelper.writeIfAllowedByEvent(properties, "beforeSeal", actor, function(copiedProperties)
        copiedProperties[sealedField] = true
    end)

    if (not allowed) then
        return false
    end


    EventSystem.trigger('sealed', {
        nodeProperties = properties,
        actor = actor
    })

    return true
end

Sealable.unseal = function (properties, actor)
    actor = actor or "system"

    if(isSealable(properties) == false) then
        return false
    end
    

    if(properties[sealedField] == false) then
        return false
    end

    local allowed = ModelHelper.writeIfAllowedByEvent(properties, "beforeUnseal", actor, function(copiedProperties)
        copiedProperties[sealedField] = false
    end)

    if (not allowed) then
        return false
    end

    EventSystem.trigger('unsealed', {
        nodeProperties = properties,
        actor = actor
    })

    return true
end

return Sealable