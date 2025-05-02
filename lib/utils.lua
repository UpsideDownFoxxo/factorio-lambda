local m = {}

---@param el LuaGuiElement
---@return string
m.get_ui_ident = function(el)
	return tostring(el.player_index) .. "|" .. tostring(el.index)
end

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
