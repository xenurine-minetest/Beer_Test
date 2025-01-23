local EventSystem = beer_test.modules.EventSystem()
local Storage = beer_test.modules.Storage()

local Sealable = {}

local sealedField = "sealed"

local function isSealable(properties)
    if(properties[sealedField] == nil) then
        return false
    end

    return true
end

Sealable.create = function (pos)
    local meta = minetest.get_meta(pos)
    local properties = Storage.get(meta) or {}

    properties[sealedField] = false

    Storage.set(properties, meta)
end

Sealable.seal = function (pos)
    local meta = minetest.get_meta(pos)
    local properties = Storage.get(meta) or {}

    if(isSealable(properties) == false) then
        return false
    end

    if(properties[sealedField] == true) then
        return false
    end

    properties[sealedField] = true
    Storage.set(properties, meta)
    EventSystem.triggerEvent('fillStateChanged', pos, properties)

    return true
end

Sealable.unseal = function (pos)
    local meta = minetest.get_meta(pos)
    local properties = Storage.get(meta) or {}

    if(isSealable(properties) == false) then
        return false
    end

    if(properties[sealedField] == false) then
        return false
    end

    properties[sealedField] = false
    Storage.set(properties, meta)
    EventSystem.triggerEvent('fillStateChanged', pos, properties)

    return true
end

return Sealable