local m = {}

m.register_click = function(func, key)
	if not m.events then
		script.on_event(defines.events.on_gui_click, function(e)
			local f = m.events[e.element.name]
			if f then
				f(e)
			end
		end)
		m.events = {}
	end

	m.events[key] = func
end

return m
