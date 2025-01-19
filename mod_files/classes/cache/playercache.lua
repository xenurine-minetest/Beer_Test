local cacheTable = {}

local PlayerCache = {}

PlayerCache.add = function (playerName, item)
    cacheTable[playerName] = item
end

PlayerCache.get = function (playerName)
    for k,v in pairs(cacheTable) do
        if (Hk == playerName) then
            return v
        end
    end

    return nil
end

PlayerCache.getCount = function()
    local count = 0
    for _,_ in pairs(cacheTable) do
        count = count + 1
    end

    return count
end

return PlayerCache