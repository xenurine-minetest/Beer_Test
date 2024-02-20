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
	inventory_image = "beer_test_soaked_barley.png",
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

minetest.register_node("beer_test:sprouting_barley", { 
	description = "Sprouting Barley",
	inventory_image = "beer_test_sprouting_barley.png",
	tiles = {"beer_test_barley_sprouting_floor.png"},
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


minetest.register_abm({
	nodenames = {"beer_test:soaked_barley"},
	interval = 100,
	chance = 50,
	action = function(pos, node)
		if minetest.find_node_near(pos, 5, {"air"}) then
			if node.name == "beer_test:soaked_barley" then
				minetest.set_node(pos, {name="beer_test:sprouting_barley"})
			end
		end
	end

})


---------------------------------------------------------------
-- malt grain--
---------------------------------------------------------------
minetest.register_craftitem("beer_test:malt_light_malt", {
	description = "Light Malt",
	inventory_image = "beer_test_malt.png",
})

minetest.register_craftitem("beer_test:malt_brown_malt", {
	description = "Brown Malt",
	inventory_image = "beer_test_brown_malt.png",
})

minetest.register_craftitem("beer_test:malt_black_malt", {
	description = "Black Malt",
	inventory_image = "beer_test_black_malt.png",
})