local storageComponents = {}

---@alias ComponentRegistration.registerStorageComponents fun(definition: table): nil
local function registerStorageComponents(definition)
    table.insert(storageComponents, definition)
end

---@alias ComponentRegistration.getStorageComponents fun(): table
local function getStorageComponents()
    return storageComponents
end

---@class ComponentRegistration
---@field registerStorageComponents ComponentRegistration.registerStorageComponents
---@field getStorageComponents ComponentRegistration.getStorageComponents
return {
    registerStorageComponents = registerStorageComponents,
    getStorageComponents = getStorageComponents
}