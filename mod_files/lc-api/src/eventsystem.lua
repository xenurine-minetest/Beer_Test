

local events = {}
local observers = {}

--- @class EventSystem
local EventSystem = {}

EventSystem.addObserver = function(observer)
    table.insert(observers, observer)
end

EventSystem.registerEvent = function(eventName, listenerCallback)
    if (events[eventName] ~= nil) then
        return false
    end

    events[eventName] = {}

    if (type(listenerCallback) == "function") then
        EventSystem.addListener(eventName, listenerCallback)
    end
end

EventSystem.addListener = function(eventName, listenerCallback)
    if (events[eventName] == nil) then
        EventSystem.registerEvent(eventName)
    end

    print(eventName)
    print(dump2(events, "all events"))
    table.insert(events[eventName], listenerCallback)
    return true
end

EventSystem.trigger = function(eventName, eventDetails)
    if (events[eventName] == nil) then
        error("event does not exist")
    end

    local listenerResults = {}

    for _,listener in ipairs(events[eventName]) do
        table.insert(listenerResults, listener(eventDetails))
    end

    for _, observer in ipairs(observers) do
        observer(eventName, eventDetails)
    end

    return listenerResults
end

return EventSystem