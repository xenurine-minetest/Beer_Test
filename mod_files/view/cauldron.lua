local View = {}

View.infoTexts = {
    empty = function ()
        return "Empty Cauldron"
    end,
    filled = function (liquidData)
        local infoText = "Cauldron filled with " .. liquidData.type
        infoText = infoText .. " " .. liquidData.amount .. "L/" .. liquidData.limit .. "L"
        return infoText
    end
}

View.formSpecs = {
    default = function (liquidData)
        local fillStateInPercent = liquidData.level/liquidData.limit*100
        local infoText = ""

        if (liquidData.type == "") then
            infoText = "Empty Cauldron"
        else
            infoText = "Cauldron filled with " .. liquidData.type .. " "
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
            "size[11,5]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "label[0.375,0.5;"..infoText.."]",
            verticalBar(1.55, 1, 1, 3, fillStateInPercent),
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end,
    debug = function (liquidData, temperature)
        local fillStateInPercent = liquidData.level/liquidData.limit*100
        local infoText = ""

        if (liquidData.type == "") then
            infoText = "Empty Cauldron"
        else
            infoText = "Cauldron filled with " .. liquidData.type .. " "
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
            "label[0.5,5;DEBUG:]",
            "label[0.5,6;Temperature: "..math.floor(temperature*100)/100 .."°C]",
            "label[0.5,6.5;aAmylase: "..liquidData.ingredients.aAmylase.." U/L]",
            "label[0.5,7;bAmylase: "..liquidData.ingredients.bAmylase.." U/L]",
            "label[0.5,7.5;Protease: "..liquidData.ingredients.protease.." U/L]",
            "label[5,6.5;Starch: "..liquidData.ingredients.starch.." U/L]",
            "label[5,7;Protein: "..liquidData.ingredients.protein.." U/L]",
            "label[5,7.5;Dextrin: "..liquidData.ingredients.dextrin.." µmol/L]",
            "label[5,8;Maltose: "..liquidData.ingredients.maltose.." µmol/L]",
            "label[5,8.5;Amino Acid: "..liquidData.ingredients.aminoAcid.." µmol/L]",
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end,
}

return View