local RecipeRegistration = lc_api.Registrations.Recipes()
local ItemRegistrator = lc_api.Registrations.Items()

minetest.register_craftitem("beer_test:soaked_barley", {
    description = "Soaked barley",
    inventory_image = "beer_test_barley_soaked.png",
    groups = {flammable = 0},
})

ItemRegistrator.registerItem({
    itemName = "beer_test:seed_barley",
    volume = 0.25
})

ItemRegistrator.registerItem({
    itemName = "beer_test:soaked_barley",
    volume = 0.25
})

RecipeRegistration.registerRecipe({
    type = "soak",
    input = "beer_test:seed_barley",
    output = "beer_test:soaked_barley",
    liquidType = "water",
    minLiquidRatio = 2,
    consumesLiquid = 1,
    processTime = 1
})

