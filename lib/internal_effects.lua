local Built = require("lib/build_results")
local Builder = require("lib/ui_builder")
---@alias ArrayReplacedDescriptor {self:LuaGuiElement,player_index:number,deps:string[],old_table:table,new_table:table}
---@param e ArrayReplacedDescriptor
local function array_replaced(e)
	local delta_in = {}
	local delta_out = {}

	local stayed = {}

	local old_set = {}
	for _, value in pairs(e.old_table) do
		old_set[value] = true
	end

	for _, value in pairs(e.new_table) do
		if old_set[value] then
			table.insert(stayed, value)
			old_set[value] = nil
		else
			table.insert(delta_in, value)
		end
	end

	for value, _ in pairs(old_set) do
		table.insert(delta_out, value)
	end

	local metadata = storage.reactive.dynamic.for_blocks[e.self]

	for _, value in pairs(delta_out) do
		metadata.child_keys[value].destroy()
		metadata.child_keys[value] = nil
	end

	for _, value in pairs(delta_in) do
		local el = Builder.build_parametrized(metadata.markup, e.self, value)
		metadata.child_keys[value] = el
	end
end

Built.effect_fns[1] = array_replaced
