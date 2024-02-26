local LiquidContainer = dofile(minetest.get_modpath("beer_test").."/mod_files/abstract_liquid_container.lua")
local Barrel = {}

Barrel.new = function (pos, environment)
    ---@class Barrel :LiquidContainer
    local self = LiquidContainer.new(pos, environment)

    -- private property declarations
    local meta, inventory, getSoakingItemStack

    -- private method declarations
    local initialize, setInventory, updateFormSpec, updateInfo

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)
        inventory = meta:get_inventory()

        if (meta:get_int("initialized") == 0) then
            initialize()
        end
    end

    -- public methods
    self.setFormSpec = function(setFormSpec)
        meta:set_string("formSpec", setFormSpec)
    end

    self.getFormSpec = function ()
        return meta:get_string("formSpec")
    end

    self.getSourceInventory = function ()
        return inventory:get_list("src")
    end

    self.getDestinyInventory = function ()
       return inventory:get_list("dst")
    end

    ---returns if barrel has items in source inventory that got soaking craft recipe
    ---@return boolean
    self.hasSoakingItems = function ()
        local soakingItemStack = getSoakingItemStack()
        if (soakingItemStack ~= nil) then
            return true
        end

        return false
    end

    ---runs soak craft recipes for all soakable items if available
    ---@return boolean
    self.soak = function ()
        local soakingItemStack, soakingItemStackIndex = getSoakingItemStack()
        local takenSoakingItem = soakingItemStack:take_item(1)

        local liquidLevel, liquidType = self.getLiquidStatus()

        if (takenSoakingItem:get_count() > 0 and liquidType == "water" and liquidLevel > 0) then
            inventory:set_stack("src", soakingItemStackIndex, soakingItemStack)
            self.takeLiquid(1)

            local dst_stack = inventory:get_stack('dst', 1)
            dst_stack:add_item(
                beer_test.soakRecipeHandler.getDestinationForSource(takenSoakingItem:get_name())
            )
            inventory:set_stack('dst', 1, dst_stack)

            return true
        end

        return false
    end

    ---checks if all inventories are empty
    ---@return boolean
    self.allInventoriesEmpty = function ()
        return inventory:is_empty("src") and inventory:is_empty("dst")
    end

    -- private methods
    setInventory = function (name, size)
        inventory:set_size(name, size)
    end

    initialize = function ()
        setInventory("src", 1)
        setInventory("dst", 1)
        self.updateDisplay()
        meta:set_int("initialized", 1)
    end

    getSoakingItemStack = function ()
        local sourceInventory = self.getSourceInventory()
        for i, itemStack in ipairs(sourceInventory) do
            if (beer_test.soakRecipeHandler.isSoakSource(itemStack:get_name())) then
                return itemStack, i
            end
        end

        return nil
    end

    updateFormSpec = function()
        self.setFormSpec(Barrel.formspecs.debug(
                {
                            level = self.getLiquidLevel(),
                            limit = self.getLiquidLevelLimit(),
                            type = self.getLiquidType(),
                            temperature = self.getTemperature()
                        },
                "nodemeta:"..pos.x..","..pos.y..","..pos.z
        ))
    end

    updateInfo = function()
        local infoText = ""
        local liquidType = self.getLiquidType()

        if(liquidType == "" and inventory:is_empty("src")) then
            infoText = "Empty Barrel"
        else
            infoText = "Barrel contains "
            local itemName = inventory:get_list("src")[1]:get_name()
            if (itemName ~= "") then
                local itemDescription
                if (minetest.registered_nodes[itemName] ~= nil) then
                    itemDescription = minetest.registered_nodes[itemName]['description']
                elseif (minetest.registered_items[itemName] ~= nil) then
                    itemDescription = minetest.registered_items[itemName]['description']
                elseif (minetest.registered_craftitems[itemName] ~= nil) then
                    itemDescription = minetest.registered_craftitems[itemName]['description']
                else
                    itemDescription = itemName
                end

                infoText = infoText .. itemDescription
            end

            if (liquidType ~= "") then
                if (itemName ~= "") then infoText = infoText .. " and " end
                infoText = infoText .. liquidType .. " " .. self.getLiquidLevel() .. "L / " .. self.getLiquidLevelLimit() .. "L"
            end
        end

        meta:set_string("infotext", infoText)
    end

    self.updateDisplay = function()
        updateFormSpec()
        updateInfo()
    end

    construct()
    return self;
end

Barrel.formspecs = {
    default = function (liquidData, nodePosition)
        local fillStateInPercent = liquidData.level/liquidData.limit*100
        local infoText = ""

        if (liquidData.type == "") then
            infoText = "Empty Barrel"
        else
            infoText = "Barrel filled with " .. liquidData.type .. " "
                    .. liquidData.level .. "L / " .. " " .. liquidData.limit .. "L"
        end

        local function verticalBar (x, y, width, height, percent)
            local backGround = "image["..x..","..y..";"..width..","..height..";gui_barrel_bar.png]"
            local foreground = ""

            if (percent > 0 ) then
                local heightP = height/100*percent
                local yP = height - heightP +y

                foreground = "image["..x..","..yP..";"..width..","..heightP..";gui_barrel_bar_fg.png]"
            end

            return backGround .. foreground
        end

        return table.concat({
            "formspec_version[6]",
            "size[11,10]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "label[0.375,0.5;"..infoText.."]",
            verticalBar(1.55, 1, 1, 3, fillStateInPercent),
            "list["..nodePosition..";src;4.05,3;1,1;]",
            "image[5.3,3;1,1;gui_barrel_arrow_bg.png]",
            "list["..nodePosition..";dst;6.55,3;1,1;]",
            "button[5,1.2;2,0.5;test;Seal Barrel]",
            "list[current_player;main;0.3,4.5;8,4;]",
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end, 
    debug = function (liquidData, nodePosition)
        local fillStateInPercent = liquidData.level/liquidData.limit*100
        local infoText = ""

        if (liquidData.type == "") then
            infoText = "Empty Barrel"
        else
            infoText = "Barrel filled with " .. liquidData.type .. " "
                    .. liquidData.level .. "L / " .. " " .. liquidData.limit .. "L"
        end

        local function verticalBar (x, y, width, height, percent)
            local backGround = "image["..x..","..y..";"..width..","..height..";gui_barrel_bar.png]"
            local foreground = ""

            if (percent > 0 ) then
                local heightP = height/100*percent
                local yP = height - heightP +y

                foreground = "image["..x..","..yP..";"..width..","..heightP..";gui_barrel_bar_fg.png]"
            end

            return backGround .. foreground
        end

        return table.concat({
            "formspec_version[6]",
            "size[12,10]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "label[0.375,0.5;"..infoText.."]",
            verticalBar(1.55, 1, 1, 3, fillStateInPercent),
            "list["..nodePosition..";src;4.05,3;1,1;]",
            "image[5.3,3;1,1;gui_barrel_arrow_bg.png]",
            "list["..nodePosition..";dst;6.55,3;1,1;]",
            "button[5,1.2;2,0.5;test;Seal Barrel]",
            "list[current_player;main;0.3,4.5;8,4;]",
            "label[7.9,0.5;DEBUG:]",
            "label[7.9,1;Temperature: "..liquidData.temperature.."°C]"
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end,
    fermenting = function ()

    end
}

return Barrel