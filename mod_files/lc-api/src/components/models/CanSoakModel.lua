local RecipeRegistration = lc_api.Registrations.Recipes()
local ItemRegistrator = lc_api.Registrations.Items()
local PropertyStorage = lc_api.modules.PropertyStorage()
local Fillable = lc_api.modules.Components.Fillable()

---@class CanSoak
local CanSoak = {}

local function getInventoryList(pos, inventoryName)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_list(inventoryName)

    return stack
end

local function replaceInputWithOutputItems(inputStack, recipe, pos)
    local inventory = minetest.get_inventory({type = "node", pos = pos})
    inputStack:take_item(1)
    inventory:set_stack("input", 1, inputStack)

    local outputStack = ItemStack(recipe.output)

    if inventory:room_for_item("output", outputStack) then
        inventory:add_item("output", outputStack)
    else
        minetest.add_item(pos, outputStack)
    end
end

local function getRemainingSpace(properties)
    return properties.maxCapacity - properties.liquidLevel
end

local function getStackVolume(stack)
    local itemName = stack:get_name()
    local itemDefinition = ItemRegistrator.getItem(itemName)

    if (itemDefinition == nil) then
        return 0
    end

    return itemDefinition.volume * stack:get_count()
end

function CanSoak.getInventoryVolume(pos, inventoryName)
    local inventory = minetest.get_inventory({type = "node", pos = pos})
    local itemStacks = inventory:get_list(inventoryName)

    local volume = 0
    for _,itemStack in ipairs(itemStacks) do
        volume = volume + getStackVolume(itemStack)
    end

    return volume
end

function CanSoak.soak(pos)
    local inputStack = getInventoryList(pos, "input")[1]

    local recipe = RecipeRegistration.getSoakRecipesForItem(inputStack:get_name())

    if (recipe == nil) then
        print("so soaking recipe")
        return false
    end

    local properties = PropertyStorage.readOnly(pos)
    local liquidRatio = properties.liquidLevel / inputStack:get_count()

    if (liquidRatio < recipe.minLiquidRatio) then
        print("not enough water for soaking")
        return false
    end

    local drained = 0

    if(recipe.consumesLiquid > 0) then
        PropertyStorage.write("dummyPlayer", pos, function (properties)
            if(Fillable.drain(properties, recipe.consumesLiquid)) then
                drained = recipe.consumesLiquid --TODO: will not work if soaking recipe drains no water
            end
        end)

        if (drained == 0) then 
            print("nothing drained")
            return false
        end
    end

    replaceInputWithOutputItems(inputStack, recipe, pos)

    if (inputStack:get_count() >0 ) then
        return true
    end

    return false
end

function CanSoak.getTotalVolume(properties)
    local inputItemVolume = CanSoak.getInventoryVolume(properties.pos, "input")
    local outputItemVolume = CanSoak.getInventoryVolume(properties.pos, "output")
    local totalVolume = properties.liquidLevel + inputItemVolume + outputItemVolume
    
    return totalVolume
end

function CanSoak.getAmountOfPassableItems(properties, stack)
    local totalVolume = CanSoak.getTotalVolume(properties)
    local stackVolume = getStackVolume(stack)

    local remainingSpace = getRemainingSpace(properties)

    local isEnoughSpace = remainingSpace - (stackVolume+totalVolume) >= 0

    if(isEnoughSpace) then
        return stack:get_count()
    end

    local itemDefinition = ItemRegistrator.getItem(stack:get_name())

    return remainingSpace / itemDefinition.volume
end

function CanSoak.takeSoakingItem(pos, stack)
    local recipe = RecipeRegistration.getSoakRecipesForItem(stack:get_name())
        
    if (recipe) then
        print ("got soaking recipe")
        minetest.get_node_timer(pos):start(recipe.processTime)
    end
end

return CanSoak