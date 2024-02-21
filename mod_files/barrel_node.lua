local modname = minetest.get_current_modname()
local Barrel = dofile(minetest.get_modpath(modname) .. "/mod_files/barrel.lua")
---@type RefreshingFormSpecs
local formSpec = dofile(minetest.get_modpath(modname) .. "/mod_files/formspec.lua")

local function onConstruct (pos)
    Barrel.new(pos)
end

local function onTimer (pos, time)
    ---@type Barrel
    local barrel = Barrel.new(pos)
    local soaked = false

    if (barrel.hasSoakingItems()) then
        soaked = barrel.soak()
    end
    --[[
        if (barrel.isSealed()) then
            barrel.ferment()
        end
    ]]--
    if (soaked) then
        minetest.get_node_timer(pos):start(1.0)
    end
    barrel.updateDisplay()
end

local function canDig (pos, player, node)
    ---@type Barrel
    local barrel = Barrel.new(pos)
	return barrel.allInventoriesEmpty()
end

local function onRightClick(pos, node, clicker, itemStack, pointed_thing)
    ---@type Barrel
    local barrel = Barrel.new(pos, clicker)

    if (clicker:is_player()) then
        if (itemStack:get_name() == "bucket:bucket_water") then
            barrel.fillLiquid(1, 'water')
            minetest.get_node_timer(pos):start(1.0)
        elseif (itemStack:get_name() == "bucket:bucket_empty") then
            barrel.takeLiquid(1)
        else
            formSpec.open(barrel,"beer_test:barrel", clicker:get_player_name())
        end
    end
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