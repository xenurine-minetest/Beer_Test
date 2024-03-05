---@class Inventory
Inventory = {}

---comment
---@param listName string
function Inventory:get_list(listName) end


---@class ItemStack
ItemStack = {}

---returns true if stack is empty.
---@return boolean
function ItemStack.is_empty() end

---returns item name (e.g. "default:stone").
---@return string
function ItemStack.get_name() end

---returns a boolean indicating whether the item was cleared.
---@return boolean
function ItemStack.set_name(item_name) end

---Returns number of items on the stack.
---@return number
function ItemStack.get_count() end

---returns a boolean indicating whether the item was cleared
---@param count number unsigned 16 bit integer
function ItemStack.set_count(count) end

---returns tool wear (0-65535), 0 for non-tools.
---@return number
function ItemStack.get_wear() end

---@param wear number @unsigned 16 bit integer
---@return boolean
---returns boolean indicating whether item was cleared
function ItemStack.set_wear(wear) end

---returns ItemStackMetaRef. See section for more details
function ItemStack.get_meta() end
function ItemStack.get_description() end
function ItemStack.get_short_description() end
function ItemStack.clear() end
function ItemStack.replace(item) end
function ItemStack.to_string() end
function ItemStack.to_table() end
function ItemStack.get_stack_max() end
function ItemStack.get_free_space() end
function ItemStack.is_known() end
function ItemStack.get_definition() end
function ItemStack.get_tool_capabilities() end
function ItemStack.add_wear(amount) end
function ItemStack.add_wear_by_uses(max_uses) end
function ItemStack.get_wear_bar_params() end
function ItemStack.add_item(item) end
function ItemStack.item_fits(item) end
function ItemStack.take_item(n) end
function ItemStack.peek_item(n) end
function ItemStack.equals(other) end