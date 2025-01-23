local FillableRegistration = beer_test.register.Fillable()

FillableRegistration("beer_test:barrel", {
	description = "Barrel",
	paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    use_texture_alpha = "blend",
	sealable = true,
	variants = {
		first = {
			default = true,
			tiles = {
				"beer_test_barrel_top.png",
				"beer_test_barrel_top.png",
				"beer_test_barrel_side.png",
				"beer_test_barrel_side.png",
				"beer_test_barrel_side.png",
				"beer_test_barrel_side.png"
			},
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.375, -0.5, 0.3125, 0.4375, 0.5, 0.4375}, -- NodeBox1
					{-0.4375, -0.5, -0.375, -0.3125, 0.5, 0.4375}, -- NodeBox2
					{-0.4375, -0.5, -0.4375, 0.375, 0.5, -0.3125}, -- NodeBox3
					{0.3125, -0.5, -0.4375, 0.4375, 0.5, 0.375}, -- NodeBox4
					{-0.375, -0.4375, -0.375, 0.375, 0.4375, 0.375}, -- NodeBox5
				}
			}
		},
		second = {
			tiles = {
				"default_wood.png^beer_test_barrel_side.png",
				"default_wood.png^beer_test_barrel_side.png",
				"default_wood.png^beer_test_brewing_barrel_side.png",
    			"default_wood.png^beer_test_brewing_barrel_side.png",
				"default_wood.png^beer_test_brewing_barrel_front.png",
				"default_wood.png^beer_test_brewing_barrel_front.png"
			},
			drawtype = "nodebox",
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
		}
	},
	onChange = function (pos, properties, variants)
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)

		local infoText = "Barrel (" .. properties.liquidLevel .. "/" .. properties.maxCapacity .. "L)"
		meta:set_string("infotext", infoText)

		if(properties.liquidLevel < 2) then
			node.name = variants.first
			minetest.swap_node(pos, node)
		end

		if(properties.liquidLevel >= 2) then
			node.name = variants.second
			minetest.swap_node(pos, node)
		end
	end,
	formspec = function(properties)
		local sealed
		local sealButton
		if (properties.sealed) then
			sealed = "yes"
			sealButton = "button[1,3;2,1;unseal;Unseal]"
		else
			sealed = "no"
			sealButton = "button[1,3;2,1;seal;Seal]"
		end
	
		local level = properties.liquidLevel .. " of " .. properties.maxCapacity .. " L"
		
		return "size[4,4]" ..
				"label[0,0; Sealed: " .. sealed .. "]" ..
				"label[0,1; Level: " .. level .. "]" ..
				sealButton
	end,
	on_receive_fields = function (fields, commands)
		if (fields.seal) then
			commands.seal()
		end

		if (fields.unseal) then
			commands.unseal()
		end
	end
})


--[[
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
	on_punch = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:mixed_beer_grain" then
			node.name = "beer_test:barrel_mixed_beer_grain"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_beer_grain"))
		end
			
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:mixed_ale_grain" then
			node.name = "beer_test:barrel_mixed_ale_grain"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_ale_grain"))
			
		end
		
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "beer_test:mixed_mead_grain" then
			node.name = "beer_test:barrel_mixed_mead_grain"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():remove_item("main", ItemStack("beer_test:mixed_mead_grain"))
			
		end
	end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Barrel")
    end,
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
}) ]]--
print("Beer_test: barrel.lua            [ok]")