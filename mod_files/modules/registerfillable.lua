local Fillable = beer_test.modules.Components.Fillable()
local Sealable = beer_test.modules.Components.Sealable()
local EventSystem = beer_test.modules.EventSystem()
local PropertyStorage = beer_test.modules.PropertyStorage()
local OpenedFormspecStorage = beer_test.modules.OpenedFormspecStorage()

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
            minetest.show_formspec(playerName,nodeName,definition.formspec(properties))
        end
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

        minetest.register_node(nodeVariantName, {
            description = definition.description,
            drawtype = definition.drawtype,
            paramtype = definition.paramtype,
            paramtype2 = definition.paramtype2,
            groups = definition.groups,
            sounds = definition.sounds,
            use_texture_alpha = definition.use_texture_alpha,
            tiles = variant.tiles,
            on_punch = definition.on_punch,
            on_construct = definition.on_construct or getOnContructCallback(definition),
            on_rightclick = definition.on_rightclick or getrightClickCallback(nodeName, definition),
            node_box = variant.node_box,
            selection_box = definition.selection_box,
        })
    end

    EventSystem.registerEvent(
        "fillStateChanged",
        getChangeEventHandler(definition, nodeName, nodeVariantNames)
    )

    minetest.register_on_player_receive_fields(
        getRecieveFieldCallback(nodeName, definition)
    )
end