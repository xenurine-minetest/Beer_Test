local InfiniteLoop = {}

InfiniteLoop.new = function (callback, finishCallback)
    local self = {}

    local execute

    local jobReferences = {}

    self.start = function (time, startDelay)
        startDelay = startDelay or 0
        execute(startDelay,time)
        return self
    end

    execute = function (startDelay,time)
        local jobReference = minetest.after (startDelay, function()
            callback()
            table.insert(jobReferences, execute(time, time))
        end)
        table.insert(jobReferences, jobReference)
        return jobReference
    end

    self.stop = function ()
        for k,v in ipairs(jobReferences) do
            local reference = table.remove(jobReferences, k)
            reference.cancel()
        end
    end

    self.stopAfter = function (stopAfter)
        minetest.after(stopAfter, function ()
            self.stop()

            if (type(finishCallback) == "function") then
                finishCallback()
            end
        end)
    end

    return self
end

return InfiniteLoop