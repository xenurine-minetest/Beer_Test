--------------------------
-- Items                --
--------------------------

--dont required, because its registered in farming

minetest.register_craftitem("beer_test:yeast", {
	description = "Yeast",
	inventory_image = "beer_test_yeast.png",
}) 

minetest.register_craftitem("beer_test:oat_grain", {
	description = "Oat Grain",
	inventory_image = "beer_test_oat_grain.png",
}) 

 --[[  -- keep this --
minetest.register_craftitem("beer_test:barley", {
	description = "Barley",
	inventory_image = "default_paper.png",
})
]]--



---------------------------------------------------------------
-- malt grain--
---------------------------------------------------------------


minetest.register_craftitem("beer_test:malt_grain_crystalised_malt", {
	description = "Crystalised Malt Grain",
	inventory_image = "beer_test_crystalised_malt.png",
})


--------------------------
-- Malt Tray            --
--------------------------

-- removed see malting for more info

--------------------------
-- wheat to malt stuff  --
--------------------------





print("Beer_test: beer.lua                     [ok]")



