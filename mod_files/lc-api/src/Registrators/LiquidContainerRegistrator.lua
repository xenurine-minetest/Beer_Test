local EventSystem = lc_api.modules.EventSystem()
local PropertyStorage = lc_api.modules.PropertyStorage()
local OpenedFormspecStorage = lc_api.modules.View.OpenedFormspecStorage()
local ComponentRegistrator = lc_api.Registrations.Components()

local function setNodeComponentPropertiesDefaults (nodeDefinition)
    ComponentRegistrator.iterators.componentsPropertiesIterator(function (componentDefinition, registrationProperty) 
        if (nodeDefinition[registrationProperty.name] ~= nil) then
            nodeDefinition[registrationProperty.name] = nodeDefinition[registrationProperty.name]
        else
            nodeDefinition[registrationProperty.name] = registrationProperty.default  
        end
    end)

    return nodeDefinition
end

local function buildReceiveFieldsCommands(nodeDefinition, properties)
    local commands = {}

    ComponentRegistrator.iterators.doIfNodeHasComponent(nodeDefinition, function(componentDefinition)
        for commandName, commandCallback in pairs(componentDefinition.receiveCommands) do
            commands[commandName] = function (...) 
                local args = {...}
                return commandCallback(properties, unpack(args))
            end
        end
    end)

    return commands
end

local getOnConstructCallback = function(nodeDefinition)
    return function (pos) 
        PropertyStorage.write("dummyPlayer", pos, function (properties)
            ComponentRegistrator.iterators.doIfNodeHasComponent(nodeDefinition, function(componentDefinition)
                if(componentDefinition.usesStorage) then
                    componentDefinition.onConstruct(nodeDefinition, properties)
                end
            end)

            if(type(nodeDefinition.inventories) == "table") then
                local meta = minetest.get_meta(pos)
		        local inv = meta:get_inventory()

                for name, size in pairs(nodeDefinition.inventories) do
                    if(type(name) ~= "string" or type(size) ~= "number") then error() end
                    inv:set_size(name, size)
                end
            end
        end)
    end
end

local function getRightClickCallback(nodeName, nodeDefinition)
    return function(pos, node, clicker, itemstack, pointed_thing) 
        local playerName = clicker:get_player_name()

        local rightClickActionDone = false

        PropertyStorage.write(playerName, pos, function (properties)
            ComponentRegistrator.iterators.doIfNodeHasComponent(nodeDefinition, function (componentDefinition)
                if (type(componentDefinition.onRightClick) == "function" and componentDefinition.usesStorage) then
                    rightClickActionDone = componentDefinition.onRightClick(pos, clicker, properties)
                    if (rightClickActionDone) then
                        EventSystem.triggerEvent('fillStateChanged', pos, properties)
                    end
                end
            end)
        end)

        if (rightClickActionDone) then
            return
        end

        OpenedFormspecStorage.add(pos, playerName)
        
        minetest.show_formspec(
            playerName,
            nodeName,
            nodeDefinition.formspec(
                pos,
                PropertyStorage.readonly(minetest.get_meta(pos))
            )
        )
    end
end

local function getRecieveFieldCallback(nodeName, definition)
    return function(player, formName, fields)
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

local getAllowInventoryPutCallback = function (nodeDefinition)
    return function (pos, listname, index, stack, player)
        local result = 0
        ComponentRegistrator.iterators.doIfNodeHasComponent(nodeDefinition, function(componentDefinition)
            for inventoryName, inventoryConfig in pairs(componentDefinition.neededInventories) do
                if(type(inventoryConfig.allowPut) == "function" and inventoryName == listname) then
                    result = result + inventoryConfig.allowPut(pos, index, stack, player)
                end
            end
        end)

        return result
    end
end

local getInventoryPutCallback = function (nodeDefinition)
    return function (pos, listname, index, stack, player) 
        ComponentRegistrator.iterators.doIfNodeHasComponent(nodeDefinition, function(componentDefinition)
            for inventoryName, inventoryConfig in pairs(componentDefinition.neededInventories) do
                if(type(inventoryConfig.put) == "function" and inventoryName == listname) then
                    inventoryConfig.put(pos, index, stack, player)
                end
            end
        end)
    end
end

local getTimerCallback = function (nodeDefinition)
    return function(pos, elapsed)
        ComponentRegistrator.iterators.doIfNodeHasComponent(nodeDefinition, function(componentDefinition)
            if(type(componentDefinition.timer) == "function") then
                componentDefinition.timer(pos, elapsed)
            end
        end)
    end
end


local function mergeToTable(tableFrom, tableTo)
    for propertyName, value in pairs (tableFrom) do
        tableTo[propertyName] = value
    end

    return tableTo
end

---@alias FillableRegistration fun(nodeName: string, definition: FillableDefinition): nil
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

        definition = setNodeComponentPropertiesDefaults(definition)

        local variantRegistration = {
            description = definition.description,
            paramtype = definition.paramtype,
            paramtype2 = definition.paramtype2,
            sounds = definition.sounds,
            use_texture_alpha = definition.use_texture_alpha,
            on_punch = definition.on_punch,
            on_construct = definition.on_construct or getOnConstructCallback(definition),
            on_rightclick = definition.on_rightclick or getRightClickCallback(nodeName, definition),
            allow_metadata_inventory_put = getAllowInventoryPutCallback(definition),
            on_metadata_inventory_put = getInventoryPutCallback(definition),
            on_timer = getTimerCallback(definition),
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
            variantRegistration.groups = mergeToTable({not_in_creative_inventory = 1}, definition.groups)
        else
            variantRegistration.groups = definition.groups
        end

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