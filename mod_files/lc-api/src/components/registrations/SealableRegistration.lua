local ComponentRegistrator = lc_api.Registrations.Components()
local Sealable = lc_api.modules.Components.Sealable()

ComponentRegistrator.registerStorageComponents('sealable', {
    usesStorage = true,
    registrationProperty = {
        name = "sealable",
        type = "boolean",
        default = false
    },
    onConstruct = function (nodeDefinition, properties)
        if(nodeDefinition.sealable) then
            Sealable.create(properties)
        end
    end,
    receiveCommands = {
        seal = function (properties)
			Sealable.seal(properties)
		end,
		unseal = function (properties)
			Sealable.unseal(properties)
		end
    },
    onEvent = {
        beforeFill = function(eventDetails)
            print("run beforeFill callback for seal")
            if (eventDetails.nodeProperties.sealed) then
                print("result for soak is false")
                return false
            end

            print("result for soak is true")
            return true
        end,
        beforeDrain = function(eventDetails)
            print("do beforeDrain")
            print(dump2(eventDetails, "EVEMTDETAILS"))
            if (eventDetails.nodeProperties.sealed) then
                print("do not drain!")
                return false
            end

            return true
        end
    },
    events = {
        "beforeSeal", "sealed", "beforeUnseal", "unsealed"
    }
})