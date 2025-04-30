local m = {}

---@param el LuaGuiElement
---@return string
m.get_ui_ident = function(el)
	return tostring(el.player_index) .. "|" .. tostring(el.index)
end

return m
