local Fillable = beer_test.modules.Components.Fillable()
local Sealable = beer_test.modules.Components.Sealable()
local EventSystem = beer_test.modules.EventSystem()
local Storage = beer_test.modules.Storage()
local OpenedFormspecStorage = beer_test.modules.OpenedFormspecStorage()

local DefinitionStorage = {}
local storageTable = {}

local function buildReceiveFieldsCommands(definition, pos)
    local commands = {
        fill = function ()
			Fillable.fill(pos)
		end,
        drain = function ()
			Sealable.drain(pos)
		end
    }

    if(definition.sealable == true) then
        commands["seal"] = function ()
			Sealable.seal(pos)
		end
        commands["unseal"] = function ()
			Sealable.unseal(pos)
		end
    end

    return commands
end

DefinitionStorage.add = function (nodeName, data)
    storageTable[nodeName] = data
end

DefinitionStorage.findByName = function(nodeName)
    if (storageTable[nodeName] ~= nil) then
        return storageTable[nodeName]
    end

    for _,data in pairs(storageTable) do
        for k,variantName in ipairs(data.variantNames) do
            if (variantName == nodeName) then
                return data
            end
        end
    end

    return nil
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
            on_construct = definition.on_construct or function(pos)
                Fillable.create(pos, definition.maxCapacity or 10)
                if(definition.sealable == true) then
                    Sealable.create(pos)
                end
            end,
            on_rightclick = definition.on_rightclick or function (pos, node, clicker, itemstack, pointed_thing)
                local playerName = clicker:get_player_name()
                local item = clicker:get_wielded_item():get_name()

                if (item and item == "bucket:bucket_water") then
                    if (Fillable.fill(pos, 1)) then
                        clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_water"))
                    end
                    return
                end

                if (item and item == "bucket:bucket_empty") then
                    if (Fillable.drain(pos, 1)) then
                        clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_e,pty"))
                    end
                    return
                end

                OpenedFormspecStorage.add(pos, playerName)
                minetest.show_formspec(
                    playerName,
                    nodeName,
                    definition.formspec(Storage.get(minetest.get_meta(pos)))
                )
            end,
            node_box = variant.node_box,
            selection_box = definition.selection_box,
        })
    end

    EventSystem.registerEvent("fillStateChanged", function(pos, properties)
        definition.onChange(pos, properties, nodeVariantNames)

        local playerNames = OpenedFormspecStorage.getPlayerNamesByPos(pos)
        for _,playerName in ipairs(playerNames) do
            minetest.show_formspec(playerName,nodeName,definition.formspec(properties))
        end
    end)

    DefinitionStorage.add(nodeName, {
        definition = definition,
        variantNames = nodeVariantNames
    })

    minetest.register_on_player_receive_fields(function(player, formName, fields)
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
			definition.on_receive_fields(fields, buildReceiveFieldsCommands(definition, pos))
		end
        
    end)
end