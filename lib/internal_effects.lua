local Built = require("__reactive-gui__/lib/build_results")
local Builder = require("__reactive-gui__/lib/ui_builder")
local utils = require("__reactive-gui__/lib/utils")
local FunctionStore = require("__reactive-gui__/lib/function_store")

---@alias ArrayReplacedDescriptor {self:LuaGuiElement,player_index:number,deps:string[],old_table:table,new_table:table}

---@param e ArrayReplacedDescriptor
Built.fns.array_replaced = function(e)
	local delta_in = {}

	local modified = {}

	local metadata = storage.reactive.dynamic.for_blocks[utils.get_ui_ident(e.self)]

	local get_key = FunctionStore.get(metadata.key) or function(el)
		return el
	end

	local old_set = {}
	for _, value in pairs(e.old_table) do
		old_set[get_key(value)] = value
	end

	for _, value in pairs(e.new_table) do
		local key = get_key(value)
		if old_set[key] then
			-- the element already existed but was modified, we need to update the param in all the effects
			if old_set[key] ~= value then
				table.insert(modified, value)
			end
			old_set[key] = nil
		else
			-- element doesn't exist, create a new one
			table.insert(delta_in, value)
		end
	end

	for value, _ in pairs(old_set) do
		metadata.children[value].element.destroy()
		metadata.children[value] = nil
	end

	for _, value in pairs(modified) do
		local effects = metadata.children[get_key(value)].effects
		for _, effect in pairs(effects) do
			if effect.params then
				effect.params = value
			end
		end

		local handlers = metadata.children[get_key(value)].handlers
		for _, handler in pairs(handlers) do
			if handler.params then
				handler.params = value
			end
		end
	end

	for _, value in pairs(delta_in) do
		local el, effects, handlers = Builder.build(metadata.markup, e.self, value)
		metadata.children[get_key(value)] = { element = el, effects = effects, handlers = handlers }
	end
end

Built.fns.cleanup_handler = function(e)
	storage.reactive.dynamic.handlers[e.event][e.self] = nil
end

Built.fns.cleanup_effect = function(e)
	for _, dep in pairs(e.deps) do
		storage.reactive.effects[dep][e.key] = nil
	end
end

Built.fns.cleanup_ref = function(e)
	storage.reactive.refs[e.player_index][e.ref] = nil
end
