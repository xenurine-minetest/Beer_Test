local helpers = {
    copyTable = function (t)
        local t2 = {}

        for k,v in pairs(t) do
            t2[k] = v
        end

        return t2
    end,
    intToBool = function(int)
        return (int>=1)
    end,
    boolToInt = function(bool)
        return (bool==true and 1 or 0)
    end
}
local MetadataStorage = {}

MetadataStorage.new = function (meta)
    local self = {}

    self.save = function (properties)
        local propertyNameDefinitions = {}
        for propertyName, value in pairs(properties) do

            if (type(value) == "string") then
                propertyNameDefinitions[propertyName] = "string"
                meta:set_string(propertyName, value)
            end

            if (type(value) == "number") then
                propertyNameDefinitions[propertyName] = "number"
                meta:set_int(propertyName, value)
            end

            if (type(value) == "boolean") then
                propertyNameDefinitions[propertyName] = "bool"
                meta:set_int(propertyName, helpers.boolToInt(value))
            end
        end

        meta:set_string("properties", minetest.serialize(propertyNameDefinitions))
    end

    self.load = function ()
        print("init status on load: ".. meta:get_int("initialized"))
        if (self.isInitialized() == false) then
            return nil
        end

        local propertyNameDefinitions = minetest.deserialize(meta:get_string("properties"))

        local properties = {}

        for propertyName, propertyType in pairs(propertyNameDefinitions) do
            if (propertyType == "string") then
                properties[propertyName] = meta:get_string(propertyName)
            end

            if (propertyType == "number") then
                properties[propertyName] = meta:get_int(propertyName)
            end

            if (propertyType == "boolean") then
                properties[propertyName] = helpers.intToBool(meta:get_int(propertyName))
            end
        end

        return properties
    end

    self.initialize = function (properties)
        meta:set_int("initialized", 1)
        print("init status after init:" .. meta:get_int("initialized"))
        self.save(properties)
    end

    self.isInitialized = function()
        if (meta:get_int("initialized") == 0) then
            return false
        end
    end

    return self
end

return MetadataStorage