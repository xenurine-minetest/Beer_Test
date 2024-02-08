--------------------------
-- Items                --
--------------------------


minetest.register_craftitem("beer_test:cracked_barley", {
	description = "Cracked Barley",
	inventory_image = "beer_test_cracked_barley.png",
}) 



--------------------------
-- blocks               --
--------------------------
minetest.register_node("beer_test:soaked_barley", { 
	description = "Soaked Barley",
	inventory_image = "beer_test_cracked_barley.png",
	tiles = {"beer_test_barley_floor.png"},
	  paramtype = "light",
	drawtype = "nodebox",
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.4, -0.5, 0.5, -0.5, 0.5}, -- bottom

			},
		},

})
