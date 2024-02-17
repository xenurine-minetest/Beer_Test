local Barrel = {}

Barrel.new = function (pos)
    ---@class Barrel
    local self = {}
    -- private property declarations
    local meta, inventory, getSoakingItemStack

    -- private method declarations
    local initialize,setInventory, getLiquidLevel, setLiquidLevel, getLiquidLevelLimit, setLiquidLevelLimit, getLiquidType, setLiquidType, updateFormSpec


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

    self.getLiquidStack = function ()
        return inventory:get_list("liquid")[1]
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

        local liquidStack = self.getLiquidStack()
        local takenLiquidItem = liquidStack:take_item(1)

        if (takenSoakingItem:get_count() > 0 and takenLiquidItem:get_count() > 0) then
            inventory:set_stack("src", soakingItemStackIndex, soakingItemStack)
            inventory:set_stack("liquid", 1, liquidStack)

            local dst_stack = inventory:get_stack('dst', 1)
            dst_stack:add_item(
                beer_test.soakRecipeHandler.getDestinationForSource(takenSoakingItem:get_name())
            )
            inventory:set_stack('dst', 1, dst_stack)
         
            local bucket_stack = inventory:get_stack('liquid', 1)
            bucket_stack:add_item("bucket:bucket_empty")
            inventory:set_stack('liquid', 1, bucket_stack)

            return true
        end

        return false
    end

    ---checks if all inventories are empty
    ---@return boolean
    self.allInventoriesEmpty = function ()
        return inventory:is_empty("src") and inventory:is_empty("dst") and inventory:is_empty("liquid") and inventory:is_empty("buk")
    end

    ---fill barrel with liquid
    ---returns overflow
    ---@param fillAmount
    ---@param fillType string
    ---@return number "overflow"
    self.fillLiquid = function (fillAmount, fillType)
        local liquidType = getLiquidType()
        local liquidLevel = getLiquidLevel()
        local liquidLevelLimit = getLiquidLevelLimit()

        if (liquidType ~= "" and liquidType ~= fillType) then
            minetest.log("action", "type of liquid: " ..liquidType)
            return fillAmount
        end

        if (liquidType == "" and liquidLevel == 0) then
            setLiquidType(fillType)
        end
        
        if (fillAmount + liquidLevel > liquidLevelLimit) then
            setLiquidLevel(liquidLevelLimit)
            return fillAmount + liquidLevel - liquidLevelLimit
        end

        setLiquidLevel(liquidLevel + fillAmount)

        return 0
    end

    ---takes liquid from barrel, returns actually retrieved amount and liquid type
    ---@param amount number
    ---@return number "amount"
    ---@return string|nil "liquid type"
    self.takeLiquid = function (amount)
        local liquidType = getLiquidType()
        local liquidLevel = getLiquidLevel()

        if (liquidLevel < amount) then
            setLiquidLevel(0)
            setLiquidType(nil)
            return liquidLevel, liquidType
        end

        liquidLevel = liquidLevel - amount
        setLiquidLevel(liquidLevel)

        if (liquidLevel == 0) then
            setLiquidType(nil)
        end 
        
        return amount, getLiquidType()
    end

    self.getLiquidStatus = function ()
        return getLiquidLevel(), getLiquidType()
    end

    -- private methods
    setInventory = function (name, size)
        inventory:set_size(name, size)
    end

    initialize = function ()
        setInventory("src", 1)
        setInventory("dst", 1)
        setLiquidLevel(1)
        setLiquidLevelLimit(10)
        setLiquidType("water")
        --self.setFormSpec(Barrel.formspecs.default("Empty Barrel"))
        updateFormSpec()
        meta:set_int("initialized", 1)
    end

    getLiquidLevel = function ()
        return meta:get_int("liquidLevel")
    end

    setLiquidLevel = function (liquidLevel)
        meta:set_int("liquidLevel", liquidLevel)
        updateFormSpec()
    end

    getLiquidLevelLimit = function ()
        return meta:get_int("liquidLevelLimit")
    end

    setLiquidLevelLimit = function (liquidLevelLimit)
        meta:set_int("liquidLevelLimit", liquidLevelLimit)
        updateFormSpec()
    end

    getLiquidType = function()
        return meta:get_string("liquidType")
    end

    setLiquidType = function(liquidType)
        meta:set_string("liquidType", liquidType)
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
        self.setFormSpec(Barrel.formspecs.default("Filled Barrel", getLiquidLevel()/getLiquidLevelLimit()*100))
    end

    construct()
    return self;
end

Barrel.formspecs = {
    default = function (infoText, fillState)
        if (type(fillState) ~= "number") then
            return
        end
        if (fillState < 0 or fillState >100) then
            infoText = "Fill state of barrel MUST be between 0 and 100"
            return table.concat({
                "size[8,8.5]",
                "label[0,0.0;"..infoText.."]",
            }, "")
        end

        local height = 3/100*fillState
        local y = 3 - height +1

        return table.concat({
            "formspec_version[6]",
            "size[11,10]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "label[0.375,0.5;"..infoText.."]",
            "image[2,1;1,3;gui_barrel_bar.png]",
            "image[2,"..y..";1,"..height..";gui_barrel_bar_fg.png]",
            "list[context;src;4,3;1,1;]",
            "image[5.3,3;1,1;gui_barrel_arrow_bg.png]",
            "list[context;dst;6.5,3;1,1;]",
            "button[5,1.2;2,0.5;test;Seal Barrel]",
            "list[current_player;main;0.3,4.5;8,4;]",
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end, 
    soaking = function ()

    end,
    fermenting = function ()

    end
}

return Barrel