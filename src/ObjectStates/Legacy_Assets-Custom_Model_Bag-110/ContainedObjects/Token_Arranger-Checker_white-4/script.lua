---
--- Generated by Luanalysis
--- Created by Whimsical.
--- DateTime: 2021-12-19 5:00 p.m.
---

---@type table<string, string>
local token_ids = {
  elder_sign = "Elder Sign",
  skull = "Skull",
  cultist = "Cultist",
  tablet = "Tablet",
  elder_thing = "Elder Thing",
  autofail = "Auto-fail",
  bless = "Bless",
  curse = "Curse",
  frost = "Frost",
  unnamed = ""
}

---@type table<string, string>
local name_ids = {
  ["Elder Sign"] = "elder_sign",
  ["Skull"] = "skull",
  ["Cultist"] = "cultist",
  ["Tablet"] = "tablet",
  ["Elder Thing"] = "elder_thing",
  ["Auto-fail"] = "autofail",
  ["Bless"] = "bless",
  ["Curse"] = "curse",
  ["Frost"] = "frost",
  [""] = "unnamed"
}

---@type Vector
local rotation = {0, 270.00, 0}

---@type table<string, number>
local offsets = {
  x = -2,
  z = -2
}

local left_right = "z"
local up_down = "x"
local vertical = "y"

---@type TTSObject[]
local tracking = {}

function onload(data)
  data = JSON.decode(data)
  if data then
    local existing = data.tracking

    if existing then
      for _, guid in ipairs(existing) do
        local object = getObjectFromGUID(guid)
        if object then
          table.insert(tracking, object)
        end
      end
    end

    if data.tokens then
      Wait.frames(function ()
        for token, value in pairs(data.tokens) do
          revalue(nil, value, token)
        end
      end, 3)
    end

    Wait.frames(function ()
      if data.auto_update then
        self.UI:setAttribute("auto_update", "isOn", data.auto_update)
        updateToggle(nil, data.auto_update, "auto_update")
      end
    end, 3)
  end

  self:addContextMenuItem("Clear", function ()
    tracking = {}
  end, false)
end

function onSave()
  local targets = {}
  for _, token in ipairs(tracking) do
    table.insert(targets, token:getGUID())
  end

  local tokens = {}
  for id, _ in pairs(token_ids) do
    tokens[id] = self.UI:getValue(id)
  end

  return JSON.encode({
    tracking = targets,
    tokens = tokens,
    auto_update = self.UI:getAttribute("auto_update", "isOn")
  })
end

---@param player Player
---@param value string
---@param token string
function revalue(player, value, token)
  if not tonumber(value) then value = 0 end
  self.UI:setValue(token, value)
  self.UI:setAttribute(token, "text", value)

  if player then -- player is nil when we call this in onload
    -- False since "on" looks greyed out
    if self.UI:getAttribute("auto_update", "isOn"):lower()=="false" then
      Wait.frames(function()
        layout()
      end, 3)
    end
  end
end


---@param player Player
---@param token string
function inc(player, token)
  local value = tonumber(self.UI:getValue(token)) or 0
  revalue(player, value+1, token)
end

---@param player Player
---@param token string
function dec(player, token)
  local value = tonumber(self.UI:getValue(token)) or 0
  revalue(player, value-1, token)
end

---@param player Player
---@param value string
---@param id string
function updateToggle(player, value, id)
  local value = value:lower() == "true" and true or false
  self.UI:setAttribute(id, "isOn", value)
  if player then
    broadcastToAll("Token Arranger: Auto-Update " .. (value and "Disabled" or "Enabled"))
  end
end

---@return TTSObject
local function get_chaos_bag()
  return getObjectsWithTag("chaos_bag")[1]
end

---@type table<string, number>
local token_precedence = {
  ["Skull"] = -1,
  ["Cultist"] = -2,
  ["Tablet"] = -3,
  ["Elder Thing"] = -4,

  ["Elder Sign"] = 100,
  ["Auto-fail"] = -100,

  ["Bless"] = -1,
  ["Curse"] = -2,
  ["Frost"] = -3,
  [""] = -1000,
}

local function token_value_comparator(left, right)
  if left.value>right.value then return true
  elseif right.value>left.value then return false
  elseif left.precedence>right.precedence then return true
  elseif right.precedence>left.precedence then return false
  else return left.token:getGUID() > right.token:getGUID()
  end
end

local function do_position()
  local data = {}

  for index, token in ipairs(tracking) do
    local name = token:getName()

    data[index] = {
      token= token,
      value = tonumber(name) or tonumber(self.UI:getValue(name_ids[name])),
      precedence = token_precedence[name] or 0
    }
  end

  table.sort(data, token_value_comparator)

  local pos = self:getPosition()
  local location = {}

  pos[left_right] = pos[left_right] + offsets[left_right]

  location[left_right] = pos[left_right]
  location[up_down] = pos[up_down]
  location[vertical] = pos[vertical]

  local current_value = data[1].value

  for _, item in ipairs(data) do
    ---@type TTSObject
    local token = item.token

    ---@type number
    local value = item.value

    if value~=current_value then
      location[left_right] = pos[left_right]
      location[up_down] = location[up_down] + offsets[up_down]
      current_value = value
    end

    token:setPosition(location)
    token:setRotation(rotation)
    location[left_right] = location[left_right] + offsets[left_right]
  end

end

function layout()
  for _, token in ipairs(tracking) do
    token:destruct()
  end

  tracking = {}

  local chaos_bag = get_chaos_bag()

  local size = #chaos_bag:getObjects()

  for _,data in ipairs(chaos_bag:getObjects()) do
    chaos_bag:takeObject {
      guid = data.guid,
      smooth = false,
      ---@param tok TTSObject
      callback_function = function (tok)
        local clone = tok:clone()
        Wait.frames(function () chaos_bag:putObject(clone) end, 1)
        table.insert(tracking, tok)
      end
    }
  end

  Wait.condition(function () do_position() end, function () return size==#tracking end)
end
