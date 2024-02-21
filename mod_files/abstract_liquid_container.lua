local AbstractLiquidContainer = {}

AbstractLiquidContainer.new = function (pos)
    ---@class LiquidContainer
    local self = {}

    -- private property declarations
    local meta

    -- private method declarations
    local initialize, setLiquidLevel, setLiquidLevelLimit, setLiquidType

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)

        if (meta:get_int("initializedLiquidContainer") == 0) then
            initialize()
        end
    end

    -- public methods

    ---fill barrel with liquid
    ---returns overflow
    ---@param fillAmount
    ---@param fillType string
    ---@return number "overflow"
    self.fillLiquid = function (fillAmount, fillType)
        local liquidType = self.getLiquidType()
        local liquidLevel = self.getLiquidLevel()
        local liquidLevelLimit = self.getLiquidLevelLimit()

        --reject if liquidType doesn't match
        if (liquidType ~= "" and liquidType ~= fillType) then
            return fillAmount
        end

        if (liquidType == "" and liquidLevel == 0) then
            setLiquidType(fillType)
        end

        if (fillAmount + liquidLevel > liquidLevelLimit) then
            setLiquidLevel(liquidLevelLimit)
            return fillAmount + liquidLevel - liquidLevelLimit
        end

        setLiquidLevel(liquidLevel + fillAmount)

        return 0
    end

    ---takes liquid from barrel, returns actually retrieved amount and liquid type
    ---@param amount number
    ---@return number "amount"
    ---@return string|nil "liquid type"
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

        return amount, self.getLiquidType()
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

    -- abstract function
    self.updateDisplay = function () end

    initialize = function()
        setLiquidLevel(0)
        setLiquidLevelLimit(10)
        setLiquidType(nil)
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

    construct()
    return self
end

return AbstractLiquidContainer