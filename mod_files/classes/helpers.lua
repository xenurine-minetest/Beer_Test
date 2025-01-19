local Helpers = {}

Helpers.mergeTables = function(tables)
        local combinedTable = {}

        for _,table in ipairs(tables) do
            for k,v in pairs(table) do
                combinedTable[k] = v
            end
        end

        print(dump2(tables, "tables", {}))
        print(dump2(combinedTable, "combinedTable", {}))
        return combinedTable
    end

Helpers.countTableItems = function (table)
    local count = 0
    for _,_ in pairs(table) do
        count = count + 1
    end
    return count
end

Helpers.tablesAreEqual = function (table1, table2)
    if (Helpers.countTableItems(table1) ~= Helpers.countTableItems(table2)) then
        return false
    end

    for k,v in pairs(table1) do
        if (table2[k] == nil or table2[k] ~= v) then
            return false
        end
    end

    return true
end

return Helpers