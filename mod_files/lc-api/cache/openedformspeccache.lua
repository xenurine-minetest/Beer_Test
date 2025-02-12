local cacheTable = {}

local OpenedFormspecCache = {}

local function tablesEquals(table1, table2)
    for k,v in pairs(table1) do
        if (table2[k] ~= v) then
            return false
        end
    end

    return true
end

local function removeByPlayerName(playerName)
    cacheTable[playerName] = nil
end

local function removeByPos(pos)
    for playerName, savedPos in pairs(cacheTable) do
        if (tablesEquals(pos, savedPos)) then
            removeByPlayerName(playerName)
        end
    end
end

OpenedFormspecCache.add = function (pos, playerName)
    cacheTable[playerName] = pos
end

OpenedFormspecCache.getPosByPlayer = function (playerName)
    for k,v in pairs(cacheTable) do
        if (k == playerName) then
            return v
        end
    end

    return nil
end

OpenedFormspecCache.getPlayerNamesByPos = function (pos)
    local foundPlayerNames = {}

    for playerName, savedPos in pairs(cacheTable) do
        if(tablesEquals(pos, savedPos)) then
            table.insert(foundPlayerNames, playerName)
        end
    end

    return foundPlayerNames
end

OpenedFormspecCache.remove = function (pos, playerName)
    if (playerName == nil) then
        removeByPos(pos)
    else
        removeByPlayerName(playerName)
    end
end

OpenedFormspecCache.debug = function()
    print(dump2(cacheTable, "openforms"))
end

return OpenedFormspecCache