function lazyLoad(file_path)
    local cache = nil
    return function()
        if not cache then
            cache = dofile(file_path)
        end
        return cache
    end
end

beer_test = {}
local modPath = minetest.get_modpath("beer_test") .. "/mod_files/"

beer_test.api = {
    classes = {
        Components = {
            LiquidContainer = lazyLoad(modPath.."classes/components/liquidcontainer.lua"),
            MetadataStorage = lazyLoad(modPath.."classes/components/metadatastorage.lua"),
            Notifier = lazyLoad(modPath.."classes/components/notifier.lua"),
        },
        Nodes = {
                Barrel = 
                {
                    Model = lazyLoad(modPath.."classes/nodes/barrel/model.lua"),
                    Controller = lazyLoad(modPath.."classes/nodes/barrel/controller.lua"),
                    ViewModel = lazyLoad(modPath.."classes/nodes/barrel/viewmodel.lua"),
                    FormSpecs = lazyLoad(modPath.."classes/nodes/barrel/formspecs.lua"),
                },
        },
        Cache = {
            NodeCache = lazyLoad(modPath.."classes/cache/nodecache.lua"),
            PlayerCache = lazyLoad(modPath.."classes/cache/playercache.lua"),
        },
        Helpers = lazyLoad(modPath.."classes/helpers.lua"),
        View = lazyLoad(modPath.."classes/view.lua")
    }
}

print("Loading Beer_Test")
print("###########################################################")
print("")
print("######                          ####### ")
print("#     # ###### ###### #####        #    ######  ####  ##### ")
print("#     # #      #      #    #       #    #      #        #")
print("######  #####  #####  #    #       #    #####   ####    #")
print("#     # #      #      #####        #    #           #   #")
print("#     # #      #      #   #        #    #      #    #   #")  
print("######  ###### ###### #    #       #    ######  ####    #") 
print("")


print("Beer_test: Loading 'beer_crafts.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/beer_crafts.lua")

print("Beer_test: Loading 'beer.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/beer.lua")

print("Beer_test: Loading 'plants.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/plants.lua")

print("Beer_test: Loading 'brewing_beer.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/brewing_beer.lua")

print("Beer_test: Loading 'abrewing_ale.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/brewing_ale.lua")


print("Beer_test: Loading 'brewing_mead.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/brewing_mead.lua")


print("Beer_test: Loading 'brewing_other.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/brewing_other.lua")


print("Beer_test: Loading 'plant-stuff.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/plants-stuff.lua")


print("Beer_test: Loading 'other_mods.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/other_mods.lua")

print("Beer_test: Loading 'other_mods.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/growing_rope.lua")


-- new file for the barrel --

print("Beer_test: Loading 'barrel.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/barrel.lua")

print("")
print("###########################################################")
print("Beer_Test has loaded successfully ")




