---@module "lib/proxy"
local Proxy = require("__lambda-ui__/lib/proxy")
local m = {}

local t = { "help" }
m.default_player_scope = { controls_active = false, icon_num = 0, a = { b = t, c = t }, c = t }

---Run a function within a player's scope
---@param player_index number
---@param f function
m.run = function(player_index, f)
	local previous = storage.p
	storage.p = storage.reactive.player_scopes[player_index]
	f()
	storage.p = previous
end

m.add_player_scope = function(player_index)
	storage.reactive.player_scopes[player_index] = Proxy.wrap(table.deepcopy(m.default_player_scope), "p", player_index)
end

return m
