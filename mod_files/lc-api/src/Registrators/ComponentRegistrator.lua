local EventSystem = lc_api.modules.EventSystem()

---@class ComponentRegistration
local ComponentRegistrator = {}

local components = {}

local function checkComponent(name, definition)
    local errorMessageTemplate = "error in component " .. name.. ": "

    assert(name ~= "", "name can not be empty")
    assert(type(definition) == "table", errorMessageTemplate .. "definition must be a table")
    assert(type(definition.usesStorage) ~= nil, errorMessageTemplate .. "usesStorage can't be nil")
    assert(type(definition.registrationProperty) == "table", errorMessageTemplate .. "registrationProperty must be a table")
    assert(type(definition.registrationProperty.name) == "string", errorMessageTemplate .. "registrationProperty.name must be a string")
    assert(type(definition.registrationProperty.default) == "boolean", errorMessageTemplate .. "registrationProperty.default must be boolean")

    if (definition.usesStorage) then
        assert(type(definition.onConstruct) == "function", errorMessageTemplate .. "onConstruct must be a function")
    end
    if(definition.neededInventories == nil) then
        definition.neededInventories = {}
    end
    if(definition.receiveCommands == nil) then
        definition.receiveCommands = {}
    end
    if (components[name] ~=nil) then
        minetest.log("info", "Previously registered component " .. name .. " was overridden")
    end
end

function ComponentRegistrator.registerStorageComponents(name, definition)

    checkComponent(name, definition)
    components[name] = definition
end

function ComponentRegistrator.getStorageComponentByName(name)
    return components[name]
end

function ComponentRegistrator.getStorageComponents()
    return components
end

ComponentRegistrator.initialize = function()
    print("initialize")
    for componentName, component in pairs(components) do
        print(componentName)
        if(component.events ~= nil) then
            print("has events")
            for _, eventName in ipairs(component.events) do
                print("registering " .. eventName)
                EventSystem.registerEvent(eventName)
            end
        end

        if(type(component.onEvent) == "table") then
            for eventName, callback in pairs(component.onEvent) do
                EventSystem.addListener(eventName, callback)
            end
        end
    end
end

ComponentRegistrator.iterators = {
    componentsPropertiesIterator = function (callback) 
        for componentName, componentDefinition in pairs(components) do
            callback(componentDefinition, componentDefinition.registrationProperty) 
        end
    end,
    doIfNodeHasComponent = function (nodeDefinition, callback) 
        ComponentRegistrator.iterators.componentsPropertiesIterator(function (componentDefinition, registrationProperty)
            if (nodeDefinition[registrationProperty.name] ~= (nil or false) ) then
                callback(componentDefinition, registrationProperty)
            end
        end)
    end,
}

return ComponentRegistrator
