local Barrel = {}

Barrel.new = function (pos) 
    local self = {}
    -- private property declarations
    local meta, inventory, getSoakingItemStack, liquidLevel, liquidLevelLimit, liquidType

    -- private method declarations
    local initialize,setInventory


    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)
        inventory = meta:get_inventory()

        if (meta:get_int("initialized") == 0) then
            initialize()
        end
    end


    -- public methods
    self.setFormSpec = function(formspec)
        meta:set_string("formspec", formspec)
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
        if (liquidType ~= nil and liquidType ~= fillType) then
            return fillAmount
        end

        if (liquidType == nil and liquidLevel == 0) then
            liquidType = fillType
        end
        
        if (fillAmount + liquidLevel > liquidLevelLimit) then
            local oldLiquidLevel = liquidLevel
            liquidLevel = liquidLevelLimit
            return fillAmount + oldLiquidLevel - liquidLevelLimit
        end

        liquidLevel = liquidLevel + fillAmount

        return 0
    end

    ---takes liquid from barrel, returns actually retrieved amount and liquid type
    ---@param amount number
    ---@return number "amount"
    ---@return string|nil "liquid type"
    self.takeLiquid = function (amount)
        local oldLiquidType = liquidType

        if (liquidLevel < amount) then 
            local oldLiquidLevel = liquidLevel
            liquidLevel = 0
            liquidType = nil
            return oldLiquidLevel, oldLiquidType
        end

        liquidLevel = liquidLevel - amount

        if (liquidLevel == 0) then
            liquidType = nil
        end 
        
        return amount, oldLiquidType
    end

    self.getLiquidStatus = function ()
        return liquidLevel
    end


    -- private methods
    setInventory = function (name, size)
        inventory:set_size(name, size)
    end

    initialize = function ()
        setInventory("liquid", 1)
        setInventory("src", 1)
        setInventory("dst", 1)
        setInventory("buk", 1)
        liquidLevel = 0
        liquidLevelLimit = 500
        liquidType = nil
        self.setFormSpec(Barrel.formspecs.default("Empty Barrel"))
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

    construct()
    return self;
end

Barrel.formspecs = {
    default = function (infotext)
        return table.concat({
            "size[8,8.5]",
            "label[0,0.0;"..infotext.."]",
            "image[2,1;1,3.35;gui_barrel_bar.png]",
            "list[context;liquid;3,1;1,1;]",
            "list[context;src;3,3;1,1;]",
            "image[4,3;1,1;gui_barrel_arrow_bg.png]",
            "list[context;dst;5,3;1,1;]",
            "list[context;buk;6,3;1,1;]",
            "button[5,1.2;2,0.5;test;Seal Barrel]",
            "list[current_player;main;0,4.5;8,4;]",
            default.get_hotbar_bg(0, 4.5)
        }, "")
    end, 
    soaking = function ()

    end,
    fermenting = function ()

    end
}

return Barrel