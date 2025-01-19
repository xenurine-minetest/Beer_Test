local ViewModel = {}

ViewModel.new = function (model, playerName)
    local self = {}

    self.getData = function ()
        return model.getData()
    end

    self.handleInput = function(fields)
        if(fields.fill) then
            model.fill(1)
        end

        if(fields.fill) then
            model.take(1)
        end

        if fields.quit then
            self.destruct()
        end
    end

    self.getPlayerName = function ()
        return playerName
    end

    self.destruct = function()
        --self = nil
    end

    return self
end

return ViewModel