---@alias EffectDescriptor {fn:number,self:LuaGuiElement,player_index:number,deps:string[]}
---@alias Props {[1]:string,[2]:string|nil}
---@alias Effect {[1]:function,[2]:string[]}
---@alias InlineStyle table

---@class Element
---@field props Props
---@field _effects Effect[]|nil
---@field [number] AnyElement

---@class Button
---@field props Props
---@field _effects Effect[]|nil
---@field _click function
---@field [number] AnyElement

---@class Slider
---@field props Props
---@field _effects Effect[]|nil
---@field _value_changed function
---@field [number] AnyElement

---@class Text
---@field props Props
---@field _effects Effect[]|nil
---@field _text_changed function
---@field [number] AnyElement
---@alias ForClause { [1]: string, key: string|nil }

---@class ElementWithForClause
---@field props Props
---@field _effects Element[]|nil
---@field _for ForClause
---@field [number] AnyElement

---@alias AnyElement Element|ElementWithForClause|Button|Slider|Text
