local Built = require("lib/build_results")

local m = {}

---@param data table
---@return Proxy
local function get_proxy(data)
	return storage.reactive.proxy_cache[data] or m.wrap_raw(data)
end

-- TODO: How easy would it be to cache this?

---Resolves a proxy to all possible paths
---@param proxy Proxy
---@return {path:string,owner:number|nil}[]
local function get_proxy_path(proxy)
	local parents = proxy.__parents

	if next(parents) == nil then
		return { { path = proxy.__root or "", owner = proxy.__owner } }
	end

	local results = {}

	for parent, key in pairs(parents) do
		local parent_paths = get_proxy_path(parent)
		for _, v in pairs(parent_paths) do
			for k, _ in pairs(key) do
				table.insert(results, { path = (v.path == "" and "" or (v.path .. ".")) .. k, owner = v.owner })
			end
		end
	end
	return results
end

local Proxy = {}

Proxy.__index = function(table, key)
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
	local old_value = table.__data[key]

	-- table has been replaced, remove parent/child relationship
	if type(table.__data[key]) == "table" then
		local p = get_proxy(table.__data[key])
		p.__parents[table][key] = nil
	end

	if type(value) == "table" and value.__data then
		---@cast value Proxy
		-- if we are passed a proxy, add new parent and only save data
		value.__parents[table][key] = true
		table.__data[key] = value.__data
	elseif type(value) == "table" then
		-- other objects are assigned a new proxy
		local p = get_proxy(value)
		p.__parents[table] = p.__parents[table] or {}
		p.__parents[table][key] = true
		table.__data[key] = value
	else
		table.__data[key] = value
	end

	local paths = get_proxy_path(table)
	for _, v in pairs(paths) do
		local path = (v.path == "" and "" or (v.path .. ".")) .. key
		local player = v.owner

		for effect, _ in pairs(storage.reactive.effects[path] or {}) do
			local previous = storage.p
			if player then
				storage.p = storage.reactive.player_scopes[player]
			else
				storage.p = nil
			end
			if effect.self.valid then
				if effect.fn == 1 then
					---@diagnostic disable-next-line: inject-field
					effect.old_table = old_value or {}

					---@diagnostic disable-next-line: inject-field
					effect.new_table = table.__data[key] or {}
				end
				Built.effect_fns[effect.fn](effect)
			else
				game.print("Encountered stale effect, ignoring")
			end
			storage.p = previous
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

---Wraps a table and all its contents in tracking proxies
m.wrap = function(data, root_name, owner)
	local function wrap_rec(parent_key, proxy_data, parent)
		if type(proxy_data) ~= "table" then
			return
		end

		local p = get_proxy(proxy_data)
		p.__parents[parent] = p.__parents[parent] or {}
		p.__parents[parent][parent_key] = true

		for key, value in pairs(proxy_data) do
			wrap_rec(key, value, p)
		end
	end

	local self = m.wrap_raw(data, root_name, owner)

	local proxy = setmetatable(self, Proxy)
	storage.reactive.proxy_cache[data] = proxy

	for key, value in pairs(data) do
		wrap_rec(key, value, self)
	end

	return proxy
end

---Wraps a table in a tracking proxy. Allows setting root name and owner
---@generic T
---@param data T
---@return T
m.wrap_raw = function(data, root_name, owner)
	---@type Proxy
	local self = {
		__id = storage.reactive.proxy_id,
		__data = data,
		__parents = {},
		__root = root_name or false,
		__owner = owner or false,
	}
	storage.reactive.proxy_id = storage.reactive.proxy_id + 1

	local proxy = setmetatable(self, Proxy)

	assert(storage.reactive.proxy_cache[data] == nil, "Tried to create second proxy for an already proxied table")
	storage.reactive.proxy_cache[data] = proxy

	return proxy
end

return m
