local modPath = minetest.get_modpath(minetest.get_current_modname()) .. "/mod_files"

local Cauldron = dofile(modPath .. "/model/cauldron.lua")
local Environment = dofile(modPath .. "/model/environment.lua")
local LiquidContainerController = dofile(modPath .. "/controller/liquid_container.lua")
---@type RefreshingFormSpecs
local formSpec = dofile(modPath .. "/lib/formspec.lua")

local CauldronController = {}

function CauldronController.onConstruct (pos)
    Cauldron.new(pos, Environment.new(pos))
end

function CauldronController.onRightClick (pos, node, clicker, itemStack, pointed_thing)
    if (not clicker:is_player()) then
        return
    end

    ---@type Cauldron
    local cauldron = Cauldron.new(pos, Environment.new(pos))

    local interacted, itemStack = LiquidContainerController.fillTakeInteraction(cauldron, clicker, itemStack)

    if (not interacted) then
        formSpec.open(cauldron,"beer_test:barrel", clicker:get_player_name())
    end

    minetest.get_node_timer(pos):start(1.0)
    return itemStack
end

function CauldronController.onTimer(pos, time)
    ---@type Cauldron
    local cauldron = Cauldron.new(pos, Environment.new(pos))
    local heated = cauldron.heat()
    cauldron.updateDisplay()

    return heated
end

function CauldronController.canDig(pos, player, node)
    ---@type Cauldron
    local cauldron = Cauldron.new(pos, Environment.new(pos))

    ---@type ItemStack
    local wielded = player.get_wielded_item(player)

    return cauldron.getLiquidLevel() == 0 or wielded.get_name(wielded) == "default:pick_mese"
end

return CauldronController