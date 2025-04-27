local creation_vars = (function()
	local t = {
		-- general
		"type",
		"name",
		"caption",
		"tooltip",
		"elem_tooltip",
		"enabled",
		"visible",
		"ignored_by_interaction",
		"style",
		"tags",
		"index",
		"anchor",
		"game_controller_interaction",

		-- frame/flow/line
		"direction",

		-- table
		"column_count",
		"draw_vertical_lines",
		"draw_horizontal_lines",
		"draw_horizontal_lines_after_headers",
		"vertical_centering",

		-- button
		"mouse_button_filter",
		"auto_toggle",
		"toggled",

		-- textfield
		"text",
		"numeric",
		"allow_decimal",
		"allow_negative",
		"is_password",
		"lose_focus_on_confirm",
		"icon_selector",

		-- progressbar
		"value",

		-- checkbox/radiobutton
		"state",

		-- sprite-button
		"sprite",
		"hovered_sprite",
		"clicked_sprite",
		"number",
		"show_percent_for_small_numbers",
		"mouse_button_filter",
		"auto_toggle",
		"toggled",

		-- sprite
		"sprite",
		"resize_to_sprite",

		-- scroll-pane
		"horizontal_scroll_policy",
		"vertical_scroll_policy",

		-- drop-down/list-box
		"items",
		"selected_index",

		-- camera
		"position",
		"surface_index",
		"zoom",

		-- choose-elem-button
		"elem_type",
		"item",
		"tile",
		"entity",
		"signal",
		"fluid",
		"recipe",
		"decorative",
		"item-group",
		"achievement",
		"technology",
		"item-with-quality",
		"entity-with-quality",
		"recipe-with-quality",
		"equipment-with-quality",
		"elem_filters",

		-- text box
		"text",
		"icon_selector",

		-- slider
		"minimum_value",
		"maximum_value",
		"value",
		"value_step",
		"discrete_values",

		-- minimap
		"position",
		"surface_index",
		"chart_player_index",
		"force",
		"zoom",

		-- tab
		"badge_text",

		-- switch
		"switch_state",
		"allow_none_state",
		"left_label_caption",
		"left_label_tooltip",
		"right_label_caption",
		"right_label_tooltip",
	}
	local tc = {}
	for _, v in pairs(t) do
		tc[v] = true
	end
	return tc
end)()

local ignore_vars = (function()
	local t = {
		"drag_target",
	}
	local tc = table.deepcopy(creation_vars)
	for _, v in pairs(t) do
		tc[v] = true
	end
	return tc
end)()

return { creation_vars, ignore_vars }
