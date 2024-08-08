--
-- Place seeds stuff
--


minetest.register_node("beer_test:hops", {
	description = "Hops",
	walkable = false,
	paramtype = "light",
	drawtype = "plantlike",
	tiles = {"beer_test_hops.png"},
	inventory_image = "beer_test_hops.png",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("beer_test:hops_dried_1", {
	description = "Drying Hops",
	walkable = false,
	paramtype = "light",
	drawtype = "plantlike",
	tiles = {"beer_test_hops_dryed_1.png"},
	inventory_image = "beer_test_hops_dryed_1.png",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("beer_test:hops_dried_2", {
	description = "Dryed Hops",
	walkable = false,
	paramtype = "light",
	drawtype = "plantlike",
	tiles = {"beer_test_hops_dryed_2.png"},
	inventory_image = "beer_test_hops_dryed_2.png",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})



 -- drying hops -- 
 
minetest.register_abm({
	nodenames = {"beer_test:hops", "beer_test:hops_dried_1"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:hops_dried_2"})
		end
		-- check if there is water nearby
		if minetest.find_node_near(pos, 5, {"air"}) then
			-- if it is dry soil turn it into wet soil
			if node.name == "beer_test:hops" then
				minetest.set_node(pos, {name="beer_test:hops_dried_1"})
			end
		end
	end,
})

farming.register_plant("beer_test:hops", {
description = "Hops Seed",
inventory_image = "beer_test_hops_seed.png",
steps = 9,
minlight = 13,
maxlight = LIGHT_MAX,
fertility = {"grassland"}
})




minetest.override_item("beer_test:hops_9", {
drawtype = "nodebox",
	tiles = {"beer_test_hops_8.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "beer_test:growing_rope_down",
	is_ground_content = true,
	walkable = false,
	buildable_to = true,
	groups = {cracky=2,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	use_texture_alpha = "blend",
	node_box = {
			type = "fixed",
			fixed = {
				{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, 0.2, 0.3, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, -0.2, 0.3, 0.5, -0.2}, -- side f 
				{-0.2, -0.5, 0.3, -0.2, 0.5, -0.3}, -- side f 
				{0.2, -0.5, 0.3, 0.2, 0.5, -0.3}, -- side f 
				{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}, -- side f
		},
	},

})

minetest.register_node("beer_test:hops_9a", {
drawtype = "nodebox",
	tiles = {"beer_test_hops_9.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "beer_test:growing_rope_down",
	is_ground_content = true,
	walkable = false,
	buildable_to = true,
	groups = {cracky=2,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	use_texture_alpha = "blend",
	node_box = {
			type = "fixed",
			fixed = {
				{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, 0.2, 0.3, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, -0.2, 0.3, 0.5, -0.2}, -- side f 
				{-0.2, -0.5, 0.3, -0.2, 0.5, -0.3}, -- side f 
				{0.2, -0.5, 0.3, 0.2, 0.5, -0.3}, -- side f 
				{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}, -- side f
		},
	},
	on_punch = function(pos, node, puncher)
			local tool = puncher:get_wielded_item():get_name()
			if tool and tool == "" then
				node.name = "beer_test:hops_9"
				minetest.env:set_node(pos, node)
				puncher:get_inventory():add_item("main", ItemStack("beer_test:hops"))
			end
		end
})

-- growing crops --


minetest.register_abm({
	nodenames = {"beer_test:hops_9", "beer_test:hops_9a"},
	interval = 30,
	chance = 50,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable then
			minetest.set_node(pos, {name="beer_test:hops_9"})
		end
		-- check if there is air nearby
		if minetest.find_node_near(pos, 5, {"air"}) then
			if node.name == "beer_test:hops_9" then
				minetest.set_node(pos, {name="beer_test:hops_9a"})
			end
		end
	end,
})

-- grow up up and away!--

minetest.register_abm({
	nodenames = {"beer_test:hops_9a"},
	neighbors = {"farming:soil_wet"},
	interval = 50,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y-1
		local name = minetest.get_node(pos).name
		if name == "farming:soil_wet" or name == "default:dirt_with_grass" or name == "farming:soil" or name == "default:dirt" then
			pos.y = pos.y+1
			local height = 0
			while minetest.get_node(pos).name == "beer_test:hops_9a" and height < 4 do
				height = height+1
				pos.y = pos.y+1
			end
			if height < 4 then
				if minetest.get_node(pos).name == "beer_test:growing_rope_down" then
					minetest.set_node(pos, {name="beer_test:hops_9"})
				end
			end
		end
	end,
})


-- crafts for hops --

minetest.register_craft({
	output = "beer_test:seed_hops",
	recipe = {
		{"beer_test:hops"},

	}
})

-- oats --

farming.register_plant("beer_test:oats", {
description = "Oat seed",
inventory_image = "beer_test_oats.png",
steps = 8,
minlight = 13,
maxlight = LIGHT_MAX,
fertility = {"grassland"}
})

-----------------
-- wild plants --
-----------------

-- wild oats --

minetest.register_node("beer_test:wild_oats", {
	description = "Wild Oats",
	paramtype = "light",
	walkable = false,
	drop = "beer_test:seed_oats",
	drawtype = "plantlike",
	paramtype2 = "facedir",
	tiles = {"beer_test_oats_8.png"},
	groups = {chopspy=2, oddly_breakable_by_hand=3, flammable=2, plant=1},
	sounds = default.node_sound_wood_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}, -- side f
		},
	},
})

-- wild hops --

minetest.register_node("beer_test:wild_hops", {
drawtype = "nodebox",
description = "Wild hops",
	tiles = {"beer_test_hops_8.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "beer_test:seed_hops",
	is_ground_content = true,
	walkable = false,
	buildable_to = true,
	groups = {chopspy=2, oddly_breakable_by_hand=3, flammable=2, plant=1},
	--light_source = LIGHT_MAX-1,
	sounds = default.node_sound_wood_defaults(),
	use_texture_alpha = "blend",
	node_box = {
			type = "fixed",
			fixed = {
				{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, 0.2, 0.3, 0.5, 0.2}, -- side f 
				{-0.3, -0.5, -0.2, 0.3, 0.5, -0.2}, -- side f 
				{-0.2, -0.5, 0.3, -0.2, 0.5, -0.3}, -- side f 
				{0.2, -0.5, 0.3, 0.2, 0.5, -0.3}, -- side f 
				{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}, -- side f

			},
		},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}, -- side f
		},
	},

})




-- crop --


-- 


 print("Beer_test: plants.lua                   [ok]")
