local Events = require("lib/events")

local m = { effects = {} }

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

local function build_func(el, root, effects)
	local lua_el

	local opts = {}
	el.props.type = el.props[1]
	el.props.name = el.props[2]
	el.props[1] = nil
	el.props[2] = nil

	for k, _ in pairs(creation_vars) do
		opts[k] = el.props[k]
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
		-- keys indexed with numbers are considered child elements
		if type(k) == "number" then
			m.build(v, lua_el)
		end
	end

	for k, v in pairs(el.props) do
		if not creation_vars[k] then
			lua_el[k] = v
		end
	end

	for _, effect in pairs(el._effects or {}) do
		local f, deps = table.unpack(effect)

		for _, dep in pairs(deps) do
			if not m.effects[dep] then
				m.effects[dep] = {}
			end

			local g = function()
				f({ self = lua_el })
			end

			table.insert(m.effects[dep], g)
			table.insert(effects, g)
		end
	end
end

---Mounts the UI element inside the markup to the root GUI element
---@param el any
---@param root LuaGuiElement
m.build = function(el, root)
	local effects = {}
	build_func(el, root, effects)

	for _, f in pairs(effects) do
		f()
	end
end

---Initialize GUI element from markup.
m.register = function(t)
	if type(t) ~= "table" then
		return
	end

	if t._click then
		assert(t.props[2] and type(t.props[2]) == "string", "Elements with click events must have a name")
		Events.register_click(t._click, t.props[2])
	end

	for k, v in pairs(t) do
		if type(k) == "number" then
			m.register(v)
		end
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
