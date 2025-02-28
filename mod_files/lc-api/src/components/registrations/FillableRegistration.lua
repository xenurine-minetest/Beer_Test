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
        print("right click3")
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
    },
    events = {
        "beforeFill", "filled", "beforeDrain", "drained"
    }
})

