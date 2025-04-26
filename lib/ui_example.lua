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

local example = {
	props = { "frame", "ugg_main_frame", auto_center = true, direction = "vertical" },
	_inlinestyle = { size = { 385, 165 } },
	_ref = "frame",

	{
		props = { "flow", direction = "horizontal", style = "ugg_header_flow" },
		{
			props = { "label", style = "ugg_header_title", caption = { "ugg.hello_world" } },
		},
		{
			props = { "empty-widget", style = "ugg_draggable_header", drag_target = "frame" },
		},

		{
			props = { "sprite-button", "close-button", sprite = "utility/close", style = "close_button" },
			_click = function(e)
				ref("frame", e).destroy()
			end,
		},
	},

	{
		props = { "frame", "content_frame", direction = "vertical", style = "ugg_content_frame" },
		{
			props = { "flow", "controls_flow", direction = "horizontal", style = "ugg_controls_flow" },
			_effects = {
				{
					function(e)
						ref("button", e).caption = storage.p.controls_active and { "ugg.deactivate" }
							or { "ugg.activate" }

						ref("slider", e).enabled = storage.p.controls_active or false
						ref("textfield", e).enabled = storage.p.controls_active or false
					end,
					{ "p.controls_active" },
				},
				{
					function(e)
						ref("textfield", e).text = tostring(storage.p.icon_num)
						ref("slider", e).slider_value = storage.p.icon_num

						local t = {}
						for i = 1, storage.p.icon_num do
							table.insert(t, item_sprites[i])
						end
						storage.p.icons = t
					end,
					{ "p.icon_num" },
				},
			},
			{
				props = { "button", "ugg_controls_toggle", caption = { "ugg.deactivate" } },
				_ref = "button",
				_click = function()
					storage.p.controls_active = not storage.p.controls_active
				end,
			},
			{
        --stylua: ignore
        props = {"slider","ugg_controls_slider",value=0,minimum_value=0,maximum_value=#item_sprites,style="notched_slider"},
				_ref = "slider",
				_value_changed = function(e)
					storage.p.icon_num = e.element.slider_value
					game.print(e.element.slider_value)
				end,
			},
			{
        --stylua: ignore
        props = {"textfield","ugg_controls_textfield",text="0",numeric=true,allow_decimal=false,allow_negative=false,style="ugg_controls_textfield"},
				_ref = "textfield",
				_text_changed = function(e)
					storage.p.icon_num = tonumber(e.element.text) or 0
				end,
			},
		},
		{
			props = { "frame", "button_frame", direction = "horizontal", style = "ugg_deep_frame" },
			{
				props = { "table", "button_table", column_count = #item_sprites, style = "filter_slot_table" },
				-- {
				-- 	_for = { "p.icons" },
				-- 	{ type = "sprite-button", sprite = "item/sulfur", style = "slot_button" },
				-- },
			},
		},
	},
}

return example
