local Environment = {}

---@param pos table<string, number>
---@return Environment
Environment.new = function(pos)
    ---@class Environment
    local self = {}

    local getNode, environmentTemperature

    environmentTemperature = 20

    ---@type fun(): number
    self.getEnvironmentTemperature = function ()
        return environmentTemperature
    end

    ---@type fun():ThermalData
    self.north = function ()
        local nodePos = {x = pos.x, y = pos.y, z = pos.z + 1}
        return getNode(nodePos)
    end

    ---@type fun():ThermalData
    self.south = function ()
        local nodePos = {x = pos.x, y = pos.y, z = pos.z - 1}
        return getNode(nodePos)
    end

    ---@type fun():ThermalData
    self.east = function ()
        local nodePos = {x = pos.x + 1, y = pos.y, z = pos.z}
        return getNode(nodePos)
    end

    ---@type fun():ThermalData
    self.west = function ()
        local nodePos = {x = pos.x - 1, y = pos.y, z = pos.z}
        return getNode(nodePos)
    end

    ---@type fun():ThermalData
    self.top = function ()
        local nodePos = {x = pos.x, y = pos.y + 1, z = pos.z}
        return getNode(nodePos)
    end

    ---@type fun():ThermalData
    self.bottom = function ()
        local nodePos = {x = pos.x, y = pos.y - 1, z = pos.z}
        return getNode(nodePos)
    end

    ---@type fun():ThermalData
    getNode = function (nodePos)
        local nodeName = minetest.get_node(nodePos).name
        if (minetest.get_item_group(nodeName, "fire") ~= 0) then
            return {uValue = 10, temperature = 1200}
        elseif (minetest.get_item_group(nodeName, "soil") ~= 0) then
            return {uValue = 2, temperature = environmentTemperature}
        elseif (minetest.get_item_group(nodeName, "wood") ~= 0) then
            return {uValue = 1, temperature = environmentTemperature}
        elseif (minetest.get_item_group(nodeName, "wool") ~= 0) then
            return {uValue = 0.5, temperature = environmentTemperature}
        elseif (nodeName == "default:air") then
            return {uValue = 5, temperature = environmentTemperature}
        end

        return {uValue = 5, temperature = environmentTemperature}
    end

    return self
end

return Environment