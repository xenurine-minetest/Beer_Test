local locks = {}
local queues = {}


local LockingSystem = {}
LockingSystem.acquireLock = function (pos, playerName)
    local strPos = minetest.pos_to_string(pos)

    if (locks[strPos]) then
        return false
    end

    locks[strPos] = playerName
    return true
end

LockingSystem.releaseLock = function(pos)
    local strPos = minetest.pos_to_string(pos)
    locks[strPos] = nil

    if (queues[strPos] and #queues[strPos] > 0) then
        local nextEntry = table.remove(queues[strPos], 1)
        local nextPlayer = nextEntry.playerName
        local nextAction = nextEntry.accessCallback
        print("It's" .. nextPlayer .. "'s turn")
        minetest.after(0, function ()
            LockingPropertyStorage.write(nextPlayer, pos, nextAction)
        end)
        print(nextPlayer .. "has done its action")
    end
end

LockingSystem.addToQueue = function(pos, playerName, accessCallback)
    local strPos = minetest.pos_to_string(pos)
    queues[strPos] = queues[strPos] or {}

    table.insert(queues[strPos], {
        playerName = playerName,
        accessCallback = accessCallback
    })
end

LockingSystem.removeFromQueue = function(pos, playerName)
    local strPos = minetest.pos_to_string(pos)
    if (queues[strPos] == nil) then
        return
    end

    for i, entry in ipairs(queues[strPos]) do
        if (entry.playerName == playerName) then
            table.remove(queues[strPos])
            break
        end
    end
end

local PropertyStorage = {}
PropertyStorage.getProperties = function(meta)
    local propertiesDefinition = minetest.deserialize(meta:get_string("properties"))

    if(propertiesDefinition == nil) then
        return nil
    end

    local properties = {}
    for property, propertyType in pairs(propertiesDefinition) do
        if (propertyType == "string") then
            properties[property] = meta:get_string(property)
        end

        if (propertyType == "number") then
            properties[property] = meta:get_int(property)
        end

        if (propertyType == "boolean") then
            properties[property] = (meta:get_int(property) == 1 or false)
        end
    end

    return properties
end

PropertyStorage.setProperties = function(properties, meta)
    local propertiesDefinition = {}

    for property, value in pairs(properties) do
        propertiesDefinition[property] = type(value)

        if (type(value) == "string") then
            meta:set_string(property, value)
        end

        if (type(value) == "number") then
            meta:set_int(property, value)
        end

        if (type(value) == "boolean") then
            value = (value == true and 1 or 0 )
            meta:set_string(property, value)
        end
    end
    
    meta:set_string("properties", minetest.serialize(propertiesDefinition))
end


local function access(playerName, pos, accessCallback)
    if (not LockingSystem.acquireLock(pos, playerName)) then
        LockingSystem.addToQueue(pos, playerName, accessCallback)
        print(playerName .. " must wait")
        return
    end

    local success, err = pcall(function()
        accessCallback()
    end)

    LockingSystem.releaseLock(pos)

    if (not success) then
        minetest.log("error", err)
    end
end

LockingPropertyStorage = {}

LockingPropertyStorage.write = function(playerName, pos, accessCallback)
    local meta = minetest.get_meta(pos)
    local properties = PropertyStorage.getProperties(meta) or {}

    access(playerName, pos, function ()
        accessCallback(properties)
    end)

    PropertyStorage.setProperties(properties, meta)
end

LockingPropertyStorage.readonly = function(meta)
    return PropertyStorage.getProperties(meta)
end

LockingPropertyStorage.dequeuePlayer = function (pos, playerName)
    return LockingSystem.removeFromQueue(pos, playerName)
end

return LockingPropertyStorage