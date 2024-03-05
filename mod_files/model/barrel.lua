local modPath = minetest.get_modpath(minetest.get_current_modname()) .. "/mod_files"

local LiquidContainer = dofile(modPath.."/model/abstract_liquid_container.lua")
---@type IngredientMetaDataHelper
local IngredientMetaDataHelper = dofile(modPath .. "/lib/ingredient_meta_data_helper.lua")
local BarrelView = dofile(modPath .. "/view/barrel.lua")

local Barrel = {}

Barrel.new = function (pos, environment)
    ---@class Barrel :LiquidContainer
    local self = LiquidContainer.new(pos, environment)

    -- private property declarations
    local meta, inventory, getSoakingItemStack

    -- private method declarations
    local initialize, setInventory, updateFormSpec, updateInfo

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)
        inventory = meta:get_inventory()

        if (meta:get_int("initialized") == 0) then
            initialize()
        end
    end

    -- public methods
    ---@type fun(setFormSpec:string)
    self.setFormSpec = function(setFormSpec)
        meta:set_string("formSpec", setFormSpec)
    end

    ---@type fun():string
    self.getFormSpec = function ()
        return meta:get_string("formSpec")
    end

    ---@type fun():table<number,ItemStack>
    self.getSourceInventory = function ()
        return inventory:get_list("src")
    end

    ---@type fun():table<number,ItemStack>
    self.getDestinyInventory = function ()
       return inventory:get_list("dst")
    end

    ---returns if barrel has items in source inventory that got soaking craft recipe
    ---@type fun():boolean
    self.hasSoakingItems = function ()
        local soakingItemStack = getSoakingItemStack()
        if (soakingItemStack ~= nil) then
            return true
        end

        return false
    end

    ---runs soak craft recipes for all soakable items if available
    ---@type fun():boolean
    self.soak = function ()
        local soakingItemStack, soakingItemStackIndex = getSoakingItemStack()
        local takenSoakingItem = soakingItemStack:take_item(1)

        local liquidLevel = self.getLiquidLevel()
        local liquidType = self.getLiquidType()

        if (takenSoakingItem:get_count() > 0 and liquidType == "water" and liquidLevel > 0) then
            inventory:set_stack("src", soakingItemStackIndex, soakingItemStack)
            self.takeLiquid(1)

            local dst_stack = inventory:get_stack('dst', 1)
            dst_stack:add_item(
                beer_test.soakRecipeHandler.getDestinationForSource(takenSoakingItem:get_name())
            )
            inventory:set_stack('dst', 1, dst_stack)

            return true
        end

        return false
    end

    ---checks if all inventories are empty
    ---@type fun():boolean
    self.allInventoriesEmpty = function ()
        return inventory:is_empty("src") and inventory:is_empty("dst")
    end

    -- private methods
    ---@type fun(name:string, size:number)
    setInventory = function (name, size)
        inventory:set_size(name, size)
    end

    ---@type fun()
    initialize = function ()
        setInventory("src", 1)
        setInventory("dst", 1)
        self.updateDisplay()
        meta:set_int("initialized", 1)
    end

    ---@type fun() :ItemStack,number|nil
    getSoakingItemStack = function ()
        local sourceInventory = self.getSourceInventory()
        for i, itemStack in ipairs(sourceInventory) do
            if (beer_test.soakRecipeHandler.isSoakSource(itemStack:get_name())) then
                return itemStack, i
            end
        end

        return nil
    end

    ---@type fun()
    updateFormSpec = function()
        self.setFormSpec(BarrelView.formSpecs.debug(
                {
                    amount = self.getLiquidLevel(),
                    temperature = self.getTemperature(),
                    ingredients = IngredientMetaDataHelper.get(meta),
                    limit = self.getLiquidLevelLimit(),
                    type = self.getLiquidType(),
                },
                "nodemeta:"..pos.x..","..pos.y..","..pos.z
        ))
    end

    ---@type fun()
    updateInfo = function()
        local infoText = ""
        local liquidType = self.getLiquidType()

        if(liquidType == "" and inventory:is_empty("src")) then
            infoText = BarrelView.infoTexts.empty()
        else
            infoText = BarrelView.infoTexts.filled({
                type = self.getLiquidType(),
                amount = self.getLiquidLevel(),
                limit = self.getLiquidLevelLimit()
            }, inventory:get_list("src")[1]:get_name())
        end

        meta:set_string("infotext", infoText)
    end

    ---@type fun()
    self.updateDisplay = function()
        updateFormSpec()
        updateInfo()
    end

    construct()
    return self;
end

return Barrel