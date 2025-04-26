local Built = require("lib/build_results.lua")
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

	game.print("+" .. serpent.line(delta_in))
	game.print("-" .. serpent.line(delta_out))
	game.print("=" .. serpent.line(stayed))
end

Built.effect_fns[1] = array_replaced
