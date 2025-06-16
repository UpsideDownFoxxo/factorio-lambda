local Build = require("__reactive-gui__/lib/build_results")
local m = {}

--- Used to maintain references to functions across save/load cycles
--- IDs below 1k are reserved for internal use
local func_id = 1000

m.link = function(f)
	assert(not game, "Linked functions should only be registered during startup")
	Build.fns[func_id] = f
	func_id = func_id + 1
	return func_id - 1
end

m.call = function(link_id, params)
	local f = Build.fns[link_id]
	return f(table.unpack(params))
end

m.get = function(link_id)
	return Build.fns[link_id]
end

return m
