local modPath = minetest.get_modpath(minetest.get_current_modname()) .. "/mod_files"
local InfiniteLoop = dofile(modPath .. "/lib/infinite_loop.lua")

local PlayerEffects = {}

PlayerEffects.formSpecs = {
    default = function ()
        return table.concat({
            "formspec_version[8]",
            "size[10,10]",
            "position[0.5,0.5]",
            "padding[0.1,0.1]",
            "button[0,1;2,1;one;Effect 1]",
            "button[0,2;2,1;two;Effect 2]",
            "button[0,3;2,1;three;Effect 3]",
        },"")
    end
}

PlayerEffects.registerReceive = function (player, formname, fields)
    if (formname ~= "beer_test:player_effects") then
        return
    end

    if (fields.quit == "true") then
        return
    end

    if (fields.one ~= nil) then
        InfiniteLoop.new(function()
            PlayerEffects.effects.one(player)
        end, function()
            PlayerEffects.effects.oneRedo(player)
        end).start(0.1, 0).stopAfter(10)
    end

    if (fields.two ~= nil) then
        InfiniteLoop.new(function()
            PlayerEffects.effects.two(player)
        end, function()
            PlayerEffects.effects.twoRedo(player)
        end).start(0.2, 0).stopAfter(10)
    end

    if (fields.three ~= nil) then
        InfiniteLoop.new(function()
            PlayerEffects.effects.three(player)
        end, function()
            PlayerEffects.effects.threeRedo(player)
        end).start(1, 0).stopAfter(10)
    end
end

PlayerEffects.effects = {
    one = function(player)
        minetest.chat_send_player(player:get_player_name(), "Hicks!")
        local physics = player.get_physics_override(player)
        physics.speed = 1 * math.random(1, 10)/5
        physics.acceleration_default = 1 * math.random(1, 10)/5
        player.set_physics_override(player, physics)
    end,
    oneRedo = function(player)
        minetest.chat_send_player(player:get_player_name(), "I'm sober again!")
        local physics = player.get_physics_override(player)
        physics.speed = 1
        physics.acceleration_default = 1
        player.set_physics_override(player, physics)
    end,
    two = function (player)
        local isPlus = function()
            local random = math.random()
            return random >= 0.5
        end

        local random = 0.01/(2*math.pi) --math.random(1,1)
        local yaw = player.get_look_horizontal(player)
        minetest.log("action", "yaw: "..yaw)

        if (isPlus()) then
            yaw = yaw + random
        else
            yaw = yaw - random
        end

        --[[if (yaw >= 360) then
            yaw = yaw - 360
        end

        if (yaw > 0) then
            yaw = yaw + 350
        end--]]
        
        player.set_look_horizontal(player, yaw)
    end,
    three = function (player)
        local fov = player.get_fov(player)
        minetest.log("action", "fov: "..fov)
        player.set_fov(player, 2, true, 0.1)
    end,
    threeRedo = function(player)
        player.set_fov(player, 0, false, 0.5)
    end
}

minetest.register_on_player_receive_fields(PlayerEffects.registerReceive)


minetest.register_chatcommand("playerEffects", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        minetest.show_formspec(name, "beer_test:player_effects", PlayerEffects.formSpecs.default())
    end
})