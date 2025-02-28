print('Loading lc_api')
print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee')
print('')
print('8     8""""8      8""""8 8""""8 8  ')
print('8     8    "      8    8 8    8 8  ')
print('8e    8e          8eeee8 8eeee8 8e ')
print('88    88     eeee 88   8 88     88 ')
print('88    88   e      88   8 88     88 ')
print('88eee 88eee8      88   8 88     88 ')
print('')

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
            ComponentModelHelper = lazyload(modulePath .. "/components/ModelHelper.lua"),
            Fillable = lazyload(modulePath .. "/components/models/FillableModel.lua"),
            Sealable = lazyload(modulePath .. "/components/models/SealableModel.lua"),
            CanSoak = lazyload(modulePath .. "/components/models/CanSoakModel.lua"),
        },
        EventSystem = lazyload(modulePath .. "/eventsystem.lua"),
        PropertyStorage = lazyload(modulePath .. "/propertystorage.lua"),
        
        View = {
            Components = lazyload(modulePath .. "/view/components.lua"),
            OpenedFormspecStorage = lazyload(modulePath .. "/view/openedformspecstorage.lua"),
        }
    },
    Registrations = {
        Fillable = lazyload(modulePath .. "/Registrators/LiquidContainerRegistrator.lua"),
        Recipes = lazyload(modulePath .. "/Registrators/RecipeRegistrator.lua"),
        Components = lazyload(modulePath .. "/Registrators/ComponentRegistrator.lua"),
        Items = lazyload(modulePath .. "/Registrators/ItemRegistrator.lua"),
    }
}

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

function table.override_table(t1, t2)
    for k,v in pairs(t2) do
        t1[k] = v
    end
end

print("lc_api: loading builtin liquid container components")
dofile(modulePath .. "/components/registrations/FillableRegistration.lua")
dofile(modulePath .. "/components/registrations/SealableRegistration.lua")
dofile(modulePath .. "/components/registrations/CanSoakRegistration.lua")

print("lc_api: initialize builtin liquid container components")
local ComponentRegistrator = lc_api.Registrations.Components()
ComponentRegistrator.initialize()

print("lc_api has loaded succesfully")