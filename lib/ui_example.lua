---@module "lib/ui_builder"
local Builder = require("__reactive-gui__/lib/ui_builder")
local ref = Builder.ref

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

for k, v in pairs(item_sprites) do
	---@type {sprite:string,toggled:boolean}
	item_sprites[k] = { sprite = v, toggled = false }
end

---@cast item_sprites {sprite:string,toggled:boolean}

---@type Element
local example = {
	props = { "frame", "ugg_main_frame", auto_center = true, direction = "vertical" },
	_inlinestyle = { size = { 385, 165 } },

	{
		props = { "flow", direction = "horizontal", style = "ugg_header_flow" },
		{
			props = { "label", style = "ugg_header_title", caption = { "ugg.hello_world" } },
		},
		{
			props = { "empty-widget", style = "ugg_draggable_header", drag_target = "ugg_main_frame" },
		},

		{
			props = { "sprite-button", "close-button", sprite = "utility/close", style = "close_button" },
			_click = function(e)
				ref("ugg_main_frame", e).destroy()
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
						ref("ugg_controls_toggle", e).caption = storage.p.controls_active and { "ugg.deactivate" }
							or { "ugg.activate" }

						ref("ugg_controls_slider", e).enabled = storage.p.controls_active or false
						ref("ugg_controls_textfield", e).enabled = storage.p.controls_active or false
					end,
					{ "p.controls_active" },
				},
				{
					function(e)
						ref("ugg_controls_textfield", e).text = tostring(storage.p.icon_num)
						ref("ugg_controls_slider", e).slider_value = storage.p.icon_num

						local t = {}
						for i = 1, storage.p.icon_num do
							t[item_sprites[i].sprite] = item_sprites[i]
						end
						storage.p.icons = t
					end,
					{ "p.icon_num" },
				},
			},
			{
				props = { "button", "ugg_controls_toggle", caption = { "ugg.deactivate" } },
				_click = function()
					storage.p.controls_active = not storage.p.controls_active
				end,
			},
			{
        --stylua: ignore
        props = {"slider","ugg_controls_slider",value=0,minimum_value=0,maximum_value=#item_sprites,style="notched_slider"},
				_value_changed = function(e)
					storage.p.icon_num = e.element.slider_value
				end,
			},
			{
        --stylua: ignore
        props = {"textfield","ugg_controls_textfield",text="0",numeric=true,allow_decimal=false,allow_negative=false,style="ugg_controls_textfield"},
				_text_changed = function(e)
					storage.p.icon_num = tonumber(e.element.text) or 0
				end,
			},
		},
		{
			props = { "frame", "button_frame", direction = "horizontal", style = "ugg_deep_frame" },
			{
				props = { "table", "button_table", column_count = #item_sprites, style = "filter_slot_table" },
				_for = {
					"p.icons",
					key = function(a)
						return a.sprite
					end,
				},
				{
					props = function(entry)
						local str = entry.sprite
						return {
							"sprite-button",
							"button_" .. str,
							sprite = "item/" .. str,
							style = "slot_button",
							toggled = entry.toggled,
						}
					end,
					_click = function(e)
						e.params.toggled = not e.params.toggled
					end,
					_effects = {
						{
							function(e)
								e.self.toggled = e.params.toggled
							end,
							function(p)
								return { "p.icons." .. p.sprite .. ".toggled" }
							end,
						},
					},
				},
			},
		},
	},
}

return example
