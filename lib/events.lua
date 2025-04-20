local m = {}

m.register_click = function(func, key)
	if not m.events then
		script.on_event(defines.events.on_gui_click, function(e)
			local f = m.events[e.element.name]
			if f then
				storage.p = storage.reactive.player_scopes[e.player_index]
				f(e)
				storage.p = nil
			end
		end)
		m.events = {}
	end

	m.events[key] = func
end

return m
