local Result = require("lib/build_results")
require("lib/internal_effects")
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
		"height",
		"column_count",
	}
	local tc = {}
	for _, v in pairs(t) do
		tc[v] = true
	end
	return tc
end)()

local build_func

local function build_element(el, root, effects)
	local lua_el

	local opts = {}
	el.props.type = el.props[1]
	el.props.name = el.props[2]
	el.props[1] = nil
	el.props[2] = nil

	for k, _ in pairs(creation_vars) do
		opts[k] = el.props[k]
	end

	---@type LuaGuiElement
	lua_el = root.add(opts)

	assert(lua_el, "Failed to create element")

	for k, v in pairs(el._inlinestyle or {}) do
		lua_el.style[k] = v
	end

	if el._ref then
		storage.reactive.refs[lua_el.player_index] = storage.reactive.refs[lua_el.player_index] or {}
		storage.reactive.refs[lua_el.player_index][el._ref] = lua_el
	end

	if el._for then
		local id = script.register_on_object_destroyed(lua_el)

		local dep = el._for[1]

		---@type EffectDescriptor
		local effect_descriptor = { fn = 1, self = lua_el, player_index = lua_el.player_index, deps = { el._for[1] } }

		storage.reactive.effect_clean[id] = storage.reactive.effect_clean[id] or {}
		table.insert(storage.reactive.effect_clean[id], effect_descriptor)

		if not storage.reactive.effects[dep] then
			storage.reactive.effects[dep] = {}
		end
		storage.reactive.effects[dep][effect_descriptor] = true

		table.insert(effects, effect_descriptor)
	end

	if el.props.drag_target then
		if type(el.props.drag_target) == "string" then
			local t = m.ref(el.props.drag_target, { player_index = lua_el.player_index })
			lua_el.drag_target = t
			el.props.drag_target = nil
		else
			-- we do not question if the user somehow managed to get a valid element reference in here
			lua_el.drag_target = el.props.drag_target
			el.props.drag_target = nil
		end
	end

	for k, v in pairs(el.props) do
		if not creation_vars[k] then
			lua_el[k] = v
		end
	end

	for _, effect in pairs(el._effects or {}) do
		local f, deps = table.unpack(effect)
		local id = script.register_on_object_destroyed(lua_el)

		local effect_descriptor = { fn = f, self = lua_el, player_index = lua_el.player_index, deps = deps }

		storage.reactive.effect_clean[id] = storage.reactive.effect_clean[id] or {}
		table.insert(storage.reactive.effect_clean[id], effect_descriptor)

		table.insert(effects, effect_descriptor)

		for _, dep in pairs(deps) do
			if not storage.reactive.effects[dep] then
				storage.reactive.effects[dep] = {}
			end
			storage.reactive.effects[dep][effect_descriptor] = true
		end
	end

	for k, v in pairs(el) do
		-- keys indexed with numbers are considered child elements
		if type(k) == "number" then
			build_func(v, lua_el, effects)
		end
	end
	return lua_el
end

local function build_for_block(el, root, effects)
	return build_func(el[1], root, effects)
end

build_func = function(el, root, effects)
	return build_element(el, root, effects)
end

---Mounts the UI element inside the markup to the root GUI element
---@param el any
---@param root LuaGuiElement
---@return LuaGuiElement
m.build = function(el, root)
	local created
	PlayerScope.run(root.player_index, function()
		---@type {fn:number,self:LuaGuiElement}
		local effects = {}
		created = build_func(el, root, effects)

		for _, f in pairs(effects) do
			if f.fn >= 1000 then
				Result.effect_fns[f.fn](f)
			end
		end
	end)

	return created
end

--- Used to maintain references to functions across save/load cycles
--- IDs below 1k are reserved for internal use
local func_id = 1000

local function register_for_block(t)
	assert(t._for[1] and type(t._for[1]) == "string", "For blocks must have a declared dependency")
	assert(t[1] and not t[2], "For blocks must have exactly one child")

	m.register(t[1])
end

local function register_element(t)
	if t._click then
		assert(t.props[2] and type(t.props[2]) == "string", "Elements with events must have a name")
		Events.register_click(t._click, t.props[2])
	end

	if t._value_changed then
		assert(t.props[2] and type(t.props[2]) == "string", "Elements with events must have a name")
		Events.register_value_changed(t._value_changed, t.props[2])
	end

	if t._text_changed then
		assert(t.props[2] and type(t.props[2]) == "string", "Elements with events must have a name")
		Events.register_text_changed(t._text_changed, t.props[2])
	end

	for _, value in pairs(t._effects or {}) do
		Result.effect_fns[func_id] = value[1]
		value[1] = func_id
		func_id = func_id + 1
	end

	for k, v in pairs(t) do
		if type(k) == "number" then
			m.register(v)
		end
	end
end

-- (Re)-register non-serializable aspects of components.
m.register = function(t)
	if type(t) ~= "table" then
		return
	end

	if t._for then
		register_for_block(t)
	else
		register_element(t)
	end
end

---Returns the element saved as ref, if any
---@param str string
---@param event {player_index : number}
---@return LuaGuiElement|nil
m.ref = function(str, event)
	local el = (storage.reactive.refs[event.player_index] or {})[str]
	if not el then
		return nil
	end

	if not el.valid then
		storage.reactive.refs[event.player_index][str] = nil
		game.print("removed stale ref")
		return nil
	end

	return el
end

return m
