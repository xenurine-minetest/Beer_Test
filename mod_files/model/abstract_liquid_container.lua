local modPath = minetest.get_modpath(minetest.get_current_modname()) .. "/mod_files"

---@type IngredientMetaDataHelper
local IngredientMetaDataHelper = dofile(modPath .. "/lib/ingredient_meta_data_helper.lua")

local AbstractLiquidContainer = {}

---@param pos table<string, number>
---@param environment Environment
---@return LiquidContainer
AbstractLiquidContainer.new = function (pos, environment)
    ---@class LiquidContainer
    local self = {}

    -- private property declarations
    local meta

    -- private method declarations
    local initialize, setLiquidLevel, setLiquidLevelLimit, setLiquidType, setTemperature, getTransmittedEnergy, mixIngredients

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)

        if (meta:get_int("initializedLiquidContainer") == 0) then
            initialize()
        end
    end

    -- public methods

    ---calculates heating/cooling dependent of environment
    ---@type fun():boolean
    self.heat = function ()
        self.runIngredientProcessing()
        local oldTemperature = self.getTemperature()

        local transmittedEnergy = getTransmittedEnergy()
        local liquidLevel = self.getLiquidLevel()

        if (liquidLevel == 0) then
            return false
        end

        local addedTemperature = transmittedEnergy/(4190*liquidLevel)

        if (addedTemperature == 1/0 or addedTemperature == 1/-0) then
            addedTemperature = 0
        end

        local newTemperature = self.getTemperature() + addedTemperature

        if (newTemperature > 100) then
            newTemperature = 100
        end

        setTemperature(newTemperature)

        if (oldTemperature == self.getTemperature()) then
            return false
        end

        return true
    end

    ---processes ingredients (enzymatic activity)
    ---@type fun()
    self.runIngredientProcessing = function()
        local processedIngredients = IngredientMetaDataHelper.calculator(
                IngredientMetaDataHelper.get(meta),
                self.getTemperature()
        )

        IngredientMetaDataHelper.set(meta, processedIngredients)
        self.updateDisplay()
    end

    ---gets highest possible temperature
    ---@type fun():number
    self.getMaximumTemperature = function ()
        return 100
    end

    ---fill barrel with liquid
    ---returns overflow
    ---@type fun(liquidData:LiquidData, fillType:string):number
    self.fillLiquid = function (liquidData, fillType)
        local liquidType = self.getLiquidType()
        local liquidLevel = self.getLiquidLevel()
        local liquidLevelLimit = self.getLiquidLevelLimit()
        local liquidTemperature = self.getTemperature()

        --reject if liquidType doesn't match
        if (liquidType ~= "" and liquidType ~= fillType) then
            return liquidData.amount
        end

        if (liquidType == "" and liquidLevel == 0) then
            setLiquidType(fillType)
        end

        local actuallyFillAmount = 0
        local overflowAmount = 0
        
        if (liquidData.amount + liquidLevel > liquidLevelLimit) then
            actuallyFillAmount = liquidLevelLimit - liquidLevel
            overflowAmount = liquidData.amount - actuallyFillAmount
        else
            actuallyFillAmount = liquidData.amount
        end

        local targetAmount = liquidLevel + actuallyFillAmount
        local targetTemperature = (liquidLevel * liquidTemperature + actuallyFillAmount * liquidData.temperature) / targetAmount

        mixIngredients(actuallyFillAmount, liquidLevel, liquidData.ingredients)
        setLiquidLevel(targetAmount)
        setTemperature(targetTemperature)

        return overflowAmount
    end

    ---takes liquid from barrel, returns actually retrieved amount and liquid type
    ---@type fun(amount:number):LiquidData
    self.takeLiquid = function (amount)
        local liquidLevel = self.getLiquidLevel()

        if (liquidLevel < amount) then
            setLiquidLevel(0)
            setLiquidType(nil)

            return {
                amount = liquidLevel,
                temperature = self.getTemperature(),
                ingredients = IngredientMetaDataHelper.get(meta)
            }
        end

        liquidLevel = liquidLevel - amount
        setLiquidLevel(liquidLevel)

        if (liquidLevel == 0) then
            setLiquidType(nil)
        end

        return {
            amount = amount,
            temperature = self.getTemperature(),
            ingredients = IngredientMetaDataHelper.get(meta)
        }
    end

    ---@type fun():number
    self.getLiquidLevel = function ()
        return meta:get_int("liquidLevel")
    end

    ---@type fun():number
    self.getLiquidLevelLimit = function ()
        return meta:get_int("liquidLevelLimit")
    end

    ---@type fun():string
    self.getLiquidType = function()
        return meta:get_string("liquidType")
    end

    ---@type fun():number
    self.getTemperature = function()
        return meta:get_float("temperature")
    end

    ---abstract function, will be overridden by child classes
    ---@type fun()
    self.updateDisplay = function () end

    ---initializes node metadata when node is placed
    ---@type fun()
    initialize = function()
        setLiquidLevel(0)
        setLiquidLevelLimit(10)
        setLiquidType(nil)
        setTemperature(environment.getEnvironmentTemperature())
        IngredientMetaDataHelper.set(meta, IngredientMetaDataHelper.get(meta))
        self.updateDisplay()
        meta:set_int("initializedLiquidContainer", 1)
    end

    ---@type fun(liquidLevel:number)
    setLiquidLevel = function (liquidLevel)
        meta:set_int("liquidLevel", liquidLevel)
        self.updateDisplay()
    end

    ---@type fun(liquidLevelLimit:number)
    setLiquidLevelLimit = function (liquidLevelLimit)
        meta:set_int("liquidLevelLimit", liquidLevelLimit)
        self.updateDisplay()
    end

    ---@type fun(liquidType:string)
    setLiquidType = function(liquidType)
        meta:set_string("liquidType", liquidType)
        self.updateDisplay()
    end

    ---@type fun(temperature:number)
    setTemperature = function(temperature)
        meta:set_float("temperature", temperature)
        self.updateDisplay()
    end

    ---@type fun():number Energy in Watt
    getTransmittedEnergy = function()
        local temperature = self.getTemperature()

        local north = environment.north()
        local northE = north.uValue * (north.temperature - temperature)

        local south = environment.south()
        local southE = south.uValue * (south.temperature - temperature)

        local east = environment.east()
        local eastE = east.uValue * (east.temperature - temperature)

        local west = environment.west()
        local westE = west.uValue * (west.temperature - temperature)

        local top = environment.top()
        local topE = top.uValue * (top.temperature - temperature)

        local bottom = environment.bottom()
        local bottomE = bottom.uValue * (bottom.temperature - temperature)

        return northE + southE + eastE + westE + topE + bottomE
    end

    ---mixes ingredients when new liquid is filled in and saves them
    ---@type fun(actuallyFillAmount:number, oldLiquidLevel:number, ingredients:table<string,number>)
    mixIngredients = function (actuallyFillAmount, oldLiquidLevel, ingredients)
        local existingIngredients = IngredientMetaDataHelper.get(meta)

        for key,value in pairs(existingIngredients) do
            existingIngredients[key] = (value * oldLiquidLevel + actuallyFillAmount * ingredients[key]) / (actuallyFillAmount + oldLiquidLevel)
        end

        IngredientMetaDataHelper.set(meta, existingIngredients)
        self.updateDisplay()
    end

    construct()
    return self
end

return AbstractLiquidContainer

