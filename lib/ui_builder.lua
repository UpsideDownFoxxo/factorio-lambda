---@module "lib/events"
local Events = require("__lambda-ui__/lib/events")
---@module "lib/player_scope"
local PlayerScope = require("__lambda-ui__/lib/player_scope")
---@module "lib/function_store"
local FunctionStore = require("__lambda-ui__/lib/function_store")
---@module "lib/utils"
local utils = require("__lambda-ui__/lib/utils")

---@module "lib/special_vars"
local special_vars = require("__lambda-ui__/lib/special_vars")
local creation_vars, ignore_vars = table.unpack(special_vars)

local m = {}

local function normalize_props(props)
	props.type = props[1]
	props.name = props[2]
	props[1] = nil
	props[2] = nil
end

local function create_event_handler(lua_el, event, handler_fn, collected_handlers, params)
	local reactive = storage.reactive
	local cleanup = reactive.cleanup
	local handlers = reactive.dynamic.handlers

	handlers[event] = handlers[event] or {}

	local handler_descriptor = { fn = handler_fn, params = params }
	handlers[event][utils.get_ui_ident(lua_el)] = handler_descriptor

	local id = script.register_on_object_destroyed(lua_el)
	cleanup[id] = cleanup[id] or {}
	table.insert(cleanup[id], { fn = "cleanup_handler", self = utils.get_ui_ident(lua_el), event = event })
	table.insert(collected_handlers, handler_descriptor)
end

---Turn element into a LuaGuiElement mounted to `root`
---@param el any
---@param root LuaGuiElement
---@param collected_effects any
---@param collected_handlers any
---@param params table
---@return LuaGuiElement
local function build_element(el, root, collected_effects, collected_handlers, params)
	local copied = false
	-- Props may be dynamic, generate them with parameters
	if type(el.props) == "number" then
		if not copied then
			el = utils.shallow_copy(el)
			copied = true
		end
		el.props = FunctionStore.call(el.props, { params })
		normalize_props(el.props)
	end

	local lua_el

	local opts = {}

	for k, _ in pairs(el.props) do
		if creation_vars[k] then
			opts[k] = el.props[k]
		end
	end

	---@type LuaGuiElement
	lua_el = root.add(opts)

	assert(lua_el, "Failed to create element")

	for k, v in pairs(el._inlinestyle or {}) do
		lua_el.style[k] = v
	end

	local reactive = storage.reactive
	local effects = reactive.effects
	local cleanup = reactive.cleanup
	local refs = reactive.refs

	if el.props.name then
		refs[lua_el.player_index] = refs[lua_el.player_index] or {}
		refs[lua_el.player_index][el.props.name] = lua_el

		local id = script.register_on_object_destroyed(lua_el)
		cleanup[id] = cleanup[id] or {}
		table.insert(cleanup[id], { fn = "cleanup_ref", player_index = lua_el.player_index, ref = el.props.name })
	end

	if el._click then
		create_event_handler(lua_el, defines.events.on_gui_click, el._click, collected_handlers, params)
	end

	if el._value_changed then
		create_event_handler(lua_el, defines.events.on_gui_value_changed, el._value_changed, collected_handlers, params)
	end

	if el._text_changed then
		create_event_handler(lua_el, defines.events.on_gui_text_changed, el._text_changed, collected_handlers, params)
	end

	if el._for then
		-- effect registration
		local id = script.register_on_object_destroyed(lua_el)

		local dep = el._for[1]

		-- Replacing the entire table is an action on the parent, so we have to start tracking it here
		---@type ComponentFunctionDescriptor
		local replaced_descriptor =
			{ fn = "array_replaced", self = lua_el, player_index = lua_el.player_index, deps = { dep } }

		if not effects[dep] then
			effects[dep] = {}
		end

		effects[dep][replaced_descriptor] = true

		table.insert(collected_effects, replaced_descriptor)

		local cleanup_descriptor = { fn = "cleanup_effect", deps = { dep }, key = replaced_descriptor }
		cleanup[id] = cleanup[id] or {}
		table.insert(cleanup[id], cleanup_descriptor)

		-- save for_block data
		reactive.dynamic.for_blocks[utils.get_ui_ident(lua_el)] = { children = {}, markup = el[1], key = el._for.key }
	end

	if el.props.drag_target then
		if type(el.props.drag_target) == "string" then
			local t = m.ref(el.props.drag_target, { player_index = lua_el.player_index })
			lua_el.drag_target = t
			el.props.drag_target = nil
		else
			-- we do not question if the user somehow managed to get a valid element reference in here
			lua_el.drag_target = el.props.drag_target
		end
	end

	for k, v in pairs(el.props) do
		if not ignore_vars[k] then
			lua_el[k] = v
		end
	end

	for _, effect in pairs(el._effects or {}) do
		local f, deps = table.unpack(effect)

		if type(deps) == "number" then
			deps = FunctionStore.call(deps, { params })
		end

		local id = script.register_on_object_destroyed(lua_el)
		local effect_descriptor =
			{ fn = f, self = lua_el, player_index = lua_el.player_index, deps = deps, params = params }
		table.insert(collected_effects, effect_descriptor)

		for _, dep in pairs(deps) do
			if not effects[dep] then
				effects[dep] = {}
			end
			effects[dep][effect_descriptor] = true
		end

		local cleanup_descriptor = { fn = "cleanup_effect", deps = deps, key = effect_descriptor }
		cleanup[id] = cleanup[id] or {}
		table.insert(cleanup[id], cleanup_descriptor)
	end

	if not el._for then
		for k, v in pairs(el) do
			-- keys indexed with numbers are considered child elements
			if type(k) == "number" then
				build_element(v, lua_el, collected_effects, collected_handlers, params)
			end
		end
	end
	return lua_el
end

---Mounts the UI element inside the markup to the root GUI element
---@param el any
---@param root LuaGuiElement
---@return LuaGuiElement, ComponentFunctionDescriptor[],EventHandlerDescriptor[]
m.build = function(el, root, params)
	local created
	local effects = {}
	local handlers = {}
	PlayerScope.run(root.player_index, function()
		---@type {fn:number,self:LuaGuiElement}
		created = build_element(el, root, effects, handlers, params)

		for _, f in pairs(effects) do
			FunctionStore.call(f.fn, { f })
		end
	end)

	return created, effects, handlers
end

-- (Re)-register non-serializable aspects of components.
m.register = function(t)
	if type(t) ~= "table" then
		return
	end
	if type(t.props) == "table" then
		normalize_props(t.props)
	end

	if t._click then
		---@diagnostic disable-next-line: param-type-mismatch
		t._click = Events.register_event_handler(defines.events.on_gui_click, t._click)
	end

	if t._value_changed then
		---@diagnostic disable-next-line: param-type-mismatch
		t._value_changed = Events.register_event_handler(defines.events.on_gui_value_changed, t._value_changed)
	end

	if t._text_changed then
		---@diagnostic disable-next-line: param-type-mismatch
		t._text_changed = Events.register_event_handler(defines.events.on_gui_text_changed, t._text_changed)
	end

	if t._for then
		assert(t._for[1] and type(t._for[1]) == "string", "For blocks must have a declared dependency")
		assert(t[1] and not t[2], "For blocks must have exactly one child")

		t[1].props = FunctionStore.link(t[1].props)
		if t._for.key then
			t._for.key = FunctionStore.link(t._for.key)
		end
	end

	for _, value in pairs(t._effects or {}) do
		value[1] = FunctionStore.link(value[1])

		-- dependency might be dynamic
		if type(value[2]) == "function" then
			value[2] = FunctionStore.link(value[2])
		end
	end

	-- recursively register children
	for k, v in pairs(t) do
		if type(k) == "number" then
			m.register(v)
		end
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
		-- this should not happen, since refs are cleaned up if their parent element is destroyed.
		-- treat as "not in cache"
		storage.reactive.refs[event.player_index][str] = nil
		return nil
	end

	return el
end

return m
