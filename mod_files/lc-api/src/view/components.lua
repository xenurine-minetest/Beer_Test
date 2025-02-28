---@alias ComponenViewComponents.verticalBar fun(x: number, y: number, width: number, height:number, percent:number, texture:string): string
local function verticalBar (x, y, width, height, percent, texture)
    local backGround = "image["..x..","..y..";"..width..","..height..";beer_test_bar_empty.png]"
    local foreGround = ""

    if (percent > 0 ) then
        local heightP = height/100*percent
        local yP = height - heightP +y

        foreGround = "image["..x..","..yP..";"..width..","..heightP..";" .. texture .. "]"
    end

    return backGround .. foreGround
end

local function soakVerticalBar (x, y, width, height, input, liquid, output)
    local backGround = "image["..x..","..y..";"..width..","..height..";beer_test_bar_empty.png]"
    local inputForeGround = ""
    local liquidForeGround = ""
    local outputForeGround = ""

    local lastHeight = 0
    if (output.percent > 0 ) then
        local heightP = height/100*output.percent
        local yP = height - heightP +y

        outputForeGround = "image["..(x)..","..yP..";"..width..","..heightP..";" .. output.texture .. "]"
        lastHeight = heightP
    end
    
    if (liquid.percent > 0 ) then
        local heightP = height/100*liquid.percent
        local yP = height - heightP +y

        liquidForeGround = "image["..x..","..(yP-lastHeight)..";"..width..","..heightP..";" .. liquid.texture .. "]"
        lastHeight = lastHeight+heightP
    end
    
    if (input.percent > 0 ) then
        local heightP = height/100*input.percent
        local yP = height - heightP +y

        inputForeGround = "image["..(x)..","..(yP-lastHeight)..";"..width..","..heightP..";" .. input.texture .. "]"
    end

    return backGround .. inputForeGround .. liquidForeGround ..  outputForeGround
end

--- @class ViewComponents
--- @field verticalBar ComponenViewComponents.verticalBar
return {
    verticalBar = verticalBar,
    soakVerticalBar = soakVerticalBar
}