local Result = require("lib/build_results")
local Events = require("lib/events")
local PlayerScope = require("lib/player_scope")

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
		storage.reactive.refs[lua_el.player_index] = storage.reactive.refs[lua_el.player_index] or {}
		storage.reactive.refs[lua_el.player_index][el._ref] = lua_el
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
			if not storage.reactive.effects[dep] then
				storage.reactive.effects[dep] = {}
			end

			table.insert(storage.reactive.effects[dep], { fn = f, self = lua_el })
			table.insert(effects, { fn = f, self = lua_el })
		end
	end
end

---Mounts the UI element inside the markup to the root GUI element
---@param el any
---@param root LuaGuiElement
m.build = function(el, root)
	PlayerScope.run(root.player_index, function()
		---@type {fn:number,self:LuaGuiElement}
		local effects = {}
		build_func(el, root, effects)

		for _, f in pairs(effects) do
			Result.effect_fns[f.fn](f)
		end
	end)
end

local n = 1
--- (Re)-register non-serializable aspects of components.
m.register = function(t)
	if type(t) ~= "table" then
		return
	end

	if t._click then
		assert(t.props[2] and type(t.props[2]) == "string", "Elements with click events must have a name")
		Events.register_click(t._click, t.props[2])
	end

	for _, value in pairs(t._effects or {}) do
		Result.effect_fns[n] = value[1]
		value[1] = n
		n = n + 1
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
	return (storage.reactive.refs[i] or {})[str]
end

return m
