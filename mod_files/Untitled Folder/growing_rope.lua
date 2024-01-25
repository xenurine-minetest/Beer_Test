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
	if name:sub(-5) == "_flat" then
		name = name:sub(1, -6)
	end

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

	--[[if count == 0 then
		swap(pos, node, name, 0)
		--swap(pos, node, name .. "_flat", any)
	--elseif count == 1 then
	--	swap(pos, node, name .. "_flat", (any + 1) % 4)
	--elseif count == 2 then
	--	if (c[0] and c[2]) or (c[1] and c[3]) then
	--		swap(pos, node, name .. "_flat", (any + 1) % 4)
	--	else
	--		swap(pos, node, name, 0)
		--end
	else
		swap(pos, node, name, 0)
	end
	]]--
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
	for i = 1, 15 do
		minetest.register_alias("beer_test:" .. name .. "_" .. i, "beer_test:" .. name .. "_flat")
	end

	local ropetypes = table.copy(def.groups)
	ropetypes.rope = 1
	minetest.register_node("beer_test:" .. name .. "_flat", {
		description = def.description,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		paramtype2 = "facedir",
		tiles = {
				def.textures[3],
				def.textures[3],
				def.textures[3],
				def.textures[3],
				def.textures[1],
				def.textures[1]
		},
		groups = ropetypes,
		drop = "beer_test:" .. name .. "_flat",
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha or false,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.05, -0.05, 0.5, 0.05, 0.05}, -- side f
				--{-0.1, -0.5, -0.1, 0.1, 0.7, 0.1}, -- floor

			},
		},
		selection_box = {
			type = "fixed",
			fixed = {{-0.5, -0.1, -0.1, 0.5, 0.1, 0.1}},
		},
		connect_sides = { "left", "right", "top", "bottom" },
	})

	local groups = table.copy(def.groups)
	groups.rope = 1
	groups.not_in_creative_inventory = 1
	minetest.register_node(":beer_test:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		description = def.description,
		tiles = {def.textures[3], def.textures[3], def.textures[1]},
		groups = groups,
		drop = "beer_test:" .. name .. "_flat",
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha or false,
		node_box = {
			type = "connected",
			fixed = {{-0.05, -0.05, -0.05, 0.05, 0.05, 0.05}},
			connect_front = {{-0.05, -0.05, -0.05, 0.05, 0.05, -0.5}},
			connect_left = {{-0.05, -0.05, -0.05, -0.5, 0.05, 0.05}},
			connect_back = {{-0.05, -0.05, 0.5, 0.05, 0.05, 0.05}},
			connect_right = {{0.5, -0.05, -0.05, 0.05, 0.05, 0.05}},
			connect_top = { {-0.05, -0.05, -0.05, 0.05, 0.5, 0.05},{-0.1, -0.1, -0.1, 0.1, 0.1, 0.1}},
			connect_bottom = {{-0.05, -0.5, -0.05, 0.05, 0.05, 0.05},{-0.1, -0.1, -0.1, 0.1, 0.1, 0.1}},
		},
		selection_box = {
			type = "connected",
			fixed = {{-0.1, -0.1, -0.1, 0.1, 0.1, 0.1}},
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
		output = "beer_test:" .. name .. "_flat 16",
		recipe = def.recipe
	})

end

beer_test.register_rope("growing_rope", {
	description = S("Growing Rope"),
	textures = {"beer_test_rope.png","beer_test_rope.png","beer_test_rope.png"},
	inventory_image = "beer_test_rope.png",
	wield_image = "beer_test_rope.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "default:glass", "default:glass"}
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

