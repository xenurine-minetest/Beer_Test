local Barrel = beer_test.api.classes.Nodes.Barrel.Model()
local NodeCache = beer_test.api.classes.Cache.NodeCache()
local PlayerCache = beer_test.api.classes.Cache.PlayerCache()
local ViewModel = beer_test.api.classes.Nodes.Barrel.ViewModel()
local View = beer_test.api.classes.View()
local FormSpecs = beer_test.api.classes.Nodes.Barrel.FormSpecs()

local BarrelFactory  = function(pos, node)
    local barrel = NodeCache.get(pos)
    if (barrel ~= nil) then
        return barrel
    end

    barrel = Barrel.new(pos)
    NodeCache.add(pos, barrel)

    barrel.addListener(
        function(data)
            local replaceNodeName = ""
            if(data.liquidLevel < 3) then
                replaceNodeName = "beer_test:barrel"
            else
                replaceNodeName = "beer_test:brewing_barrel"
            end

            if (node.name ~= replaceNodeName) then
                node.name = replaceNodeName
                minetest.swap_node(pos, node)
            end
        end
    )

    barrel.addListener(
        function(data)
            print(data.liquidLevel)
            local meta = minetest.get_meta(pos)
            meta:set_string("infotext", "Barrel " .. data.liquidLevel .. "/10L")
        end
    )
    return barrel
end

local BarrelController = {
    onRightClick = function (pos, node, clicker, itemstack, pointed_thing)
        local playerName = clicker:get_player_name()
        local barrel = BarrelFactory(pos, node)
        local item = clicker:get_wielded_item():get_name()

        if item and item == "bucket:bucket_water" then
            if (barrel.fill(1)) then
                clicker:get_inventory():remove_item("main", ItemStack("bucket:bucket_water"))
            end
        else
            local viewModel = PlayerCache.get(playerName)
            if (viewModel == nil) then
                viewModel = ViewModel.new(barrel, playerName)
                PlayerCache.add(playerName, viewModel)
                barrel.addListener(
                    function()
                        View.createView(viewModel, FormSpecs.default)
                    end
                )
            end
            
            View.createView(viewModel, FormSpecs.default)
        end
    end,

    onConstruct = function(pos)
        local barrel = BarrelFactory(pos, minetest.get_node(pos))
    end
}

return BarrelController