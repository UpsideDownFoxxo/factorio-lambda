local Proxy = require("lib/proxy")
local Builder = require("lib/ui_builder")
local example = require("lib/ui_example")

Builder.register(example)

script.on_init(function()
	storage.players = {}
	storage.events = {}
	storage.refs = {}
	storage.proxy_cache = {}
	storage.g = Proxy.wrap({ controls_active = false }, "g")
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if not player then
		return
	end

	local screen_element = player.gui.screen

	Builder.build(example, screen_element)

	storage.players[player.index] = { controls_active = true }
end)
