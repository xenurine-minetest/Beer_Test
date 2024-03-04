local View = {}

View.infoTexts = {
    empty = function ()
        return "Empty Barrel"
    end,
    filled = function (liquidData, itemName)
        local infoText = "Barrel contains "

        if (itemName ~= "") then
            local itemDescription
            if (minetest.registered_nodes[itemName] ~= nil) then
                itemDescription = minetest.registered_nodes[itemName]['description']
            elseif (minetest.registered_items[itemName] ~= nil) then
                itemDescription = minetest.registered_items[itemName]['description']
            elseif (minetest.registered_craftitems[itemName] ~= nil) then
                itemDescription = minetest.registered_craftitems[itemName]['description']
            else
                itemDescription = itemName
            end

            infoText = infoText .. itemDescription
        end

        if (liquidType ~= "") then
            if (itemName ~= "") then infoText = infoText .. " and " end
            infoText = infoText .. liquidData.type .. " " .. liquidData.amount .. "L / " .. liquidData.limit .. "L"
        end

        return infoText
    end
}

View.formSpecs = {
    default = function (liquidData, nodePosition)
        local fillStateInPercent = liquidData.level/liquidData.limit*100
        local infoText = ""

        if (liquidData.type == "") then
            infoText = "Empty Barrel"
        else
            infoText = "Barrel filled with " .. liquidData.type .. " "
                    .. liquidData.level .. "L / " .. " " .. liquidData.limit .. "L"
        end

        local function verticalBar (x, y, width, height, percent)
            local backGround = "image["..x..","..y..";"..width..","..height..";gui_barrel_bar.png]"
            local foreground = ""

            if (percent > 0 ) then
                local heightP = height/100*percent
                local yP = height - heightP +y

                foreground = "image["..x..","..yP..";"..width..","..heightP..";gui_barrel_bar_fg.png]"
            end

            return backGround .. foreground
        end

        return table.concat({
            "formspec_version[6]",
            "size[11,10]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "label[0.375,0.5;"..infoText.."]",
            verticalBar(1.55, 1, 1, 3, fillStateInPercent),
            "list["..nodePosition..";src;4.05,3;1,1;]",
            "image[5.3,3;1,1;gui_barrel_arrow_bg.png]",
            "list["..nodePosition..";dst;6.55,3;1,1;]",
            "button[5,1.2;2,0.5;test;Seal Barrel]",
            "list[current_player;main;0.3,4.5;8,4;]",
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end,
    debug = function (liquidData, nodePosition)
        local fillStateInPercent = liquidData.amount/liquidData.limit*100
        local infoText = ""

        if (liquidData.type == "") then
            infoText = "Empty Barrel"
        else
            infoText = "Barrel filled with " .. liquidData.type .. " "
                    .. liquidData.amount .. "L / " .. " " .. liquidData.limit .. "L"
        end

        local function verticalBar (x, y, width, height, percent)
            local backGround = "image["..x..","..y..";"..width..","..height..";gui_barrel_bar.png]"
            local foreground = ""

            if (percent > 0 ) then
                local heightP = height/100*percent
                local yP = height - heightP +y

                foreground = "image["..x..","..yP..";"..width..","..heightP..";gui_barrel_bar_fg.png]"
            end

            return backGround .. foreground
        end

        return table.concat({
            "formspec_version[6]",
            "size[15,10]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "label[0.375,0.5;"..infoText.."]",
            verticalBar(1.55, 1, 1, 3, fillStateInPercent),
            "list["..nodePosition..";src;4.05,3;1,1;]",
            "image[5.3,3;1,1;gui_barrel_arrow_bg.png]",
            "list["..nodePosition..";dst;6.55,3;1,1;]",
            "button[5,1.2;2,0.5;test;Seal Barrel]",
            "list[current_player;main;0.3,4.5;8,4;]",
            "label[10.9,0.5;DEBUG:]",
            "label[10.9,1;Temperature: "..math.floor(liquidData.temperature*100)/100 .."°C]",
            "label[10.9,1.5;aAmylase: "..liquidData.ingredients.aAmylase.." U/L]",
            "label[10.9,2;bAmylase: "..liquidData.ingredients.bAmylase.." U/L]",
            "label[10.9,2.5;Protease: "..liquidData.ingredients.protease.." U/L]",
            "label[10.9,3.5;Starch: "..liquidData.ingredients.starch.." U/L]",
            "label[10.9,4;Protein: "..liquidData.ingredients.protein.." U/L]",
            "label[10.9,4.5;Dextrin: "..liquidData.ingredients.dextrin.." µmol/L]",
            "label[10.9,5;Maltose: "..liquidData.ingredients.maltose.." µmol/L]",
            "label[10.9,5.5;Amino Acid: "..liquidData.ingredients.aminoAcid.." µmol/L]",
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end,
    fermenting = function ()

    end
}

return View