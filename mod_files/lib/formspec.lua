---@class RefreshingFormSpecs
local refreshingFormSpecs = {}

---@type table<string, string>
refreshingFormSpecs.playerInstances = {}

---@param formSpecMaster function object that controls formspecs lifecycle. Must implement public function getFormSpec()
---@param formSpecName string formspec identifier
---@param playerName string players name
---@param isRecursiveCall boolean shouldn't get set to true from outside
refreshingFormSpecs.open = function (formSpecMaster, formSpecName, playerName, isRecursiveCall)
    if (isRecursiveCall) then
        if (refreshingFormSpecs.playerInstances[playerName] == nil) then
            return
        end
    else
        refreshingFormSpecs.register(formSpecName, playerName)
    end

    minetest.after(0.3, function()
        refreshingFormSpecs.open(formSpecMaster, formSpecName, playerName,true)
    end)

    minetest.show_formspec(playerName, formSpecName, formSpecMaster.getFormSpec())
end

refreshingFormSpecs.register = function (formSpecName, playerName)
    refreshingFormSpecs.playerInstances[playerName] = formSpecName

    minetest.register_on_player_receive_fields(function(player, formname, fields)
        if(fields["quit"] == "true") then
            refreshingFormSpecs.playerInstances[playerName] = nil
        end
    end)
end

return refreshingFormSpecs