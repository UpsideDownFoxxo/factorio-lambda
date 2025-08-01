---@module "lib/function_store"
local FunctionStore = require("__lambda-ui__/lib/function_store")
---@module "lib/utils"
local utils = require("__lambda-ui__/lib/utils")
local m = { events = {} }

script.on_event(defines.events.on_object_destroyed, function(e)
	local effects = storage.reactive.cleanup[e.registration_number]
	if effects then
		for _, effect in pairs(effects) do
			FunctionStore.call(effect.fn, { effect })
		end
		storage.reactive.cleanup[e.registration_number] = nil
	end
end)

---Adds `func` to be run once `event` occurs. Works with all UI events that contain the `element` field
--- WARN: Calling script.on_event on these events will break the framework in a major way
---@param func function
---@return integer
m.register_event_handler = function(event, func)
	local id = FunctionStore.link(func)
	if not m.events[event] then
		---@param e {player_index:number,element:LuaGuiElement,params:any}
		script.on_event(event, function(e)
			local handler = (storage.reactive.dynamic.handlers[event] or {})[utils.get_ui_ident(e.element)]

			if handler then
				local tmp = storage.p
				storage.p = storage.reactive.player_scopes[e.player_index]
				e.params = handler.params
				FunctionStore.call(handler.fn, { e })
				storage.p = tmp
			end
		end)
		m.events[event] = true
	end

	return id
end

return m
