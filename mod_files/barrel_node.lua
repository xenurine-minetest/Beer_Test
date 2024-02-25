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
        barrel.fillLiquid(1, 'water', 20)
    elseif (itemStack:get_name() == "bucket:bucket_empty") then
        barrel.takeLiquid(1)
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
    groups = {cracky=2},
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