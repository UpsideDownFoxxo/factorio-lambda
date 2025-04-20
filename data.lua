-- These are some style prototypes that the tutorial uses
-- You don't need to understand how these work to follow along
local styles = data.raw["gui-style"].default

styles["ugg_content_frame"] = {
	type = "frame_style",
	parent = "inside_shallow_frame_with_padding",
	vertically_stretchable = "on",
}

styles["ugg_controls_flow"] = {
	type = "horizontal_flow_style",
	vertical_align = "center",
	horizontal_spacing = 16,
}

styles["ugg_controls_textfield"] = {
	type = "textbox_style",
	width = 36,
}

styles["ugg_deep_frame"] = {
	type = "frame_style",
	parent = "slot_button_deep_frame",
	vertically_stretchable = "on",
	horizontally_stretchable = "on",
	top_margin = 16,
	left_margin = 8,
	right_margin = 8,
	bottom_margin = 4,
}

styles["ugg_header_flow"] = {
	type = "horizontal_flow_style",
	parent = "frame_header_flow",
	vertically_stretchable = "off",
}

styles["ugg_header_title"] = {
	type = "label_style",
	parent = "frame_title",
	vertically_stretchable = "on",
	horizontally_squashable = "on",
	top_margin = -3,
	bottom_padding = 3,
}

styles["ugg_draggable_header"] = {
	type = "empty_widget_style",
	parent = "draggable_space_header",
	right_margin = 4,
	horizontally_stretchable = "on",
	vertically_stretchable = "off",
	height = 24,
	natural_height = 24,
}

data:extend({
	{
		type = "custom-input",
		name = "ugg_toggle_interface",
		key_sequence = "CONTROL + I",
		order = "a",
	},
})
