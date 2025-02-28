local items = {}

---@class ItemRegistrator
local ItemRegistrator = {}

---comment
---@param itemDefinition ItemDefinition
---@return boolean
function ItemRegistrator.registerItem(itemDefinition)
    local itemName = itemDefinition.itemName

    if (items[itemName] ~= nil) then
        return false
    end

    items[itemName] = {
        name = itemName,
        volume = itemDefinition.volume or 0
    }

    return true
end

---comment
---@param itemName string
---@return ItemDefinition
function ItemRegistrator.getItem(itemName)
    return items[itemName]
end

return ItemRegistrator