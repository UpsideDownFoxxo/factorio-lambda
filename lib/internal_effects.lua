---@module "lib/build_results"
local Built = require("__lambda-ui__/lib/build_results")
---@module "lib/ui_builder"
local Builder = require("__lambda-ui__/lib/ui_builder")
---@module "lib/utils"
local utils = require("__lambda-ui__/lib/utils")
---@module "lib/function_store"
local FunctionStore = require("__lambda-ui__/lib/function_store")

---@alias ArrayReplacedDescriptor {self:LuaGuiElement,player_index:number,deps:string[],old_table:table,new_table:table}

local function gen_swap_sequence(unordered_list)
	local sorted_indices = {}
	local indirections = {}

	local swaps = {}

	for key, value in pairs(unordered_list) do
		table.insert(sorted_indices, { key = key, value = value })
	end

	for i = 1, #sorted_indices do
		indirections[i] = i
	end

	table.sort(sorted_indices, function(a, b)
		return a.value < b.value
	end)

	for i = 1, #sorted_indices do
		local is = unordered_list[indirections[i]]
		local should = sorted_indices[i].value

		if is ~= should then
			table.insert(swaps, { i, indirections[sorted_indices[i].key] })
			utils.swap(indirections, i, indirections[sorted_indices[i].key])
		end
	end

	return swaps
end

---@param e ArrayReplacedDescriptor
Built.fns.array_replaced = function(e)
	local delta_in = {}

	local modified = {}

	local metadata = storage.reactive.dynamic.for_blocks[utils.get_ui_ident(e.self)]

	local get_key = FunctionStore.get(metadata.key) or function(el)
		return el
	end

	local old_by_key = {}
	for _, value in pairs(e.old_table) do
		old_by_key[get_key(value)] = value
	end

	local element_to_key = {}
	for key, value in pairs(metadata.children) do
		element_to_key[value.element.index] = key
	end

	local old_set = {}
	for _, value in pairs(e.self.children) do
		local key = element_to_key[value.index]
		old_set[key] = old_by_key[key]
		game.print("Found element for key " .. key)
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

	-- build map from element index to index in original table
	local key_to_index = {}
	for key, value in pairs(e.new_table) do
		key_to_index[get_key(value)] = key
	end

	local self = e.self
	local element_to_index = {}
	for key, value in pairs(metadata.children) do
		element_to_index[value.element.index] = key_to_index[key]
	end

	local ingame_child_order = {}
	for _, value in pairs(self.children) do
		table.insert(ingame_child_order, element_to_index[value.index])
	end

	local swaps = gen_swap_sequence(ingame_child_order)

	for _, swap in pairs(swaps) do
		self.swap_children(swap[1], swap[2])
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

Built.fns.cleanup_for = function(e)
	for _, dep in pairs(e.deps) do
		storage.reactive.effects[dep][e.key] = nil
	end

	storage.reactive.dynamic.for_blocks[e.key.ident] = nil
end

Built.fns.cleanup_ref = function(e)
	storage.reactive.refs[e.player_index][e.ref] = nil
end
