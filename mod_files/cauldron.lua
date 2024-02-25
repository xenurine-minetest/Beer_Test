local LiquidContainer = dofile(minetest.get_modpath("beer_test").."/mod_files/abstract_liquid_container.lua")
local Cauldron = {}

Cauldron.new = function (pos, environment)
    ---@class Cauldron :LiquidContainer
    local self = LiquidContainer.new(pos, environment)

    -- private property declarations
    local meta

    -- private method declarations
    local initialize, updateFormSpec, updateInfo

    -- constructor
    local construct = function ()
        meta = minetest.get_meta(pos)

        if (meta:get_int("initialized") == 0) then
            initialize()
        end
    end

    -- public methods
    self.setFormSpec = function(setFormSpec)
        meta:set_string("formSpec", setFormSpec)
    end

    self.getFormSpec = function ()
        return meta:get_string("formSpec")
    end

    self.updateDisplay = function()
        updateFormSpec()
        updateInfo()
    end

    -- private methods
    initialize = function ()
        self.updateDisplay()
        meta:set_int("initialized", 1)
    end

    updateFormSpec = function()
        self.setFormSpec(Cauldron.formspecs.default(
                {level = self.getLiquidLevel(), limit = self.getLiquidLevelLimit(), type = self.getLiquidType()},
                self.getTemperature()
        ))
    end

    updateInfo = function()  end

    construct()
    return self;
end

Cauldron.formspecs = {
    default = function (liquidData, temperature)
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
            "label[0.5,6;Temperature: "..temperature.."°C]"
            --"button[5,1.2;2,0.5;test;Seal Barrel]",
            --"list[current_player;main;0.3,4.5;8,4;]",
            --default.get_hotbar_bg(0, 4.5)
        }, "")
    end,
}

return Cauldron