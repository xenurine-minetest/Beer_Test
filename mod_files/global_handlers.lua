local BeerTest = {}

BeerTest.soakRecipeHandler = function ()
    local self = {}

    local isSourceNodeRegistered
    local recipes = {}

    self.getDestinationForSource = function (sourceNode)
        for i, recipe in ipairs(recipes) do
            if (recipe.sourceNode == sourceNode) then
                return recipe.destNode
            end
        end

        return nil
    end

    self.isSoakSource = function (sourceNode)
        for i, recipe in ipairs(recipes) do
            if (recipe.sourceNode == sourceNode) then
                return true
            end
        end

        return false
    end

    self.registerSoakRecipe = function (sourceNode, destNode)
        -- TODO: check if nodes are registered in minetest

        if (self.isSoakSource(sourceNode)) then
            minetest.log("error", "Recipe for node " + sourceNode + " is already registered")
            return false
        end

        table.insert(recipes, {
            sourceNode = sourceNode,
            destNode = destNode
        })
    end



    return self
end

return {
    soakRecipeHandler = BeerTest.soakRecipeHandler()
}