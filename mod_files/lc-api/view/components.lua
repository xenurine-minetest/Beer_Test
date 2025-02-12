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

return {
    verticalBar = verticalBar
}