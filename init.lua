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

-- new nodes --

print("Beer_test: Loading 'malting.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/malting.lua")

print("Beer_test: Loading 'barrel_node.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/barrel_node.lua")

print("Beer_test: Loading 'cauldron_node.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/cauldron_node.lua")

print("Beer_test: Loading 'global_handlers.lua'")
beer_test = dofile(minetest.get_modpath("beer_test").."/mod_files/lib/global_handlers.lua")

print("Beer_test: Loading 'debug_commands.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/lib/debug_commands.lua")

beer_test.soakRecipeHandler.registerSoakRecipe("beer_test:cracked_barley", "beer_test:soaked_barley")

print("")
print("###########################################################")
print("Beer_Test has loaded successfully ")



print("Beer_test: Loading 'player_effects.lua'")
dofile(minetest.get_modpath("beer_test").."/mod_files/lib/player_effects.lua")
