local Built = require("lib/build_results")
local Builder = require("lib/ui_builder")
local utils = require("lib.utils")
local FunctionStore = require("lib/function_store")
---@alias ArrayReplacedDescriptor {self:LuaGuiElement,player_index:number,deps:string[],old_table:table,new_table:table}
---@param e ArrayReplacedDescriptor
Built.fns.array_replaced = function(e)
	local delta_in = {}

	local stayed = {}

	local metadata = storage.reactive.dynamic.for_blocks[utils.get_ui_ident(e.self)]

	local get_key = FunctionStore.get(metadata.key) or function(el)
		return el
	end

	local old_set = {}
	for _, value in pairs(e.old_table) do
		old_set[get_key(value)] = true
	end

	for _, value in pairs(e.new_table) do
		local key = get_key(value)
		if old_set[key] then
			table.insert(stayed, value)
			old_set[key] = nil
		else
			table.insert(delta_in, value)
		end
	end

	for value, _ in pairs(old_set) do
		metadata.child_keys[value].destroy()
		metadata.child_keys[value] = nil
	end

	for _, value in pairs(delta_in) do
		local el = Builder.build_parametrized(metadata.markup, e.self, value)
		metadata.child_keys[get_key(value)] = el
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
