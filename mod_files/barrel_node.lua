local modname = minetest.get_current_modname()
local Barrel = dofile(minetest.get_modpath(modname) .. "/mod_files/barrel.lua")

function onConstruct (pos)
    minetest.log("action", "creating barrel ...")
    local barrel = Barrel.new(pos)
end

function onTimer (pos, time)
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

function canDig (pos, player, node)
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
    can_dig = canDig,
	on_timer = onTimer,
    on_construct = onConstruct,
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