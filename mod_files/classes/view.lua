local View = {}

View.createView = function(viewModel, formSpec)
    local data = viewModel.getData()
    local value = minetest.formspec_escape(data.liquidLevel)
    local formSpec = formSpec(value)

    minetest.register_on_player_receive_fields(function(player, formname, fields)
        if formname == "mymod:example" then
            viewModel.handleInput(fields)
        end
    end)

    minetest.show_formspec(viewModel.getPlayerName(), "mymod:example", formSpec)
end


return View