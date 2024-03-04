local getFormSpec = function ()
    return table.concat({
        "formspec_version[7]",
        "size[12,10]",
        "position[0.5,0.5]",
        "padding[0.1,0.1]",
        "label[0.375,0.5;Create Mash]",
        "field[0.375,1.5;5,1;aamylase;Alpha Amylase in U/L;20000]",
        "field[0.375,3;5,1;bamylase;Beta Amylase in U/L;10000]",
        "field[0.375,4.5;5,1;protease;Protease in U/L;10000]",
        "field[6,1.5;5,1;starch;Starch in µmol/L;490000]",
        "field[6,4.5;5,1;protein;Protein in µmol/L;20000]",
        "button[4,7;4,1;submit;Give me the mash!]",
        --"button[6,7;3,1;cancel;Cancel]",
    },"")
end

local formSpecName = "beer_test:debug_mash"

minetest.register_chatcommand("mash", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        minetest.show_formspec(name, formSpecName, getFormSpec())
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= formSpecName then
        return
    end

    if (fields.quit == "true") then
        return
    end

    if (fields.submit ~= nil) then
        local aAmylase = tonumber(fields.aamylase)
        if (aAmylase == nil) then
            aAmylase = 0
        end

        local bAmylase = tonumber(fields.bamylase)
        if (bAmylase == nil) then
            bAmylase = 0
        end

        local protease = tonumber(fields.protease)
        if (protease == nil) then
            protease = 0
        end

        local starch = tonumber(fields.starch)
        if (starch == nil) then
            starch = 0
        end

        local protein = tonumber(fields.protein)
        if (protein == nil) then
            protein = 0
        end

        local itemStack = ItemStack("bucket:bucket_water 10")
        local meta = itemStack:get_meta()

        meta:set_float("aAmylase", aAmylase)
        meta:set_float("bAmylase", bAmylase)
        meta:set_float("protease", protease)
        meta:set_float("starch", starch)
        meta:set_float("protein", protein)
        meta:set_int("temperature", 30)

        local inventory = minetest.get_inventory({ type="player", name=player:get_player_name() })
        inventory:add_item("main", itemStack)
    end
end)