local LiquidContainer = {}

LiquidContainer.new = function(settings)
    local self = {}

    local liquidLevel = nil
    local maximumFillLevel = nil
    local onActionCallback = nil

    local function construct()
        if(type(settings) ~= "table") then
            error("LiquidContainers constructor parameter has to be a table!")
        end

        if(type(settings.liquidLevel) ~= "number") then
            error("LiquidContainers setting \"liquidLevel\" has to be a number!")
        end

        if(type(settings.maximumFillLevel) ~= "number") then
            error("LiquidContainers setting \"maximumFillLevel\" has to be a number!")
        end

        if(type(settings.onAction) ~= "function") then
            error("LiquidContainers setting \"onAction\" has to be a function!")
        end

        liquidLevel = settings.liquidLevel
        maximumFillLevel = settings.maximumFillLevel
        onActionCallback = settings.onAction
    end

    self.fill = function (amount)
        if (liquidLevel + amount <= maximumFillLevel) then
            liquidLevel = liquidLevel + 1
            onActionCallback(self.getData())
            return true
        end

        return false
    end

    self.take = function (amount)
        if (liquidLevel - amount >= 0) then
            liquidLevel = liquidLevel - 1
            print(liquidLevel)

            return true
        end

        return false
    end

    self.getData = function ()
        return {
            liquidLevel = liquidLevel,
            maximumFillLevel = maximumFillLevel
        }
    end

    construct()

    return self
end

return LiquidContainer