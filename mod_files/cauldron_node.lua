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
        local iMeta = itemStack:get_meta()
        local temperature = iMeta:get("temperature")
        if (temperature == nil) then
            temperature = 20
        end
        itemStack:take_item(1)

        local overflow = cauldron.fillLiquid(1, 'water', temperature)

        if (overflow == 0) then
            local playerInventory = minetest.get_inventory({ type="player", name=clicker:get_player_name() })
            playerInventory:add_item("main", ItemStack("bucket:bucket_empty"))
        end

    elseif (itemStack:get_name() == "bucket:bucket_empty") then

        local amount, temperature = cauldron.takeLiquid(1)

        if (amount > 0) then
            local playerInventory = minetest.get_inventory(
                    { type="player", name=clicker:get_player_name() }
            )

            itemStack:take_item(1)
            local waterBucketStack = ItemStack("bucket:bucket_water")
            local iMeta = waterBucketStack:get_meta()
            iMeta:set_float("temperature", temperature)
            local leftover = playerInventory:add_item("main", waterBucketStack)
        end

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
            {-0.5000, -0.06250, -0.5000, -0.4375, 0.5000, 0.5000},
            {-0.5000, -0.06250, -0.5000, 0.5000, 0.5000, -0.4375},
            {0.4375, -0.06250, -0.5000, 0.5000, 0.5000, 0.5000},
            {-0.5000, -0.06250, 0.4375, 0.5000, 0.5000, 0.5000},
            {-0.4375, -0.1875, -0.4375, 0.4375, -0.06250, -0.3750},
            {0.3750, -0.1875, -0.4375, 0.4375, -0.06250, 0.4375},
            {-0.4375, -0.1875, -0.4375, -0.3750, -0.06250, 0.4375},
            {-0.4375, -0.1875, 0.3750, 0.4375, -0.06250, 0.4375},
            {-0.3750, -0.2500, -0.3750, 0.3750, -0.1875, -0.3125},
            {-0.3750, -0.2500, 0.3125, 0.3750, -0.1875, 0.3750},
            {-0.3750, -0.2500, -0.3750, -0.3125, -0.1875, 0.3750},
            {0.3125, -0.2500, -0.3750, 0.3750, -0.1875, 0.3750},
            {-0.3125, -0.3125, -0.3125, 0.3125, -0.2500, 0.3125},
            {-0.5000, -0.5000, -0.5000, -0.3750, -0.4375, -0.3750},
            {-0.4375, -0.4375, -0.4375, -0.3125, -0.1875, -0.3125},
            {0.3750, -0.5000, -0.5000, 0.5000, -0.4375, -0.3750},
            {0.3125, -0.4375, -0.4375, 0.4375, -0.1875, -0.3125},
            {-0.5000, -0.5000, 0.3750, -0.3750, -0.4375, 0.5000},
            {-0.4375, -0.4375, 0.3125, -0.3125, -0.1875, 0.4375},
            {0.3750, -0.5000, 0.3750, 0.5000, -0.4375, 0.5000},
            {0.3125, -0.4375, 0.3125, 0.4375, -0.1875, 0.4375}
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5000, -0.06250, -0.5000, -0.4375, 0.5000, 0.5000},
            {-0.5000, -0.06250, -0.5000, 0.5000, 0.5000, -0.4375},
            {0.4375, -0.06250, -0.5000, 0.5000, 0.5000, 0.5000},
            {-0.5000, -0.06250, 0.4375, 0.5000, 0.5000, 0.5000},
            {-0.4375, -0.1875, -0.4375, 0.4375, -0.06250, -0.3750},
            {0.3750, -0.1875, -0.4375, 0.4375, -0.06250, 0.4375},
            {-0.4375, -0.1875, -0.4375, -0.3750, -0.06250, 0.4375},
            {-0.4375, -0.1875, 0.3750, 0.4375, -0.06250, 0.4375},
            {-0.3750, -0.2500, -0.3750, 0.3750, -0.1875, -0.3125},
            {-0.3750, -0.2500, 0.3125, 0.3750, -0.1875, 0.3750},
            {-0.3750, -0.2500, -0.3750, -0.3125, -0.1875, 0.3750},
            {0.3125, -0.2500, -0.3750, 0.3750, -0.1875, 0.3750},
            {-0.3125, -0.3125, -0.3125, 0.3125, -0.2500, 0.3125},
            {-0.5000, -0.5000, -0.5000, -0.3750, -0.4375, -0.3750},
            {-0.4375, -0.4375, -0.4375, -0.3125, -0.1875, -0.3125},
            {0.3750, -0.5000, -0.5000, 0.5000, -0.4375, -0.3750},
            {0.3125, -0.4375, -0.4375, 0.4375, -0.1875, -0.3125},
            {-0.5000, -0.5000, 0.3750, -0.3750, -0.4375, 0.5000},
            {-0.4375, -0.4375, 0.3125, -0.3125, -0.1875, 0.4375},
            {0.3750, -0.5000, 0.3750, 0.5000, -0.4375, 0.5000},
            {0.3125, -0.4375, 0.3125, 0.4375, -0.1875, 0.4375}
        }
    },
})