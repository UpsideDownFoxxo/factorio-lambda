local Events = require("lib/events")

local m = {}

local creation_vars = (function()
	local t = {
		"type",
		"name",
		"caption",
		"direction",
		"value",
		"minimum_value",
		"maximum_value",
		"numeric",
		"allow_decimal",
		"allow_negative",
		"text",
	}
	local tc = {}
	for _, v in pairs(t) do
		tc[v] = true
	end
	return tc
end)()

---Mounts the UI element inside the markup to the root GUI element
---@param el any
---@param root LuaGuiElement
m.build = function(el, root)
	local lua_el
	if el.type == nil then
		el.type = "frame"
	end

	local opts = {}
	for k, _ in pairs(creation_vars) do
		opts[k] = el[k]
	end
	lua_el = root.add(opts)

	for k, v in pairs(el._inlinestyle or {}) do
		lua_el.style[k] = v
	end

	if el._ref then
		storage.refs[lua_el.player_index] = storage.refs[lua_el.player_index] or {}
		storage.refs[lua_el.player_index][el._ref] = lua_el
	end

	for k, v in pairs(el) do
		if creation_vars[k] then
		-- keys indexed with numbers are considered child elements
		elseif type(k) == "number" then
			m.build(v, lua_el)
		elseif k:sub(1, 1) == "_" then
		else
			-- dump all other top-level keys not starting with _ into the lua element
			lua_el[k] = v
		end
	end
end

---Initialize GUI element from markup.
m.register = function(t)
	if type(t) ~= "table" then
		return
	end

	if t._click then
		Events.register_click(t._click, t.name)
	end

	for _, v in pairs(t) do
		m.register(v)
	end
end

---Returns the element saved as ref, if any
---@param str string
---@param event EventData.on_gui_click | EventData.on_gui_text_changed
---@return LuaGuiElement|nil
m.ref = function(str, event)
	local i = event.player_index
	return (storage.refs[i] or {})[str]
end

return m
