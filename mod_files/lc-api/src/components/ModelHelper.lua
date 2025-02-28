local EventSystem = lc_api.modules.EventSystem()

local ModelHelper = {}

ModelHelper.writeIfAllowedByEvent = function (properties, eventName, actor, callback)
    local copiedProperties = table.shallow_copy(properties)
    callback(copiedProperties)

    local triggerResults = EventSystem.trigger(eventName, {
        nodeProperties =  copiedProperties,
        actor = actor
    })

    for i,result in ipairs(triggerResults) do
        print("result nr "..i)
        if (result == false) then
            print(" return false")
            return false
        else
            print(" return true")
        end
    end

    table.override_table(properties, copiedProperties)

    return true
end

return ModelHelper