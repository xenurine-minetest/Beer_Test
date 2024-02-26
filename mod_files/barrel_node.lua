local modname = minetest.get_current_modname()
local Barrel = dofile(minetest.get_modpath(modname) .. "/mod_files/barrel.lua")
local Environment = dofile(minetest.get_modpath(modname) .. "/mod_files/environment.lua")

---@type RefreshingFormSpecs
local formSpec = dofile(minetest.get_modpath(modname) .. "/mod_files/formspec.lua")

local function onConstruct (pos)
    Barrel.new(pos, Environment.new(pos))
end

local function onTimer (pos, time)
    ---@type Barrel
    local barrel = Barrel.new(pos, Environment.new(pos))

    local heated = barrel.heat()
    local soaked = false

    if (barrel.hasSoakingItems()) then
        soaked = barrel.soak()
    end
    barrel.updateDisplay()

    if (soaked or heated) then
        return true
    end
end

local function canDig (pos, player, node)
    ---@type Barrel
    local barrel = Barrel.new(pos, Environment.new(pos))
	return barrel.allInventoriesEmpty() and barrel.getLiquidLevel() == 0
end

local function onRightClick(pos, node, clicker, itemStack, pointed_thing)
    if (not clicker:is_player()) then
        return
    end

    ---@type Barrel
    local barrel = Barrel.new(pos, Environment.new(pos))

    if (itemStack:get_name() == "bucket:bucket_water") then
        local iMeta = itemStack:get_meta()
        local temperature = iMeta:get("temperature")
        if (temperature == nil) then
            temperature = 20
        end
        itemStack:take_item(1)

        local overflow = barrel.fillLiquid(1, 'water', temperature)

        if (overflow == 0) then
            local playerInventory = minetest.get_inventory({ type="player", name=clicker:get_player_name() })
            playerInventory:add_item("main", ItemStack("bucket:bucket_empty"))
        end
    elseif (itemStack:get_name() == "bucket:bucket_empty") then
        local amount, temperature = barrel.takeLiquid(1)

        if (amount > 0) then
            local playerInventory = minetest.get_inventory(
                    { type="player", name=clicker:get_player_name() }
            )

            itemStack:take_item(1)
            local waterBucketStack = ItemStack("bucket:bucket_water")
            local iMeta = waterBucketStack:get_meta()
            iMeta:set_float("temperature", temperature)
            local leftover = playerInventory:add_item("main", waterBucketStack)
        end
    else
        formSpec.open(barrel,"beer_test:barrel", clicker:get_player_name())
    end

    minetest.get_node_timer(pos):start(1.0)
end

minetest.register_node("beer_test:barrel",{
    description = "Empty Barrel",
	drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
    "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2, explody=4, flammable=4},
    sounds = default.node_sound_wood_defaults(),
    can_dig = canDig,
	on_timer = onTimer,
    on_construct = onConstruct,
    on_rightclick = onRightClick,
    on_metadata_inventory_move = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_metadata_inventory_put = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,
    on_metadata_inventory_take = function(pos)
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