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
		mappings = {
			reg_to_ui_idents = {},
		},
		player_scopes = {},
		---@type table<string,table<ComponentFunctionDescriptor,true>>
		effects = {},
		---@type table<number,ComponentFunctionDescriptor[]>
		cleanup = {},
		dynamic = {
			---@type table<string,ForBlockMetadata>
			for_blocks = {},
			---@type table<any,table<string,number>>
			handlers = {},
		},
	}
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if not player then
		return
	end

	PlayerScope.add_player_scope(event.player_index)

	Builder.build(example, player.gui.screen)
end)
