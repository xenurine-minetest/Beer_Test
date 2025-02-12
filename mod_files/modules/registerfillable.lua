local Fillable = beer_test.modules.Components.Fillable()
local Sealable = beer_test.modules.Components.Sealable()
local EventSystem = beer_test.modules.EventSystem()
local PropertyStorage = beer_test.modules.PropertyStorage()
local OpenedFormspecStorage = beer_test.modules.OpenedFormspecStorage()
local RecipeRegistration = beer_test.register.Recipes()

local function buildReceiveFieldsCommands(definition, properties)
    local commands = {
        fill = function (amount)
			Fillable.fill(properties, amount)
		end,
        drain = function (amount)
			Sealable.drain(properties, amount)
		end
    }

    if(definition.sealable == true) then
        commands["seal"] = function ()
			Sealable.seal(properties)
		end
        commands["unseal"] = function ()
			Sealable.unseal(properties)
		end
    end

    return commands
end

local getOnContructCallback = function(definition)
    return function (pos) 
        PropertyStorage.write("dummyPlayer", pos, function (properties)
            Fillable.create(properties, definition.maxCapacity or 10)

            if(definition.sealable == true) then
                Sealable.create(properties)
            end

            if(type(definition.inventories) == "table") then
                local meta = minetest.get_meta(pos)
		        local inv = meta:get_inventory()

                for name, size in pairs(definition.inventories) do
                    if(type(name) ~= "string" or type(size) ~= "number") then error() end
                    inv:set_size(name, size)
                end
            end
        end)
    end
end

local function getrightClickCallback(nodeName, definition)
    return function(pos, node, clicker, itemstack, pointed_thing) 
        local playerName = clicker:get_player_name()
            local item = clicker:get_wielded_item():get_name()

            if (item and item == "bucket:bucket_water") then
                PropertyStorage.write(playerName, pos, function (properties)
                    if (Fillable.fill(properties, 1)) then
                        clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_water"))
                        EventSystem.triggerEvent('fillStateChanged', pos, properties)
                    end
                end)
                
                return
            end

            if (item and item == "bucket:bucket_empty") then
                PropertyStorage.write(playerName, pos, function (properties)
                    if (Fillable.drain(properties, 1)) then
                        clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_empty"))
                        EventSystem.triggerEvent('fillStateChanged', pos, properties)
                    end
                end)
                
                return
            end

            OpenedFormspecStorage.add(pos, playerName)
            
            minetest.show_formspec(
                playerName,
                nodeName,
                definition.formspec(
                    pos,
                    PropertyStorage.readonly(minetest.get_meta(pos))
                )
            )
    end
end

local function getRecieveFieldCallback(nodeName, definition)
    return function(player, formName, fields)
		print(dump2(fields, "FIELDS"))
        if (formName ~= nodeName) then
            return
        end
		
        local playerName = player:get_player_name()
		
        if (fields.quit == "true") then
            OpenedFormspecStorage.remove(nil, playerName)
        end

		OpenedFormspecStorage.debug()
		local pos = OpenedFormspecStorage.getPosByPlayer(playerName)

		if (pos ~= nil) then
            PropertyStorage.write(playerName, pos, function (properties)
                definition.on_receive_fields(fields, buildReceiveFieldsCommands(definition, properties))
                EventSystem.triggerEvent('fillStateChanged', pos, properties)
            end)
		end
    end
end

local getChangeEventHandler = function(definition, nodeName, nodeVariantNames)
    return function(pos, properties)
        definition.onChange(pos, properties, nodeVariantNames)

        local playerNames = OpenedFormspecStorage.getPlayerNamesByPos(pos)
        for _,playerName in ipairs(playerNames) do
            minetest.show_formspec(playerName,nodeName,definition.formspec(pos, properties))
        end
    end
end

local getAllowInventoryPutCallback = function ()
    return function (pos, listname, index, stack, player)
        if (listname == "input") then
            local recipe = RecipeRegistration.getSoakRecipesForItem(stack:get_name())
            if(recipe == nil) then
                return 0
            end

            if (recipe.inputVolume == 0) then
                return stack:get_count()
            end
            
            local properties = PropertyStorage.readonly(minetest.get_meta(pos))
            local remainingSpace = properties.maxCapacity - properties.liquidLevel

            local isenoughSpace = remainingSpace >= stack:get_count() * recipe.inputVolume

            if(isenoughSpace) then
                return stack:get_count()
            end

            return 0
        end

        return 0
    end
end

local getInventoryPutCallback = function ()
    return function (pos, listname, index, stack, player) 
        if (listname ~= "input") then
            return
        end

        local recipe = RecipeRegistration.getSoakRecipesForItem(stack:get_name())

        if (recipe) then
            minetest.get_node_timer(pos):start(recipe.processTime)
        end
    end
end

local getTimerCallback = function ()
    return function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local input_stack = inv:get_stack("input", 1)

        local recipe = RecipeRegistration.getSoakRecipesForItem(input_stack:get_name())

        if (recipe == nil) then
            return false
        end

        local properties = PropertyStorage.readonly(minetest.get_meta(pos))
        local liquidRatio = properties.liquidLevel / input_stack:get_count()

        if (liquidRatio < recipe.minLiquidRatio) then
            return false
        end

        local drained = 0

        PropertyStorage.write("dummyPlayer", pos, function (properties)
            print(recipe.consumesLiquid)
            if(Fillable.drain(properties, recipe.consumesLiquid)) then
                drained = recipe.consumesLiquid
                EventSystem.triggerEvent('fillStateChanged', pos, properties)
            end
        end)

        if (drained == 0) then
            return false
        end

        input_stack:take_item(1)
        inv:set_stack("input", 1, input_stack)
        
        local output_stack = ItemStack(recipe.output)
        
        if inv:room_for_item("output", output_stack) then
            inv:add_item("output", output_stack)
        else
            minetest.add_item(pos, output_stack)
        end
        
        if (input_stack:get_count() >0 ) then
            return true
        end

        return false
    end
end

return function (nodeName, definition)
    local nodeVariantNames = {}

    for variantName,variant in pairs(definition.variants) do
        local nodeNameAppendix

        if (variant.default) then
            nodeNameAppendix = ""
        else
            nodeNameAppendix = "_"..variantName
        end

        local nodeVariantName = nodeName..nodeNameAppendix
        nodeVariantNames[variantName] = nodeVariantName

        local variantRegistration = {
            description = definition.description,
            paramtype = definition.paramtype,
            paramtype2 = definition.paramtype2,
            sounds = definition.sounds,
            use_texture_alpha = definition.use_texture_alpha,
            on_punch = definition.on_punch,
            on_construct = definition.on_construct or getOnContructCallback(definition),
            on_rightclick = definition.on_rightclick or getrightClickCallback(nodeName, definition),
            allow_metadata_inventory_put = getAllowInventoryPutCallback(),
            on_metadata_inventory_put = getInventoryPutCallback(),
            on_timer = getTimerCallback(),
            selection_box = definition.selection_box,
            drop = nodeName,
            tiles = variant.tiles,
            drawtype = variant.drawtype,
        }

        if (variant.drawtype == "nodebox") then
            variantRegistration.node_box = variant.node_box
        elseif (variant.drawtype == "mesh") then
            variantRegistration.mesh = variant.mesh
        end

        if (not variant.default) then
            variantRegistration.groups = {not_in_creative_inventory = 1}
        end

        print(dump2(variantRegistration, "REGISTRATION"))

        minetest.register_node(nodeVariantName, variantRegistration)
    end

    EventSystem.registerEvent(
        "fillStateChanged",
        getChangeEventHandler(definition, nodeName, nodeVariantNames)
    )

    minetest.register_on_player_receive_fields(
        getRecieveFieldCallback(nodeName, definition)
    )
end