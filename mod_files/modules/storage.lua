local Storage = {}

Storage.get = function (meta)
    local propertiesDefinition = minetest.deserialize(meta:get_string("properties"))

    if(propertiesDefinition == nil) then
        return nil
    end

    local properties = {}
    for property, propertyType in pairs(propertiesDefinition) do
        if (propertyType == "string") then
            properties[property] = meta:get_string(property)
        end

        if (propertyType == "number") then
            properties[property] = meta:get_int(property)
        end

        if (propertyType == "boolean") then
            properties[property] = (meta:get_int(property) == 1 or false)
        end
    end

    return properties
end

Storage.set = function (properties, meta)
    local propertiesDefinition = {}

    for property, value in pairs(properties) do
        propertiesDefinition[property] = type(value)

        if (type(value) == "string") then
            meta:set_string(property, value)
        end

        if (type(value) == "number") then
            meta:set_int(property, value)
        end

        if (type(value) == "boolean") then
            value = (value == true and 1 or 0 )
            meta:set_string(property, value)
        end
    end
    
    meta:set_string("properties", minetest.serialize(propertiesDefinition))
end

return Storage