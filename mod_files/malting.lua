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


minetest.register_node("beer_test:stone_block_barley", {
	description = "Stone Block with Barley",
	tiles = {"beer_test_barley_floor.png", "default_stone_block.png", "default_stone_block.png^beer_test_barley_side.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),

	on_rightclick = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "" then
			node.name = "default:stone_block"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():add_item("main", ItemStack("beer_test:cracked_barley"))
		end
	end
})


minetest.override_item("default:stone_block", {
	description = ("Stone Block"),
	tiles = {"default_stone_block.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),

	on_rightclick = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:cracked_barley" then
			node.name = "beer_test:stone_block_barley"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:cracked_barley"))
		end
	end
})
