local modulePath = minetest.get_modpath("beer_test").."/mod_files/lc-api/src"

--- @generic T
--- @param file_path string
--- @return fun(): T
local function lazyload(file_path)
    local cache = nil
    return function()
        if not cache then
            cache = dofile(file_path)
        end
        return cache
    end
end

---@type LcApi
lc_api = {
    modules = {
        Components = {
            Fillable = lazyload(modulePath .. "/components/fillable.lua"),
            Sealable = lazyload(modulePath .. "/components/sealable.lua")
        },
        EventSystem = lazyload(modulePath .. "/eventsystem.lua"),
        PropertyStorage = lazyload(modulePath .. "/propertystorage.lua"),
        
        View = {
            Components = lazyload(modulePath .. "/view/components.lua"),
            OpenedFormspecStorage = lazyload(modulePath .. "/view/openedformspecstorage.lua"),
        }
    },
    Registrations = {
        Fillable = lazyload(modulePath .. "/registrations/registerfillable.lua"),
        Recipes = lazyload(modulePath .. "/registrations/registerrecipes.lua"),
        Components = lazyload(modulePath .. "/registrations/registercomponent.lua"),
    }
}
