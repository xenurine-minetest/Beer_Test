local Helpers = beer_test.api.classes.Helpers()

local cacheTable = {}

local NodeCache = {}

NodeCache.add = function (pos, item)
    cacheTable[pos] = item
end

NodeCache.get = function (pos)
    for k,v in pairs(cacheTable) do
        if (Helpers.tablesAreEqual(pos, k)) then
            return v
        end
    end

    return nil
end

NodeCache.getCount = function()
    local count = 0
    for _,_ in pairs(cacheTable) do
        count = count + 1
    end

    return count
end

return NodeCache