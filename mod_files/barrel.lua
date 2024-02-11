--------------------------
-- Items                --
--------------------------

--------------------------
-- blocks               --
--------------------------

function default.get_barrel_empty_formspec(infotext)
	return "size[8,8.5]" ..
		"padding[1,1]" ..
		"label[0,0.0;"..infotext.."]" ..
		"image[2,1;1,3.35;gui_barrel_bar.png]" ..
		"list[context;liquid;3,1;1,1;]" ..
		"list[context;src;3,3;1,1;]" ..
		"image[4,3;1,1;gui_barrel_arrow_bg.png]" ..
		"list[context;dst;5,3;1,1;]" ..
		"list[context;buk;6,3;1,1;]" ..
		"button[5,1.2;2,0.5;test;Seal Barrel]" ..
		"list[current_player;main;0,4.5;8,4;]" ..
	default.get_hotbar_bg(0, 4.5)
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




local function can_dig(pos, player, node)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst")
end

local function barrel_node_timer(pos, newFull)
	
	local meta = minetest.get_meta(pos)
	-- GUI elements so fromspec and GUI
	local formspec
	local infotext

	--[[
	
	--local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local srclist, liquidlist 

    srclist = inv:get_list("src")
	liquidlist = inv:get_list("liquid")
 	
 	infotext = ("Barrel "..srclist.."")

    -- Check if there is fuel
    if liquidlist == "bucket:bucket_water" then
		for i, itemstack in ipairs(srclist) do
            if itemstack == "default:apple" then
                -- Remove the apple from src
                itemstack:take_item()
                inv:set_stack('src', i, itemstack)

                -- Add a soaked barley apple to dst
                inv:add_item('dst', "beer_test:soaked_barley")
                inv:set_stack('dst', 1, dst_stack)

     
            end
        end
    end
	]]--


	if newFull == 0 then
		infotext = ("Empty Barrel")
		formspec = default.get_barrel_empty_formspec(infotext)
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
		-- set barrel inv size
		local inv = meta:get_inventory()
		inv:set_size("liquid", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 1)
		inv:set_size("buk", 1)
		newFull = meta:get_int("full")

		barrel_node_timer(pos, newFull, node) 

	end,

	--[[	on_punch = function(pos, node, puncher) 
		local meta = minetest.get_meta(pos)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "bucket:bucket_water" then
			puncher:get_inventory():remove_item("main", ItemStack("bucket:bucket_water"))
			puncher:get_inventory():add_item("main", ItemStack("bucket:bucket_empty"))
			meta:set_int("full",100);

		end
	end,
	]]
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

-------------------

minetest.register_abm({
    nodenames = {"beer_test:barrel"},
    interval = 1.0, -- Run every second
    chance = 1, -- Always run for all nodes
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local src_list = inv:get_list('src')
        local liquid_list = inv:get_list('liquid')

        -- Check if there is fuel
        if liquid_list[1]:get_name() == "bucket:bucket_water" then
            for i, itemstack in ipairs(src_list) do
                if itemstack:get_name() == "beer_test:cracked_barley" then
                    -- Remove the apple from src
                    itemstack:take_item()
                    inv:set_stack('src', i, itemstack)

                    local liquid_stack = liquid_list[1]
                    liquid_stack:set_count(liquid_stack:get_count() - 1)
                    inv:set_stack('liquid', 1, liquid_stack)


                    -- add soaked barley and give back bukket 
            
                    local dst_stack = inv:get_stack('dst', 1)
                    dst_stack:add_item("beer_test:soaked_barley")
                    inv:set_stack('dst', 1, dst_stack)
         
                    local bucket_stack = inv:get_stack('liquid', 1)
                    bucket_stack:add_item("bucket:bucket_empty")
                    inv:set_stack('liquid', 1, bucket_stack)
               


                end
            end
        end
    end,
})