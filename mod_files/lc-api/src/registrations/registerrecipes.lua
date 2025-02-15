---@type RecipeDefinition[]
local soakRepipes = {}

---@alias RecipeRegistration.registerRecipe fun(recipeDefinition: RecipeDefinition): nil
local function registerRecipe(recipeDefinition)
    if (recipeDefinition.type == 'soak') then
        table.insert(soakRepipes, {
            input = recipeDefinition.input,
            output = recipeDefinition.output,
            liquidType = (recipeDefinition.liquidType == nil and 'any' or recipeDefinition.liquidType),
            minLiquidRatio = recipeDefinition.minLiquidRatio,
            inputVolume = (recipeDefinition.inputVolume == nil and 0 or recipeDefinition.inputVolume),
            consumesLiquid = (recipeDefinition.consumesLiquid == nil and 0 or recipeDefinition.consumesLiquid),
            processTime = (recipeDefinition.processTime == nil and 0 or recipeDefinition.processTime),
        })
    end
end

---@alias RecipeRegistration.getSoakRecipesForItem fun(item: string): nil|RecipeDefinition
local function getSoakRecipesForItem(item)
    print(dump2(soakRepipes, "allrecipes"))
    for _,recipe in ipairs(soakRepipes) do
        if (recipe.input == item) then
            return recipe
        end
    end

    return nil
end

---@class RecipeRegistration
---@field registerRecipe RecipeRegistration.registerRecipe
---@field getSoakRecipesForItem RecipeRegistration.getSoakRecipesForItem
return {
    registerRecipe = registerRecipe,
    getSoakRecipesForItem = getSoakRecipesForItem
}
