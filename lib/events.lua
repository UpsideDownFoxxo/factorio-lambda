script.on_event(defines.events.on_object_destroyed, function(e)
	local effects = storage.reactive.effect_clean[e.registration_number]
	if effects then
		for _, effect in pairs(effects) do
			for _, dep in pairs(effect.deps) do
				storage.reactive.effects[dep][effect] = nil
			end
		end
	end
end)

local m = { events = {} }

m.register_click = function(func, key)
	if not m.events.click then
		script.on_event(defines.events.on_gui_click, function(e)
			local f = m.events.click[e.element.name]
			if f then
				storage.p = storage.reactive.player_scopes[e.player_index]
				f(e)
				storage.p = nil
			end
		end)
		m.events.click = {}
	end

	m.events.click[key] = func
end

m.register_value_changed = function(func, key)
	if not m.events.value_changed then
		script.on_event(defines.events.on_gui_value_changed, function(e)
			local f = m.events.value_changed[e.element.name]
			if f then
				storage.p = storage.reactive.player_scopes[e.player_index]
				f(e)
				storage.p = nil
			end
		end)
		m.events.value_changed = {}
	end

	m.events.value_changed[key] = func
end

m.register_text_changed = function(func, key)
	if not m.events.text_changed then
		script.on_event(defines.events.on_gui_text_changed, function(e)
			local f = m.events.text_changed[e.element.name]
			if f then
				storage.p = storage.reactive.player_scopes[e.player_index]
				f(e)
				storage.p = nil
			end
		end)
		m.events.text_changed = {}
	end

	m.events.text_changed[key] = func
end

return m
