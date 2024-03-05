---@class Minetest
minetest = {}

---returns the currently loading mod's name, when loading a mod.
---@return string
function minetest.get_current_modname() end

---returns the directory path for a mod, e.g. "/home/user/.minetest/usermods/modname".
---@param modname string
---@return string|nil modPath
function minetest.get_modpath(modname) end

---returns a list of enabled mods, sorted alphabetically.
---@return string[] 
function minetest.get_modnames() end

---returns a table containing information about the current game
---@return table
function minetest.get_game_info() end

---returns e.g. "/home/user/.minetest/world"
---@return string worldPath
function minetest.get_worldpath() end

---@return boolean is single player
function minetest.is_singleplayer() end







---comment
---@param pos Position
---@return MetaDataRef
function minetest.get_meta(pos) end

