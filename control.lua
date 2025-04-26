require("util")
require("lib/interfaces")
require("lib/internal_effects")
local Builder = require("lib/ui_builder")
local example = require("lib/ui_example")
local PlayerScope = require("lib/player_scope")

Builder.register(example)

script.on_init(function()
	storage.reactive = {
		refs = {},
		proxy_cache = {},
		proxy_id = 1,
		player_scopes = {},
		---@type table<string,table<EffectDescriptor,true>>
		effects = {},
		---@type table<number,EffectDescriptor[]>
		effect_clean = {},
		dynamic = {
			---@type table<LuaGuiElement,ForBlockMetadata>
			for_blocks = {},
		},
	}
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if not player then
		return
	end

	PlayerScope.add_player_scope(event.player_index)

	local screen_element = player.gui.screen

	Builder.build(example, screen_element)
end)
