local modPath = minetest.get_modpath(minetest.get_current_modname()) .. "/mod_files"

local Barrel = dofile(modPath .. "/model/barrel.lua")
local Environment = dofile(modPath .. "/model/environment.lua")
local LiquidContainerController = dofile(modPath .. "/controller/liquid_container.lua")
---@type RefreshingFormSpecs
local formSpec = dofile(modPath .. "/lib/formspec.lua")

local BarrelController = {}

function BarrelController.onConstruct (pos)
    Barrel.new(pos, Environment.new(pos))
end

function BarrelController.onRightClick (pos, node, clicker, itemStack, pointed_thing)
    if (not clicker:is_player()) then
        return
    end

    ---@type Barrel
    local barrel = Barrel.new(pos, Environment.new(pos))

    local interacted, itemStack = LiquidContainerController.fillTakeInteraction(barrel, clicker, itemStack)

    if (not interacted) then
        formSpec.open(barrel,"beer_test:barrel", clicker:get_player_name())
    end

    minetest.get_node_timer(pos):start(1.0)
    return itemStack
end

function BarrelController.onTimer (pos, time)
    ---@type Barrel
    local barrel = Barrel.new(pos, Environment.new(pos))

    local heated = barrel.heat()
    local soaked = false

    if (barrel.hasSoakingItems()) then
        soaked = barrel.soak()
    end

    barrel.updateDisplay()

    if (soaked or heated) then
        return true
    end
end

function BarrelController.canDig (pos, player, node)
    ---@type Barrel
    local barrel = Barrel.new(pos, Environment.new(pos))

    ---@type ItemStack
    local wielded = player.get_wielded_item(player)

    return barrel.allInventoriesEmpty() and barrel.getLiquidLevel() == 0 or wielded.get_name(wielded) == "default:pick_mese"
end

return BarrelController