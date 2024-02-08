--------------------------
-- Items                --
--------------------------

--------------------------
-- blocks               --
--------------------------
function default.get_barrel_empty_formspec()
	return "size[8,7.5]" ..
		"image[1,0;1,3.35;gui_barrel_bar.png]" ..
		"image[4,1;1,1;gui_barrel_arrow_bg.png]" ..
		"list[current_player;main;0,3.5;8,4;]" ..
		"list[context;main;2,0;2,3;]" ..
		"list[context;out;5,1;1,1;]" ..
		"label[5,0.0;Barrel]" ..
		"button[5,2.5;2,0.5;test;Seal Barrel]" ..
	default.get_hotbar_bg(0, 4.25)
end

function default.get_barrel_active_formspec()
	return "size[8,7.5]" ..
		"image[1,0;1,3.35;gui_barrel_bar.png]" ..
		"image[1,0;1,3.35;gui_barrel_bar_fg.png]" ..
		"image[4,1;1,1;gui_barrel_arrow_bg.png]" ..
		"list[current_player;main;0,3.5;8,4;]" ..
		"list[context;main;2,0;2,3;]" ..
		"list[context;out;5,1;1,1;]" ..
		"label[5,0.0;Barrel]" ..
		"button[5,2.5;2,0.5;test;Seal Barrel]" ..
	default.get_hotbar_bg(0, 4.25)
end




local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("main") and inv:is_empty("out")
end

local function barrel_node_timer(pos, newFull)
	
	local meta = minetest.get_meta(pos)
	local active = false
	local formspec
	local infotext


	

	if newFull == 0 then
		infotext = ("Empty Barrel")
		formspec = default.get_barrel_empty_formspec()
	else
		infotext = ("Barrel "..newFull.."% Full")
		formspec = default.get_barrel_active_formspec()
	end

	meta:set_string("formspec", formspec)
	meta:set_string("infotext", infotext)



end

minetest.register_node("beer_test:barrel", {
    description = "Empty Barrel",
	drawtype = "nodebox",
    tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "beer_test_barrel_side_2.png",
    "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png", "beer_test_barrel_side_2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    -- node stuff 
    can_dig = can_dig,
	on_timer =  barrel_node_timer,
    on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		-- set barrel inv size
		inv:set_size("main", 6)
		inv:set_size("out", 1)
		newFull = meta:get_int("full")
		barrel_node_timer(pos, newFull) 

	end,
	on_punch = function(pos, node, puncher) 
		local meta = minetest.get_meta(pos)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "bucket:bucket_water" then
			puncher:get_inventory():remove_item("main", ItemStack("bucket:bucket_water"))
			puncher:get_inventory():add_item("main", ItemStack("bucket:bucket_empty"))
			meta:set_int("full",100);

		end
	end,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0.5, 0.35}, -- side f
            {-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}, -- bottom
            {-0.5, -0.5, -0.5, -0.35, 0.5, 0.5}, -- side l
            {0.35, -0.5, -0.5, 0.5, 0.5, 0.5},  -- side r
            {-0.5, -0.5, -0.35, 0.5, 0.5, -0.5}, -- frount
             
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    }, 
})

