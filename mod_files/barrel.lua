local Barrel = {}

Barrel.new = function (pos) 
    local self = {}
    -- private property declarations
    local meta, inventory, getSoakingItemStack

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
        minetest.log("action", "set formspec ...")
        minetest.log("action", dump2("FORMSPEC: ", formspec))
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

    self.hasSoakingItems = function ()
        local soakingItemStack = getSoakingItemStack()
        if (soakingItemStack ~= nil) then
            return true
        end

        return false
    end

    self.soak = function ()
        local soakingItemStack, soakingItemStackIndex = getSoakingItemStack()
        local takenSoaking = soakingItemStack:take_item(1)

        local liquidStack = self.getLiquidStack()
        local takenLiquid = liquidStack:take_item(1)

        if (takenSoaking:get_count() > 0 and takenLiquid:get_count() > 0) then
            inventory:set_stack("src", soakingItemStackIndex, soakingItemStack)
            inventory:set_stack("liquid", 1, liquidStack)

            local dst_stack = inventory:get_stack('dst', 1)
            dst_stack:add_item("beer_test:soaked_barley")
            inventory:set_stack('dst', 1, dst_stack)
         
            local bucket_stack = inventory:get_stack('liquid', 1)
            bucket_stack:add_item("bucket:bucket_empty")
            inventory:set_stack('liquid', 1, bucket_stack)
        end
    end


    -- private methods
    setInventory = function (name, size)
        inventory:set_size(name, 1)
    end

    initialize = function ()
        setInventory("liquid", 1)
        setInventory("src", 1)
        setInventory("dst", 1)
        setInventory("buk", 1)
        minetest.log("action", "initialized!")
        self.setFormSpec(Barrel.formspecs.default("Empty Barrel"))
        meta:set_int("initialized", 1)
    end

    getSoakingItemStack = function ()
        local sourceInventory = self.getSourceInventory()
        for i, itemStack in ipairs(sourceInventory) do
            if (itemStack:get_name() == "beer_test:cracked_barley") then
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

Barrel.onConstruct = function (pos)
    minetest.log("action", "creating barrel ...")
    local barrel = Barrel.new(pos)
end

Barrel.onTimer = function (pos, time)
    local barrel = Barrel.new(pos)
    if (barrel.hasSoakingItems()) then
        barrel.soak()
    end
    --[[
        if (barrel.isSealed()) then
            barrel.ferment()
        end
    ]]--
end

Barrel.canDig = function (pos, player, node)
    local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst")
end

minetest.register_node("beer_test:barrel",{
    description = "Empty Barrel",
	drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
    "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    can_dig = Barrel.canDig,
	on_timer =  Barrel.onTimer,
    on_construct = Barrel.onConstruct,
    on_metadata_inventory_move = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_metadata_inventory_put = function(pos)
        -- start timer function, it will sort out whether furnace can burn or not.
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_metadata_inventory_take = function(pos)
        -- check whether the furnace is empty or not.
        minetest.get_node_timer(pos):start(1.0)
    end,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0.5, 0.35}, -- side f
            {-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}, -- bottom
            {-0.5, -0.5, -0.5, -0.35, 0.5, 0.5}, -- side l
            {0.35, -0.5, -0.5, 0.5, 0.5, 0.5},  -- side r
            {-0.5, -0.5, -0.35, 0.5, 0.5, -0.5}, -- frount
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
})