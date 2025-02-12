local RecipeRegistration = lc_api.register.Recipes()

minetest.register_craftitem("beer_test:soaked_barley", {
    description = "Soaked barley",
    inventory_image = "beer_test_barley_soaked.png",
    groups = {flammable = 0},
})

RecipeRegistration.registerRecipe({
    type = "soak",
    input = "beer_test:seed_barley",
    output = "beer_test:soaked_barley",
    liquidType = "water",
    minLiquidRatio = 2,
    inputVolume = 0.25,
    consumesLiquid = 1,
    processTime = 1
})