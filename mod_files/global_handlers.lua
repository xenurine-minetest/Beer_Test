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
        if (minetest.registered_craftitems[sourceNode == nil]) then 
            minetest.log("error", sourceNode + " doesn't exist!")
            return false
        end

        if (minetest.registered_craftitems[destNode == nil] and minetest.registered_nodes[destNode == nil]) then 
            minetest.log("error", destNode + " doesn't exist!")
            return false
        end

        if (self.isSoakSource(sourceNode)) then
            minetest.log("error", "Recipe for node " + sourceNode + " is already registered")
            return false
        end

        table.insert(recipes, {
            sourceNode = sourceNode,
            destNode = destNode
        })

        return true
    end



    return self
end

return {
    soakRecipeHandler = BeerTest.soakRecipeHandler()
}