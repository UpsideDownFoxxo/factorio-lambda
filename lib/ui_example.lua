local ref = require("lib/ui_builder").ref

local item_sprites = {
	"inserter",
	"transport-belt",
	"stone-furnace",
	"assembling-machine-3",
	"storage-chest",
	"sulfur",
	"utility-science-pack",
	"laser-turret",
}

local ex = {
	props = { "frame", "ugg_main_frame", caption = { "ugg.hello_world" }, auto_center = true },
	_inlinestyle = { size = { 385, 165 } },

	{
		props = { "frame", "content_frame", direction = "vertical", style = "ugg_content_frame" },
		{
			props = { "flow", "controls_flow", direction = "horizontal", style = "ugg_controls_flow" },
			{
				props = { "button", "ugg_controls_toggle", caption = { "ugg.deactivate" } },
				_click = function()
					storage.p.controls_active = not storage.p.controls_active
					game.print(storage.p.controls_active)
				end,

				_effects = {
					{
						function(e)
							e.self.caption = storage.p.controls_active and { "ugg.deactivate" } or { "ugg.activate" }
						end,
						{ "p.controls_active" },
					},
				},
			},
			{
				props = {
					"slider",
					"ugg_controls_slider",
					value = 0,
					minimum_value = 0,
					maximum_value = #item_sprites,
					style = "notched_slider",
				},
				_effects = {
					{
						function(e)
							e.self.enabled = storage.p.controls_active
						end,
						{ "p.controls_active" },
					},
				},
			},
			{
				props = {
					"textfield",
					"ugg_controls_textfield",
					text = "0",
					numeric = true,
					allow_decimal = false,
					allow_negative = false,
					style = "ugg_controls_textfield",
				},
				_effects = {
					{
						function(e)
							e.self.enabled = storage.p.controls_active
						end,
						{ "p.controls_active" },
					},
				},
			},
		},
	},
}

return ex
