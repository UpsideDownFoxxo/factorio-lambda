require("util")
local Proxy = require("lib/proxy")
local Builder = require("lib/ui_builder")
local example = require("lib/ui_example")
local PlayerScope = require("lib/player_scope")

Builder.register(example)

script.on_init(function()
	storage.reactive = {
		refs = {},
		proxy_cache = {},
		player_scopes = {},
		effects = {},
	}

	storage.g = Proxy.wrap({ controls_active = false, e = {} }, "g")
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

remote.add_interface("reactive", {
	flip = function(player_index)
		storage.reactive.player_scopes[player_index].controls_active =
			not storage.reactive.player_scopes[player_index].controls_active
	end,
})
