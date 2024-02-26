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
    local initialize, setLiquidLevel, setLiquidLevelLimit, setLiquidType, setTemperature, getTransmittedEnergy

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)

        if (meta:get_int("initializedLiquidContainer") == 0) then
            initialize()
        end
    end

    -- public methods

    ---@type fun():boolean
    self.heat = function ()
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

        setTemperature(self.getTemperature() + addedTemperature)

        if (oldTemperature == self.getTemperature()) then
            return false
        end

        return true
    end

    self.getEnvironmentTemperature = function()
        return 20
    end

    self.getMaximumTemperature = function ()
        return 100
    end

    ---fill barrel with liquid
    ---returns overflow
    ---@param fillAmount
    ---@param fillType string
    ---@return number "overflow"
    self.fillLiquid = function (fillAmount, fillType, fillTemperature)
        local liquidType = self.getLiquidType()
        local liquidLevel = self.getLiquidLevel()
        local liquidLevelLimit = self.getLiquidLevelLimit()
        local liquidTemperature = self.getTemperature()

        --reject if liquidType doesn't match
        if (liquidType ~= "" and liquidType ~= fillType) then
            return fillAmount
        end

        if (liquidType == "" and liquidLevel == 0) then
            setLiquidType(fillType)
        end

        local actuallyFillAmount = 0
        local overflowAmount = 0
        if (fillAmount + liquidLevel > liquidLevelLimit) then
            actuallyFillAmount = liquidLevelLimit
            overflowAmount = fillAmount + liquidLevel - liquidLevelLimit
        else
            actuallyFillAmount = fillAmount
        end

        local targetAmount = liquidLevel + actuallyFillAmount
        local targetTemperature = (liquidLevel * liquidTemperature + actuallyFillAmount * fillTemperature) / targetAmount

        setLiquidLevel(targetAmount)
        setTemperature(targetTemperature)

        return overflowAmount
    end

    ---takes liquid from barrel, returns actually retrieved amount and liquid type
    ---@param amount number
    ---@return number "amount"
    ---@return number "temperature"
    ---@return string|nil "liquid type" (deprecated)
    self.takeLiquid = function (amount)
        local liquidType = self.getLiquidType()
        local liquidLevel = self.getLiquidLevel()

        if (liquidLevel < amount) then
            setLiquidLevel(0)
            setLiquidType(nil)
            return liquidLevel, liquidType
        end

        liquidLevel = liquidLevel - amount
        setLiquidLevel(liquidLevel)

        if (liquidLevel == 0) then
            setLiquidType(nil)
        end

        return amount, self.getTemperature(), self.getLiquidType()
    end

    self.getLiquidStatus = function ()
        return self.getLiquidLevel(), self.getLiquidType()
    end

    self.getLiquidLevel = function ()
        return meta:get_int("liquidLevel")
    end

    self.getLiquidLevelLimit = function ()
        return meta:get_int("liquidLevelLimit")
    end

    self.getLiquidType = function()
        return meta:get_string("liquidType")
    end

    ---@type fun():number
    self.getTemperature = function()
        return meta:get_float("temperature")
    end

    -- abstract function
    self.updateDisplay = function () end

    initialize = function()
        setLiquidLevel(0)
        setLiquidLevelLimit(10)
        setLiquidType(nil)
        setTemperature(self.getEnvironmentTemperature())
        self.updateDisplay()
        meta:set_int("initializedLiquidContainer", 1)
    end

    setLiquidLevel = function (liquidLevel)
        meta:set_int("liquidLevel", liquidLevel)
        self.updateDisplay()
    end

    setLiquidLevelLimit = function (liquidLevelLimit)
        meta:set_int("liquidLevelLimit", liquidLevelLimit)
        self.updateDisplay()
    end

    setLiquidType = function(liquidType)
        meta:set_string("liquidType", liquidType)
        self.updateDisplay()
    end

    setTemperature = function(temperature)
        --minetest.log("action", "set temp to: " .. temperature)
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

    construct()
    return self
end

return AbstractLiquidContainer