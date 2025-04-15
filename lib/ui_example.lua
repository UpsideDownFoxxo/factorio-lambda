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
	type = "frame",
	name = "ugg_main_frame",
	caption = { "ugg.hello_world" },
	_inlinestyle = { size = { 385, 165 } },
	auto_center = true,
	{
		type = "frame",
		name = "content_frame",
		direction = "vertical",
		style = "ugg_content_frame",
		{
			type = "flow",
			name = "controls_flow",
			direction = "horizontal",
			style = "ugg_controls_flow",
			{
				type = "button",
				name = "ugg_controls_toggle",
				caption = { "ugg.deactivate" },
				_click = function(event)
					local player_storage = storage.players[event.player_index]
					player_storage.controls_active = not player_storage.controls_active

					local control_toggle = event.element
					control_toggle.caption = player_storage.controls_active and { "ugg.deactivate" }
						or { "ugg.activate" }

					local slider = ref("slider", event)
					if slider then
						slider.enabled = player_storage.controls_active
					end

					local text = ref("text", event)
					if text then
						text.enabled = player_storage.controls_active
					end
				end,
			},
			{
				type = "slider",
				name = "ugg_controls_slider",
				value = 0,
				minimum_value = 0,
				maximum_value = #item_sprites,
				style = "notched_slider",
				_ref = "slider",
			},
			{
				type = "textfield",
				name = "ugg_controls_textfield",
				text = "0",
				numeric = true,
				allow_decimal = false,
				allow_negative = false,
				style = "ugg_controls_textfield",
				_ref = "text",
			},
		},
	},
}

return ex
