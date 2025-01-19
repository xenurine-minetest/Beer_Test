local Notifier = beer_test.api.classes.Components.Notifier()
local MetadataStorage = beer_test.api.classes.Components.MetadataStorage()
local LiquidContainer = beer_test.api.classes.Components.LiquidContainer()
local Helpers = beer_test.api.classes.Helpers()


local Model = {}

Model.new = function (pos)
    local self = {}
    local private = {} -- Contains private methods
    local properties = { -- Contains private properties that will be persisted
        sealed = false
    }

    local meta = minetest.get_meta(pos)

    local notifier = Notifier.new()
    
    local metadataStorage = MetadataStorage.new(meta)
    local liquidContainer

    
    local function construct()
        local loadedProperties = metadataStorage.load()

        local liquidLevel

        if (loadedProperties == nil) then
            metadataStorage.initialize(properties)
            liquidLevel = 0
        else
            liquidLevel = loadedProperties.liquidLevel
        end

        liquidContainer = LiquidContainer.new({
            liquidLevel = liquidLevel,
            maximumFillLevel = 10,
            onAction = function(data)
                private.saveAndNotify()
            end
        });

        self.fill = liquidContainer.fill
        self.take = liquidContainer.take
    end

    private.saveAndNotify = function ()
        local properties = self.getData()
        metadataStorage.save(properties)
        notifier.notifyListeners(properties)
    end

    self.getData = function()
        local liquidData = liquidContainer.getData()
        return Helpers.mergeTables({properties, liquidData})
    end

    self.addListener = notifier.addListener

    construct()

    return self
end

return Model