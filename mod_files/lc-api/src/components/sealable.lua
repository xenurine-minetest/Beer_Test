local EventSystem = lc_api.modules.EventSystem()

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

Sealable.seal = function (properties)
    if(isSealable(properties) == false) then
        return false
    end

    if(properties[sealedField] == true) then
        return false
    end

    properties[sealedField] = true

    EventSystem.triggerEvent('changed', properties.pos, properties)
    return true
end

Sealable.unseal = function (properties)

    if(isSealable(properties) == false) then
        return false
    end

    if(properties[sealedField] == false) then
        return false
    end

    properties[sealedField] = false

    EventSystem.triggerEvent('changed', properties.pos, properties)
    return true
end

return Sealable