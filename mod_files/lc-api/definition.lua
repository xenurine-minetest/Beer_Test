---@meta

--- @class LcApi
--- @field Registrations Api.Registrations
--- @field modules Api.modules

--- @class Api.Registrations
--- @field Fillable fun(): FillableRegistration
--- @field Recipes fun(): RecipeRegistration
--- @field Components fun(): ComponentRegistration

--- @class Api.modules
--- @field Components Api.modules.Components
--- @field View Api.modules.View
--- @field EventSystem fun(): EventSystem
--- @field PropertyStorage fun(): PropertyStorage

--- @class Api.modules.Components
--- @field Fillable fun(): Fillable
--- @field Sealable fun(): Sealable

--- @class Api.modules.View
--- @field Components fun(): ViewComponents
--- @field OpenedFormspecStorage fun(): OpenedFormspecStorage














--- Definitions

--- @class RecipeDefinition
--- @field type string mandatory, can be "soak"
--- @field input string mandatory, item name
--- @field liquidType string default=any
--- @field minLiquidRatio number mandatory
--- @field inputVolume number default=0
--- @field consumesLiquid number default=0
--- @field processTime number default=0

--- @class FillableDefinition
--- @field description string
--- @field paramtype string
--- @field paramtype2 string
--- @field sounds table
--- @field use_texture_alpha string
--- @field on_punch function|nil
--- @field on_construct function|nil
--- @field on_rightclick function|nil
--- @field selection_box? table
--- @field variants table
--- @field maxCapacity? number
--- @field sealable boolean
--- @field inventories table
--- @field formspec function
--- @field on_receive_fields function
