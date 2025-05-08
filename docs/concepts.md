# Motivation
*Lambda* defines UI contents as a function over state. Whenever state the UI depends on changes, the contents are automatically updated to reflect that change.
This makes it easy to create UIs that have to display a lot of dynamic data.

# Data Storage
Data is stored in a subsection of the `storage` global:
- `storage.g` is used for global state, accessible to all functions, no matter what player they belong to.
- `storage.p` is used to save player-specific state. It's only populated inside event handlers (like `_click`) or effects.
  The raw data for each player lives in the `storage.reactive.players` table

# Components
A UI component is made up of at least a `props` table, where basic properties of the component are defined.
```lua
local example = {
  props={"button","example-button",caption="Hello World!"}
}
```
The first element of the table is used as the element type, the second (if specified) is used as the element name.
All other keys inside `props` are applied to the component where appropriate, either during creation or directly after.

## Refs
A ref, short for reference, gives the component a name that can be used to obtain a reference to the underlying UI element inside functions.
A component with a name is automatically entered into a player-specific referenced table, and a reference to the generated UI element can be obtained using the `ref` function.
```lua
local ref_el = {
  props={"label","ref_label",caption = ""}
}

local ref_button = {
  props = {"button", caption = "Click Me!"}
  _click = function (e) 
    -- ref returns the GUI element representing ref_el for the player index inside e
    ref("ref-label",e).caption = "I am being referenced!"
  end
}
```

Additionally, a component may have the following top-level entries:

## Children
All numeric keys inside a component are considered to be that component's children, and are expected to be valid components themselves.

## Event Handlers
Event handlers allow you to react to interactions with components.
Currently implemented are:
- `_click`
- `_value_changed`
- `_text_changed`

The event handler is a function taking in a single argument, the event data created by the observed interaction.
The appropriate player data is mounted to `storage.p` and is accessible inside the handler.

## Effect
Effects are functions that are automatically ran when the component they belong to is created or state their output depends on changes.
They consist of a function taking in one argument `e`, which provides access to the element and the player index with `e.self` and `e.player_index`, and a table which is used to declare dependencies on data within `storage.g` or `storage.p`
```lua
local data_label = {
  props = {"label",caption=""}
  _effects = {
    {
      -- this function will automatically re-run when storage.p.string is written to
      function(e)
        e.self.caption = storage.p.string
      end,
      {"storage.p.string"}
    }
  }
}
```
# Dynamic Content
Sometimes UI contents aren't known ahead of time. In these cases you can use the following tools to declare your components: 

## For Blocks
The presence of a `_for` key in the top level of a component will turn that component into a For Block.
For Blocks can only have one child element, which they will duplicate for every entry in the table. To allow the children to differ from each other,
the `props` field can now be a function that returns a customized `props` table. The function takes in one argument, the value of the entry in the source table.

`_for` expects a table with a string to declare a dependency on a table, and optionally a `key` function.
Replacing the table at the address will prompt Lambda to identify new entries in the table and remove old entries.
By default it will use Lua equality of the values for this, which might not work properly if the values are themselves tables. For this, the `key` function can be used to generate unique identifiers for comparison. The `key` function takes in the value of the table and should output a value that uniquely identifies this entry in the table.

```lua
-- storage.p = {{sprite="inserter",toggled=true},{sprite="transport-belt",toggled=false}}
local buttons = {
  props = { "table", "button_table", column_count = #item_sprites, style = "filter_slot_table" },
  _for = {
    "p.icons",
    -- we only need to update elements if new sprites are introduced, so the sprite string should be our identifier
    key = function(a)
      return a.sprite
    end,
  },
  {
    props = function(entry)
      return {
        "sprite-button",
        sprite = "item/" .. entry.sprite,
        toggled = entry.toggled
      }
    end,
  }
}
```
> [!WARNING]
> For Blocks currently do not work too well with effects. An extra `params` element is available on the table passed into effects and event handlers, which will hold the values of the element in the table they were constructed from. This may change in the future
