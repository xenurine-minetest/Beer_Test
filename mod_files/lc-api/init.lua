local modulePath = minetest.get_modpath("beer_test").."/mod_files/lc-api"

local function lazyload(file_path)
    local cache = nil
    return function()
        if not cache then
            cache = dofile(file_path)
        end
        return cache
    end
end

lc_api = {
    modules = {
        Components = {
            Fillable = lazyload(modulePath .. "/components/fillable.lua"),
            Sealable = lazyload(modulePath .. "/components/sealable.lua")
        },
        EventSystem = lazyload(modulePath .. "/eventsystem.lua"),
        PropertyStorage = lazyload(modulePath .. "/propertystorage.lua"),
        OpenedFormspecStorage = lazyload(modulePath .. "/cache/openedformspeccache.lua"),
        View = {
            Components = lazyload(modulePath .. "/view/components.lua")
        }
    },
    register = {
        Fillable = lazyload(modulePath .. "/registerfillable.lua"),
        Recipes = lazyload(modulePath .. "/registerrecipes.lua"),
    }
}