--
-- Place seeds stuff

	minetest.register_node("beer_test:growing_rope_down", {
	description = "Growing rope",
	drawtype = "nodebox",
	tiles = {"beer_test_rope.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = true,
	walkable = false,
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
			type = "fixed",
			fixed = {
				--{-0.1, -0.1, -0.9, 0.1, 0.1, 0.9}, -- side f
				{-0.05, -0.5, -0.05, 0.05, 0.5, 0.05}, -- floor

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f
		},
	},
	
	})
	



print("Beer_test: plants-stuff.lua             [ok]")