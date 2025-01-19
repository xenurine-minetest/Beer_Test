print(dump2(beer_test))
local BarrelController = beer_test.api.classes.Nodes.Barrel.Controller()

-----------------
-- beer barrle --
-----------------

minetest.register_node("beer_test:barrel", {
    description = "Barrel",
    drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side.png",
    "beer_test_barrel_side.png", "beer_test_barrel_side.png", "beer_test_barrel_side.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    use_texture_alpha = "blend",
	on_rightclick = BarrelController.onRightClick,
    on_construct = BarrelController.onConstruct,
    --on_construct = function(pos) print(dump2(pos))end,
    node_box = {
        type = "fixed",
        fixed = {
			{-0.375, -0.5, 0.3125, 0.4375, 0.5, 0.4375}, -- NodeBox1
			{-0.4375, -0.5, -0.375, -0.3125, 0.5, 0.4375}, -- NodeBox2
			{-0.4375, -0.5, -0.4375, 0.375, 0.5, -0.3125}, -- NodeBox3
			{0.3125, -0.5, -0.4375, 0.4375, 0.5, 0.375}, -- NodeBox4
			{-0.375, -0.4375, -0.375, 0.375, 0.4375, 0.375}, -- NodeBox5
		}
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.4375, -0.5, -0.4375, 0.4375, 0.5, 0.4375}, -- NodeBox1
        },
    },
})

minetest.register_node("beer_test:brewing_barrel", {
	description = "Brewing Barrel",
	drawtype = "nodebox",
    tiles = {"default_wood.png^beer_test_barrel_side.png", "default_wood.png^beer_test_barrel_side.png", "default_wood.png^beer_test_brewing_barrel_side.png",
    "default_wood.png^beer_test_brewing_barrel_side.png", "default_wood.png^beer_test_brewing_barrel_front.png", "default_wood.png^beer_test_brewing_barrel_front.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    use_texture_alpha = "blend",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.375, -0.5, 0.4375, -0.25, 0.5}, -- NodeBox2
			{-0.4375, -0.375, -0.5, -0.3125, 0.4375, 0.5}, -- NodeBox3
			{-0.4375, 0.375, -0.5, 0.375, 0.5, 0.5}, -- NodeBox4
			{0.3125, -0.3125, -0.5, 0.4375, 0.5, 0.5}, -- NodeBox5
			{-0.375, -0.3125, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox6
			{-0.5, -0.5, 0.3125, 0.5, -0.375, 0.4375}, -- NodeBox8
			{-0.5, -0.5, -0.4375, 0.5, -0.375, -0.3125}, -- NodeBox9
		}
	},
	selection_box = {
        type = "fixed",
        fixed = {
           -- {-0.437, -0.5, -0.5, 0.4375, 0.5, 0.5}, -- NodeBox1
            {-0.437, -0.375, -0.5, 0.4375, 0.5, 0.5}, -- NodeBox1
            {-0.5, -0.5, 0.3125, 0.5, -0.375, 0.4375}, -- NodeBox8
			{-0.5, -0.5, -0.4375, 0.5, -0.375, -0.3125}, -- NodeBox9
        },
    },
	on_rightclick = BarrelController.onRightClick,
    on_construct = BarrelController.onConstruct,
})


print("Beer_test: barrel.lua            [ok]")