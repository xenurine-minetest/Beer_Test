--- @class EventSystem
local EventSystem = {
    handlers = {}
}

-- Registriere einen neuen Event-Handler für ein bestimmtes Event
EventSystem.registerEvent = function(event_name, callback)
    if not EventSystem.handlers[event_name] then
        EventSystem.handlers[event_name] = {}
    end
    table.insert(EventSystem.handlers[event_name], callback)
end

-- Löst ein Ereignis aus und ruft alle zugehörigen Handler auf
EventSystem.triggerEvent = function(event_name, ...)
    if EventSystem.handlers[event_name] then
        for _, callback in ipairs(EventSystem.handlers[event_name]) do
            callback(...)
        end
    end
end

return EventSystem