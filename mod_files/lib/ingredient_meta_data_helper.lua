--TODO:refactor this!
---@class IngredientMetaDataHelper
local IngredientMetaDataHelper = {}

---@type table<string,string>
IngredientMetaDataHelper.definition = {
    aAmylase = "int",
    bAmylase = "int",
    protease = "int",
    starch = "int",
    protein = "int",
    dextrin = "int",
    maltose = "int",
    aminoAcid = "int"
}

---@type fun(meta:MetaDataRef):table<string,number>
IngredientMetaDataHelper.get = function (meta)
    local itemMetaData = {}

    for key,type in pairs(IngredientMetaDataHelper.definition) do
        if (type == "float") then
            itemMetaData[key] = meta:get_float(key)
        end

        if (type == "int") then
            itemMetaData[key] = meta:get_int(key)
        end
    end

    return itemMetaData
end

---@type fun(meta:MetaDataRef,itemMetaData:table<string,number>)
IngredientMetaDataHelper.set = function (meta, itemMetaData)
    for itemMetaDataKey,itemMetaDataValue in pairs(itemMetaData) do
        local type = IngredientMetaDataHelper.definition[itemMetaDataKey]

        if (type == "float") then
            meta:set_float(itemMetaDataKey, itemMetaDataValue)
        end

        if (type == "int") then
            meta:set_int(itemMetaDataKey, itemMetaDataValue)
        end
    end
end

--TODO:make less CPU consuming
---@type fun(ingredients:table<string,table<string, number>>, temperature:number): table<string,table<string, number>>
IngredientMetaDataHelper.calculator = function(ingredients, temperature)
    for enzyme,enzymeSpecs in pairs(IngredientMetaDataHelper.enzymeData) do
        if (ingredients[enzyme] > 0) then
            local activityCoEfficient = IngredientMetaDataHelper.gauss(enzymeSpecs.median, enzymeSpecs.variance, temperature)

            local denatureCoEfficient = IngredientMetaDataHelper.calculateDenatureCoEfficient(enzymeSpecs.denature, temperature)
            local enzymeAmount = ingredients[enzyme]

            local amountAfterDenature = enzymeAmount - enzymeAmount*denatureCoEfficient
            if (amountAfterDenature > 0) then
                ingredients[enzyme] = amountAfterDenature
            else
                ingredients[enzyme] = 0
                -- why the fuck lua has no continue() ??????????
            end

            enzymeAmount = ingredients[enzyme]
            local convertAmount = enzymeAmount * activityCoEfficient
            local consumedIngredientLeft = ingredients[enzymeSpecs.consumes] - convertAmount
            if (consumedIngredientLeft >= 0) then
                ingredients[enzymeSpecs.consumes] = consumedIngredientLeft
                ingredients[enzymeSpecs.produces] = ingredients[enzymeSpecs.produces] + convertAmount
            else
                ingredients[enzymeSpecs.produces] = ingredients[enzymeSpecs.produces] + ingredients[enzymeSpecs.consumes]
                ingredients[enzymeSpecs.consumes] = 0
            end
        end
    end

    return ingredients
end

---@type fun(denatureTemperature:number, currentTemperature:number): number
IngredientMetaDataHelper.calculateDenatureCoEfficient = function (denatureTemperature, currentTemperature)
    local delta = currentTemperature - denatureTemperature

    if (delta < 0) then
        return 0
    end

    return delta/20
end

---@type fun(median:number, variance:number, temperature:number): number
IngredientMetaDataHelper.gauss = function (median, variance, temperature)
    local result = (1/(variance*math.sqrt(2*math.pi)))^(-0.5*((temperature-median)/variance)^2)
    result = math.floor(result*100)/100
    return result
end

IngredientMetaDataHelper.enzymeData = {
    aAmylase = {
        median = 70,
        variance = 0.392,
        consumes = "starch",
        produces = "dextrin",
        denature = 80
    },
    bAmylase = {
        median = 62,
        variance = 0.396,
        consumes = "starch",
        produces = "maltose",
        denature = 69
    },
    protease = {
        median = 53,
        variance = 0.396,
        consumes = "protein",
        produces = "aminoAcid",
        denature = 57
    }
}

return IngredientMetaDataHelper