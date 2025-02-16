local FillableRegistration = lc_api.Registrations.Fillable()
local ViewComponents = lc_api.modules.View.Components()

local formspecs = {
	unsealed = function(pos, properties)
		local levelString = properties.liquidLevel .. " of " .. properties.maxCapacity .. " L"

		
		return  "formspec_version[8]"..
				"size[11,10]" ..
				"position[0.5,0.5]"..
				"anchor[0.5,0.5]"..
				"padding[0.1,0.1]"..
				ViewComponents.verticalBar(0.5,1,1,3,(properties.liquidLevel/properties.maxCapacity*100), "beer_test_bar_blue.png")..
				"label[0.5,0.5; Level: " .. levelString .. "]" ..
				"button[2.0,2.0;2,1;seal;Seal]"..
				"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";input;4.5,1;1,1;]" ..
				"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";output;4.5,2.5;1,1;]" ..
            	"list[current_player;main;0.5,5;8,4;]"
				
	end,

	sealed = function(pos, properties)
		local levelString = properties.liquidLevel .. " of " .. properties.maxCapacity .. " L"
		
		return  "formspec_version[8]"..
				"size[11,10]" ..
				"position[0.5,0.5]"..
				"anchor[0.5,0.5]"..
				"padding[0.1,0.1]"..
				ViewComponents.verticalBar(0.5,1,1,3,(properties.liquidLevel/properties.maxCapacity*100), "beer_test_bar_blue.png")..
				"label[0.5,0.5; Level: " .. levelString .. "]" ..
				"button[2.0,2.0;2,1;unseal;Unseal]"..
				"label[4.5,2; Sealed barrel will process stuff ...]" ..
            	"list[current_player;main;0.5,5;8,4;]"
	end
}

FillableRegistration("beer_test:barrel", {
	description = "Barrel",
	paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    use_texture_alpha = "blend",
	sealable = true,
	fillable = true,
	canSoak = true,
	inventories = {
		input = 1,
		output = 1
	},
	variants = {
		empty = {
			default = true,
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_empty.obj"
		},
		oneOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_1.obj"
		},
		twoOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_2.obj"
		},
		threeOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_3.obj"
		},
		fourOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_4.obj"
		},
		fiveOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_5.obj"
		},
		sixOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_6.obj"
		},
		sevenOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_7.obj"
		},
		eightOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_8.obj"
		},
		nineOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_9.obj"
		},
		tenOfTen = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_10.obj"
		},
		closed = {
			tiles = {{name = "beer_test_barrel_combined.png^beer_test_barrel_water.png"}},
			drawtype = "mesh",
			mesh = "beer_test_barrel_closed.obj"
		},
	},
	onChange = function (pos, properties, variants)
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)

		local infoText = "Barrel (" .. properties.liquidLevel .. "/" .. properties.maxCapacity .. "L)"
		meta:set_string("infotext", infoText)

		if(properties.liquidLevel == 0) then
			node.name = variants.empty
		end

		if(properties.liquidLevel == 1) then
			node.name = variants.oneOfTen
		end

		if(properties.liquidLevel == 2) then
			node.name = variants.twoOfTen
		end

		if(properties.liquidLevel == 3) then
			node.name = variants.threeOfTen
		end

		if(properties.liquidLevel == 4) then
			node.name = variants.fourOfTen
		end

		if(properties.liquidLevel == 5) then
			node.name = variants.fiveOfTen
		end

		if(properties.liquidLevel == 6) then
			node.name = variants.sixOfTen
		end

		if(properties.liquidLevel == 7) then
			node.name = variants.sevenOfTen
		end

		if(properties.liquidLevel == 8) then
			node.name = variants.eightOfTen
		end

		if(properties.liquidLevel == 9) then
			node.name = variants.nineOfTen
		end

		if(properties.liquidLevel == 10) then
			node.name = variants.tenOfTen
		end

		if(properties.sealed) then
			node.name = variants.closed
		end

		minetest.swap_node(pos, node)
	end,
	formspec = function(pos,properties)
		if (properties.sealed) then
			return formspecs.sealed(pos, properties)
		else
			return formspecs.unsealed(pos, properties)
		end
	end,
	on_receive_fields = function (fields, commands)
		print(dump2(commands, "commands"))
		if (fields.seal) then
			commands.seal()
		end

		if (fields.unseal) then
			commands.unseal()
		end
	end
})
print("Beer_test: barrel.lua            [ok]")