local modPath = minetest.get_modpath(minetest.get_current_modname()) .. "/mod_files"

local IngredientMetaDataHelper = dofile(modPath .. "/lib/ingredient_meta_data_helper.lua")
local Controller = {}

---@param entity LiquidContainer
---@param clicker table
---@param itemStack ItemStack
---@type fun(entity:LiquidContainer, clicker, itemStack:ItemStack): boolean, ItemStack
function Controller.fillTakeInteraction(entity, clicker, itemStack)
    local interacted = false

    if (itemStack:get_name() == "bucket:bucket_water") then
        local iMeta = itemStack:get_meta()
        local temperature = iMeta:get("temperature")
        if (temperature == nil) then
            temperature = 30
        end

        local itemIngredientMetaDataHelper = IngredientMetaDataHelper.get(iMeta)

        local overflow = entity.fillLiquid({
            amount = 1,
            temperature = temperature,
            ingredients = itemIngredientMetaDataHelper
        }, 'water')

        if (overflow == 0) then
            local playerInventory = minetest.get_inventory({ type="player", name=clicker:get_player_name() })
            playerInventory:add_item("main", ItemStack("bucket:bucket_empty"))

            itemStack:take_item()
        end

        interacted = true

    elseif (itemStack:get_name() == "bucket:bucket_empty") then

        local liquidData = entity.takeLiquid(1)

        if (liquidData.amount > 0) then
            local playerInventory = minetest.get_inventory(
                    { type="player", name=clicker:get_player_name() }
            )

            itemStack:take_item(1)
            local waterBucketStack = ItemStack("bucket:bucket_water")
            local iMeta = waterBucketStack:get_meta()
            IngredientMetaDataHelper.set(iMeta, liquidData.ingredients)
            iMeta:set_float("temperature", liquidData.temperature)
            local leftover = playerInventory:add_item("main", waterBucketStack)
        end

        interacted = true
    end

    return interacted, itemStack
end



return Controller