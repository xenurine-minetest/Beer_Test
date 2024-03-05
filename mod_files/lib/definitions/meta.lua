---@class MetaDataRef
MetaDataRef = {}

---comment
---@param key string
---@return number
function MetaDataRef:get_int(key) end

---comment
---@param key string
---@param value number
function MetaDataRef:set_int(key, value) end

---comment
---@param key string
---@param value string
function MetaDataRef:set_string(key, value) end

---get inventory
---@return Inventory
function MetaDataRef:get_inventory() end

---@class Position
---@field x number
---@field y number
---@field z number