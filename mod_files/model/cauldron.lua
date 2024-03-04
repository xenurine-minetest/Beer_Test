local modPath = minetest.get_modpath(minetest.get_current_modname()).."/mod_files"

local LiquidContainer = dofile(modPath.."/model/abstract_liquid_container.lua")
---@type IngredientMetaDataHelper
local IngredientMetaDataHelper = dofile(modPath .. "/lib/ingredient_meta_data_helper.lua")
local CauldronView = dofile(modPath.."/view/cauldron.lua")

local Cauldron = {}

Cauldron.new = function (pos, environment)
    ---@class Cauldron :LiquidContainer
    local self = LiquidContainer.new(pos, environment)

    -- private property declarations
    local meta

    -- private method declarations
    local initialize, updateFormSpec, updateInfo

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)

        if (meta:get_int("initialized") == 0) then
            initialize()
        end
    end

    -- public methods
    ---@type fun(setFormSpec:string)
    self.setFormSpec = function(setFormSpec)
        meta:set_string("formSpec", setFormSpec)
    end

    ---@type fun(): string
    self.getFormSpec = function ()
        return meta:get_string("formSpec")
    end

    ---@type fun()
    self.updateDisplay = function()
        updateFormSpec()
        updateInfo()
    end

    -- private methods
    ---@type fun()
    initialize = function ()
        self.updateDisplay()
        meta:set_int("initialized", 1)
    end

    ---@type fun()
    updateFormSpec = function()
        self.setFormSpec(CauldronView.formSpecs.debug(
                {
                    level = self.getLiquidLevel(),
                    limit = self.getLiquidLevelLimit(),
                    type = self.getLiquidType(),
                    ingredients = IngredientMetaDataHelper.get(meta)
                },
                self.getTemperature()
        ))
    end

    ---@type fun()
    updateInfo = function()
        local infoText = ""
        local liquidType = self.getLiquidType()

        if(liquidType == "" and self.getLiquidLevel() == 0) then
            infoText = CauldronView.infoTexts.empty()
        else
            infoText = CauldronView.infoTexts.filled({
                type = self.getLiquidType(),
                amount = self.getLiquidLevel(),
                limit = self.getLiquidLevelLimit()
            })
        end

        meta:set_string("infotext", infoText)
    end

    construct()
    return self;
end

return Cauldron