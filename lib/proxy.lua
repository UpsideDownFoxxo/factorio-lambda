local m = {}

---@class Proxy
---@field __data any
local Proxy = {}
Proxy.__index = function(table, key)
	game.print("read aceess on key " .. key)
	return table.__data[key]
end

Proxy.__newindex = function(table, key, value)
	game.print("write access on key " .. key)
	table.__data[key] = value
end

Proxy.__pairs = function(table)
	game.print("indexed table")
	local function iterator(t, k)
		local next_key, next_value = next(t, k)
		if next_key == nil then
			return nil
		end

		-- we want deep reactivity for nested objects
		if type(next_value) == "table" then
			next_value = m.wrap(next_value)
		end

		return next_key, next_value
	end

	return iterator, table.__data, nil
end

script.register_metatable("proxy_meta", Proxy)

---Wraps a table in a tracking proxy
---@generic T
---@param table T
---@return T
m.wrap = function(table)
	local self = {
		__data = table,
	}
	return setmetatable(self, Proxy)
end

return m
