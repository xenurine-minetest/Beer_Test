local ComponentRegistrator = lc_api.Registrations.Components()
local PropertyStorage = lc_api.modules.PropertyStorage()
local EventSystem = lc_api.modules.EventSystem()

local CanSoak = lc_api.modules.Components.CanSoak()

ComponentRegistrator.registerStorageComponents('canSoak', {
    usesStorage = false,
    registrationProperty = {
        name = "canSoak",
        default = false
    },
    neededInventories = {
        input = { 
            allowPut = function(pos, index, stack, player)
                local nodeProperties = PropertyStorage.readOnly(pos)
                return CanSoak.getAmountOfPassableItems(nodeProperties, stack)
            end,
            put = function(pos, index, stack, player)
                print("take soaking item if possible")
                EventSystem.trigger("filled", {
                    nodeProperties = PropertyStorage.readOnly(pos)
                })
                CanSoak.takeSoakingItem(pos, stack)
            end,
            take = function(pos, listname, index, stack, player)
                EventSystem.trigger("filled", {
                    nodeProperties = PropertyStorage.readOnly(pos)
                })
                
            end
        },
        output = {
            allowPut = function(pos, index, stack, player)
                local nodeProperties = PropertyStorage.readOnly(pos)
                return CanSoak.getAmountOfPassableItems(nodeProperties, stack)
            end,
            put = function(pos, index, stack, player)
                EventSystem.trigger("filled", {
                    nodeProperties = PropertyStorage.readOnly(pos)
                })
            end,
            take = function(pos, listname, index, stack, player)
                EventSystem.trigger("filled", {
                    nodeProperties = PropertyStorage.readOnly(pos)
                })
            end
        }
    },
    timer = function(pos, elapsed)
        print("soak if possible")
        return CanSoak.soak(pos)
    end,
    onEvent = {
        all = function (eventName, eventDetails) 
            local pos = eventDetails.nodeProperties.pos
            print("event name1: "..eventName)


            print("event name3: "..eventName)
            local inventory = minetest.get_inventory({type = "node", pos = pos})
            local itemStacks = inventory:get_list("input")
            for _,itemStack in ipairs(itemStacks) do
                print("event name4: "..eventName)
                CanSoak.takeSoakingItem(pos, itemStack)
            end
        end,
        beforeFill = function (eventDetails) 
            print("run beforeFill callback for soak")

            local totalVolume = CanSoak.getTotalVolume(eventDetails.nodeProperties)

            return totalVolume <= eventDetails.nodeProperties.maxCapacity
        end
    },
    events = {
        "beforeSoak", "soaked"
    }
})