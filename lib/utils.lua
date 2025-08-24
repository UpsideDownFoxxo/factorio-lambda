local m = {}

---Turns a `LuaGuiElement` into an unique identifier
---@param el LuaGuiElement
---@return string
m.get_ui_ident = function(el)
	return tostring(el.player_index) .. "|" .. tostring(el.index)
end

----------------------
-- Table Operations --
----------------------

---Swaps elements at the two keys
---@generic A
---@param t table<A,any>
---@param a A
---@param b A
m.swap = function(t, a, b)
	local tmp = t[a]
	t[a] = t[b]
	t[b] = tmp
end

m.reverse = function(t)
	local new = {}
	for key, value in pairs(t) do
		new[value] = key
	end

	return new
end

---Creates a shallow copy of the provided table
---@param t table
---@return table
m.shallow_copy = function(t)
	if type(t) == "table" then
		local c = {}

		for k, v in pairs(t) do
			c[k] = v
		end

		return c
	end

	error("Cannot shallow copy non-table values")
end

return m
