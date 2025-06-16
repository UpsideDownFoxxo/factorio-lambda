require("util")
require("__reactive-gui__/lib/interfaces")
require("__reactive-gui__/lib/internal_effects")
local Builder = require("__reactive-gui__/lib/ui_builder")
local example = require("__reactive-gui__/lib/ui_example")
local PlayerScope = require("__reactive-gui__/lib/player_scope")

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
			---@type table<any,table<string,EventHandlerDescriptor>>
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
