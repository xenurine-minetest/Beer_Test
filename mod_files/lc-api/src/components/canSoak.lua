local RecipeRegistration = lc_api.Registrations.Recipes()
local PropertyStorage = lc_api.modules.PropertyStorage()
local EventSystem = lc_api.modules.EventSystem()
local Fillable = lc_api.modules.Components.Fillable()

---@class CanSoak
local CanSoak = {}

function CanSoak.soak(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local input_stack = inv:get_stack("input", 1)

    local recipe = RecipeRegistration.getSoakRecipesForItem(input_stack:get_name())

    if (recipe == nil) then
        return false
    end

    local properties = PropertyStorage.readonly(minetest.get_meta(pos))
    local liquidRatio = properties.liquidLevel / input_stack:get_count()

    if (liquidRatio < recipe.minLiquidRatio) then
        return false
    end

    local drained = 0

    PropertyStorage.write("dummyPlayer", pos, function (properties)
        if(Fillable.drain(properties, recipe.consumesLiquid)) then
            drained = recipe.consumesLiquid
            EventSystem.triggerEvent('fillStateChanged', pos, properties)
        end
    end)

    if (drained == 0) then
        return false
    end

    input_stack:take_item(1)
    inv:set_stack("input", 1, input_stack)
    
    local output_stack = ItemStack(recipe.output)
    
    if inv:room_for_item("output", output_stack) then
        inv:add_item("output", output_stack)
    else
        minetest.add_item(pos, output_stack)
    end
    
    if (input_stack:get_count() >0 ) then
        return true
    end

    return false
end

function CanSoak.getAmountOfPassableItems(pos, stack)
    local recipe = RecipeRegistration.getSoakRecipesForItem(stack:get_name())
    if(recipe == nil) then
        return 0
    end

    if (recipe.inputVolume == 0) then
        return stack:get_count()
    end
    
    local properties = PropertyStorage.readonly(minetest.get_meta(pos))
    local remainingSpace = properties.maxCapacity - properties.liquidLevel

    local isenoughSpace = remainingSpace >= stack:get_count() * recipe.inputVolume


    if(isenoughSpace) then
        return stack:get_count()
    end

    return remainingSpace / recipe.inputVolume
end

function CanSoak.takeSoakingItem(pos, stack)
    local recipe = RecipeRegistration.getSoakRecipesForItem(stack:get_name())
        
    if (recipe) then
        minetest.get_node_timer(pos):start(recipe.processTime)
    end
end

return CanSoak