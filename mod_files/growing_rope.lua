-- Growing Rope --

-- The following code is based off of xpanes
local S = minetest.get_translator("beer_test")


local function is_rope(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "rope") > 0
end

local function connects_dir(pos, name, dir)
	local aside = vector.add(pos, minetest.facedir_to_dir(dir))
	if is_rope(aside) then
		return true
	end

	local connects_to = minetest.registered_nodes[name].connects_to
	if not connects_to then
		return false
	end
	local list = minetest.find_nodes_in_area(aside, aside, connects_to)

	if #list > 0 then
		return true
	end

	return false
end

local function swap(pos, node, name, param2)
	if node.name == name and node.param2 == param2 then
		return
	end

	minetest.swap_node(pos, {name = name, param2 = param2})
end
-- This will check the node to see if it sould connect to a diffent node. 


local function update_rope(pos)
	if not is_rope(pos) then
		return
	end
	local node = minetest.get_node(pos)
	local name = node.name

	local any = node.param2
	local c = {}
	local count = 0
	for dir = 0, 5 do
		c[dir] = connects_dir(pos, name, dir)
		if c[dir] then
			any = dir
			count = count + 1
		end
	end

	swap(pos, node, name, 0)


end

minetest.register_on_placenode(function(pos, node)
	if minetest.get_item_group(node, "rope") then
		update_rope(pos)
	end
	for i = 0, 5 do
		local dir = minetest.facedir_to_dir(i)
		update_rope(vector.add(pos, dir))
	end
end)

minetest.register_on_dignode(function(pos)
	for i = 0, 5 do
		local dir = minetest.facedir_to_dir(i)
		update_rope(vector.add(pos, dir))
	end
end)

beer_test = {}
function beer_test.register_rope(name, def )
	-- possibly remove this since they will be only one type of flat rope. 


	local groups = table.copy(def.groups)
	groups.rope = 1
	minetest.register_node(":beer_test:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		tiles = {def.textures[3], def.textures[3], def.textures[1]},
		groups = groups,
		drop = def.drop,
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha or false,
		node_box = {
			type = "connected",
			fixed = def.fixed_box,
			connect_front = {{-0.05, -0.05, -0.05, 0.05, 0.05, -0.5}},
			connect_left = {{-0.05, -0.05, -0.05, -0.5, 0.05, 0.05}},
			connect_back = {{-0.05, -0.05, 0.5, 0.05, 0.05, 0.05}},
			connect_right = {{0.5, -0.05, -0.05, 0.05, 0.05, 0.05}},
			connect_top = { {-0.05, -0.05, -0.05, 0.05, 0.5, 0.05},{-0.1, -0.1, -0.1, 0.1, 0.1, 0.1}},
			connect_bottom = {{-0.05, -0.5, -0.05, 0.05, 0.05, 0.05},{-0.1, -0.1, -0.1, 0.1, 0.1, 0.1}},
		},
		selection_box = {
			type = "connected",
			fixed = def.fixed_selection,
			connect_front = {{-0.1, -0.1, -0.1, 0.1, 0.1, -0.5}},
			connect_left = {{-0.1, -0.1, -0.1, -0.5, 0.1, 0.1}},
			connect_back = {{-0.1, -0.1, 0.5, 0.1, 0.1, 0.1}},
			connect_right = {{0.5, -0.1, -0.1, 0.1, 0.1, 0.1}},
			connect_top = { {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1}},
			connect_bottom = {{-0.1, -0.5, -0.1, 0.1, 0.1, 0.1}},

		},
		connects_to = {"group:rope", "group:stone", "group:glass", "group:wood", "group:tree", "beer_test:growing_rope_down"},
	})

		minetest.register_craft({
		output = "beer_test:" .. name .. " 2",
		recipe = def.recipe
	})

end

beer_test.register_rope("growing_rope", {
	description = S("Growing Rope"),
	textures = {"beer_test_rope.png","beer_test_rope.png","beer_test_rope.png"},
	inventory_image = "beer_test_rope_item.png",
	wield_image = "beer_test_rope_item.png",
	sounds = default.node_sound_wood_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	fixed_box = {{-0.05, -0.05, -0.05, 0.05, 0.05, 0.05}},
	fixed_selection = {{-0.1, -0.1, -0.1, 0.1, 0.1, 0.1}},
	recipe = {
		{"farming:string","farming:cotton", "farming:string"},
		{"farming:cotton","farming:string", "farming:cotton"}
	}
	
})

beer_test.register_rope("fence_rope", {
	description = S("Fence Rope"),
	textures = {"default_fence_wood.png^beer_test_rope-overlay.png","default_fence_wood.png^beer_test_rope-underlay.png","default_fence_wood.png^beer_test_rope-underlay.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	fixed_box = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},{-0.185, -0.3, -0.185, 0.185, 0.3, 0.185}},
	fixed_selection = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}},
	recipe = {
		{"beer_test:growing_rope" , "default:fence"},
	}
})

beer_test.register_rope("pine_fence_rope", {
	description = S("Pine Fence Rope"),
	textures = {"default_fence_pine_wood.png^beer_test_rope-overlay.png","default_fence_pine_wood.png^beer_test_rope-underlay.png","default_fence_pine_wood.png^beer_test_rope-underlay.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	fixed_box = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},{-0.185, -0.3, -0.185, 0.185, 0.3, 0.185}},
	fixed_selection = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}},
	recipe = {
		{"beer_test:growing_rope" , "default:fence_pine_wood"},
	}
})

beer_test.register_rope("junglewood_fence_rope", {
	description = S("Junglewood Fence Rope"),
	textures = {"default_fence_junglewood.png^beer_test_rope-overlay.png","default_fence_junglewood.png^beer_test_rope-underlay.png","default_fence_junglewood.png^beer_test_rope-underlay.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	fixed_box = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},{-0.185, -0.3, -0.185, 0.185, 0.3, 0.185}},
	fixed_selection = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}},
	recipe = {
		{"beer_test:growing_rope" , "default:fence_junglewood"},
	}
})

beer_test.register_rope("aspen_fence_rope", {
	description = S("Aspen Fence Rope"),
	textures = {"default_fence_aspen_wood.png^beer_test_rope-overlay.png","default_fence_aspen_wood.png^beer_test_rope-underlay.png","default_fence_aspen_wood.png^beer_test_rope-underlay.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	fixed_box = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},{-0.185, -0.3, -0.185, 0.185, 0.3, 0.185}},
	fixed_selection = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}},
	recipe = {
		{"beer_test:growing_rope" , "default:fence_aspen_wood"},
	}
})

beer_test.register_rope("acacia_fence_rope", {
	description = S("Acacia Fence Rope"),
	textures = {"default_fence_acacia_wood.png^beer_test_rope-overlay.png","default_fence_acacia_wood.png^beer_test_rope-underlay.png","default_fence_acacia_wood.png^beer_test_rope-underlay.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	fixed_box = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},{-0.185, -0.3, -0.185, 0.185, 0.3, 0.185}},
	fixed_selection = {{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}},
	recipe = {
		{"beer_test:growing_rope" , "default:fence_acacia_wood"},
	}
})






minetest.register_lbm({
	name = "beer_test:gen2",
	nodenames = {"group:rope"},
	action = function(pos, node)
		update_rope(pos)
		for i = 0, 3 do
			local dir = minetest.facedir_to_dir(i)
			update_rope(vector.add(pos, dir))
		end
	end
})

