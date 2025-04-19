local Built = require("lib/ui_builder")

local m = {}

---@type table<table,Proxy>

---@param data table
---@return Proxy
local function get_proxy(data)
	return storage.proxy_cache[data] or m.wrap(data)
end

---Resolves a proxy to all possible paths
---@param proxy Proxy
---@return string[]
local function get_proxy_path(proxy)
	local parents = proxy.__parents
	for _, _ in pairs(parents) do
		goto c
	end

	do
		return { proxy.__root or "" }
	end

	::c::

	local results = {}

	for parent, key in pairs(parents) do
		local parent_paths = get_proxy_path(parent)
		for _, v in pairs(parent_paths) do
			for k, _ in pairs(key) do
				table.insert(results, (v == "" and v or (v .. ".")) .. k)
			end
		end
	end
	return results
end

---@class Proxy
---@field __data any
---@field __parents table<Proxy,table<string,boolean>>
---@field __root string|nil

local Proxy = {}

Proxy.__index = function(table, key)
	game.print("read aceess on key " .. key)
	local value = table.__data[key]
	if type(value) == "table" then
		local proxy = get_proxy(value)

		if not proxy.__parents[table] then
			proxy.__parents[table] = { [key] = true }
		elseif not proxy.__parents[table][key] then
			proxy.__parents[table][key] = true
		end

		return proxy
	end
	return value
end

Proxy.__newindex = function(table, key, value)
	-- table has been replaced, remove parent/child relationship
	if type(table.__data[key]) == "table" then
		local p = get_proxy(table.__data[key])
		p.__parents[table][key] = nil
	end

	if type(value) == "table" and value.__data then
		-- if we are passed a proxy, add new parent and only save data
		value.__parents[table][key] = true
		table.__data[key] = value.__data
	else
		-- other objects are saved as-is
		table.__data[key] = value
	end

	local paths = get_proxy_path(table)
	for _, v in pairs(paths) do
		local path = (v == "" and "" or (v .. ".")) .. key
		game.print("write access on " .. path)
		for _, effect in pairs(Built.effects[path] or {}) do
			effect()
		end
	end
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
			next_value = get_proxy(next_value)

			if not next_value.__parents[table] then
				next_value.__parents[table] = { [next_key] = true }
			end
		end

		return next_key, next_value
	end

	return iterator, table.__data, nil
end

script.register_metatable("proxy_meta", Proxy)

---Wraps a table in a tracking proxy
---@generic T
---@param data T
---@return T
m.wrap = function(data, root_name)
	local self = {
		__data = data,
		__parents = {},
		__root = root_name,
	}
	local proxy = setmetatable(self, Proxy)
	storage.proxy_cache[data] = proxy
	return proxy
end

return m
