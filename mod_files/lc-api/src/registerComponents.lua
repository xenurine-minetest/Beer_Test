local ComponentRegistrator = lc_api.Registrations.Components()

local Fillable = lc_api.modules.Components.Fillable()
ComponentRegistrator.registerStorageComponents('fillable', {
    usesStorage = true,
    registrationProperty = {
        name = "fillable",
        type = "boolean",
        default = true
    },
    onConstruct = function (nodeDefinition, storageProperties)
        if (nodeDefinition.fillable) then
            Fillable.create(storageProperties, nodeDefinition.maxCapacity or 10)
        end
    end,
    onRightClick = function(pos, clicker, properties) 
        local item = clicker:get_wielded_item():get_name()

        if (item and item == "bucket:bucket_water") then
            if (Fillable.fill(properties, 1)) then
                clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_water"))
            end
                
            return true
        end

        if (item and item == "bucket:bucket_empty") then
            if (Fillable.drain(properties, 1)) then
                clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_empty"))
            end
            
            return true
        end
    end,
    receiveCommands = {
        fill = function (properties, amount)
			Fillable.fill(properties, amount)
		end,
        drain = function (properties, amount)
			Fillable.drain(properties, amount)
		end
    }
})

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
    }
})

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
                return CanSoak.getAmountOfPassableItems(pos, stack)
            end,
            put = function(pos, index, stack, player)
                CanSoak.takeSoakingItem(pos, stack)
            end
        },
        output = {
            allowPut = function()
                return 0
            end
        }
    },
    timer = function(pos, elapsed)
        return CanSoak.soak(pos)
    end,
    onChange = function(pos, properties, eventContext) 
        if (eventContext and eventContext.actor == "canSoak") then
            return false
        end

        local inventory = minetest.get_inventory({type = "node", pos = pos})
        local itemStacks = inventory:get_list("input")
        for _,itemStack in ipairs(itemStacks) do
            CanSoak.takeSoakingItem(pos, itemStack)
        end
    end
})