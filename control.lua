local Proxy = require("lib/proxy")
local Builder = require("lib/ui_builder")
local example = require("lib/ui_example")

Builder.register(example)

script.on_init(function()
	storage.players = {}
	storage.events = {}
	storage.refs = {}
	storage.proxy_cache = {}
	storage.p = Proxy.wrap({ controls_active = false }, "p")
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

-- script.on_event(defines.events.on_gui_click, function(event)
-- 	if event.element.name == "ugg_controls_toggle" then
-- 		local player_storage = storage.players[event.player_index]
-- 		player_storage.controls_active = not player_storage.controls_active
--
-- 		local control_toggle = event.element
-- 		control_toggle.caption = player_storage.controls_active and { "ugg.deactivate" } or { "ugg.activate" }
-- 	end
-- end)

remote.add_interface("human interactor", {
	flip = function()
		storage.p.b = nil
	end,
	bye = function(name)
		game.player.print("Bye " .. name)
	end,
})
