local RecipeRegistration = lc_api.Registrations.Recipes()
local PropertyStorage = lc_api.modules.PropertyStorage()
local Fillable = lc_api.modules.Components.Fillable()

---@class CanSoak
local CanSoak = {}

local function replaceInputWithOutputItems(inputStack, inv, recipe)
    inputStack:take_item(1)
    inv:set_stack("input", 1, inputStack)

    local outputStack = ItemStack(recipe.output)

    if inv:room_for_item("output", outputStack) then
        inv:add_item("output", outputStack)
    else
        minetest.add_item(pos, outputStack)
    end
end

function CanSoak.soak(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local input_stack = inv:get_stack("input", 1)

    local recipe = RecipeRegistration.getSoakRecipesForItem(input_stack:get_name())

    if (recipe == nil) then
        return false
    end

    local properties = PropertyStorage.readOnly(pos)
    local liquidRatio = properties.liquidLevel / input_stack:get_count()

    if (liquidRatio < recipe.minLiquidRatio) then
        return false
    end

    local drained = 0

    if(recipe.consumesLiquid > 0) then
        PropertyStorage.write("dummyPlayer", pos, function (properties)
            if(Fillable.drain(properties, recipe.consumesLiquid, {actor = "canSoak"})) then
                drained = recipe.consumesLiquid
            end
        end)

        if (drained == 0) then
            return false
        end
    end
 
    replaceInputWithOutputItems(input_stack, inv)
    
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
    
    local properties = PropertyStorage.readOnly(pos)
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