local Notifier = {}

Notifier.new = function ()
    local self = {}

    local listeners = {}

    self.addListener = function(listener)
        table.insert(listeners, listener)
    end

    self.notifyListeners = function(data)
        for _, listener in ipairs(listeners) do
            listener(data)
        end
    end

    return self
end

return Notifier;