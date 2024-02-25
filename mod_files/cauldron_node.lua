local modname = minetest.get_current_modname()
local Cauldron = dofile(minetest.get_modpath(modname) .. "/mod_files/cauldron.lua")
local Environment = dofile(minetest.get_modpath(modname) .. "/mod_files/environment.lua")

---@type RefreshingFormSpecs
local formSpec = dofile(minetest.get_modpath(modname) .. "/mod_files/formspec.lua")

local function onConstruct (pos)
    Cauldron.new(pos, Environment.new(pos))
end

local function onTimer(pos)
    ---@type Cauldron
    local cauldron = Cauldron.new(pos, Environment.new(pos))
    local heated = cauldron.heat()
    cauldron.updateDisplay()

    return heated
end

local function canDig (pos, player, node)
    ---@type Cauldron
    local cauldron = Cauldron.new(pos, Environment.new(pos))
    return cauldron.getLiquidLevel() == 0
end

local function onRightClick (pos, node, clicker, itemStack, pointed_thing)
    if (not clicker:is_player()) then
        return
    end

    ---@type Cauldron
    local cauldron = Cauldron.new(pos, Environment.new(pos))

    if (itemStack:get_name() == "bucket:bucket_water") then
        cauldron.fillLiquid(1, 'water', 20)
    elseif (itemStack:get_name() == "bucket:bucket_empty") then
        cauldron.takeLiquid(1)
    else
        formSpec.open(cauldron,"beer_test:barrel", clicker:get_player_name())
    end

    minetest.get_node_timer(pos):start(1.0)
end

minetest.register_node("beer_test:cauldron",{
    description = "Empty Barrel",
    drawtype = "nodebox",
    --TODO: replace xdecor tiles or add copyright
    tiles = {"beer_test_barrel_top.png", "beer_test_barrel_top.png", "xdecor_cauldron_sides.png",
             "xdecor_cauldron_sides.png", "xdecor_cauldron_sides.png", "xdecor_cauldron_sides.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky=2},
    sounds = default.node_sound_wood_defaults(),
    can_dig = canDig,
    on_timer = onTimer,
    on_construct = onConstruct,
    on_rightclick = onRightClick,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.5, 0.5, 0.5, 0.35}, -- side f
            {-0.5, -0.5, -0.5, 0.5, -0.35, 0.5}, -- bottom
            {-0.5, -0.5, -0.5, -0.35, 0.5, 0.5}, -- side l
            {0.35, -0.5, -0.5, 0.5, 0.5, 0.5},  -- side r
            {-0.5, -0.5, -0.35, 0.5, 0.5, -0.5}, -- frount
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
})