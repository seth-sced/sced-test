#!/usr/local/bin/lua
local do_unbundle = true

local json = require 'dkjson'
local fs = require 'lfs'

local janky = require 'jankybundle'
local json_keyorder = require 'keyorder'

function is_nil_or_empty(str)
  return str == nil or str:len() == 0
end

function write_file(name, content)
  local tmp = io.open(name, 'w')
  if not tmp then
    print(name, fs.currentdir())
    error('failed to open file ' .. name .. ' in dir ' .. fs.currentdir())
  end
  tmp:write(content)
  tmp:close()
end

function write_luaxmlstate(obj)
  if not is_nil_or_empty(obj.LuaScript) then
    if do_unbundle then
      local unbundle_code = janky.tryunbundle(obj.LuaScript)
      if unbundle_code then
        write_file('script.lua', unbundle_code)
      else
        write_file('script.lua', obj.LuaScript)
      end
    else
      write_file('script.lua', obj.LuaScript)
    end
  end
  if not is_nil_or_empty(obj.XmlUI) then write_file('ui.xml', obj.XmlUI) end
  if not is_nil_or_empty(obj.LuaScriptState) then
    local script_state_obj = json.decode(obj.LuaScriptState)
    local keyorder = keyorder_for_placement_bag_state(script_state_obj)
    write_file('state.json',
               json.encode(script_state_obj,
                           {indent = true, keyorder = keyorder}))
  end

  obj.LuaScript = ""
  obj.LuaScriptState = ""
  obj.XmlUI = ""
end

function sanitized(str)
  return str:gsub('[^%a%d-._]', '_')
end

function safe_name(key, obj)
  assert(type(key) == 'string')
  return ('%s-%s-%s'):format(
        #(obj.Nickname) > 0 and sanitized(obj.Nickname) or '',
        #(obj.Name) > 0 and sanitized(obj.Name) or '',
        key)
end

function recursive_write_luaxmlstate(obj)
  local States = obj.States
  obj.States = nil

  local ContainedObjects = obj.ContainedObjects
  if obj.ContainedObjects then
    obj.ContainedObjects = {}
  end

  write_luaxmlstate(obj)
  if obj.Name == 'Deck' then
    setmetatable(obj.CustomDeck, {__jsonorder = keyorder_for_CustomDeck(obj.CustomDeck)})
  end

  write_file('object.json', json.encode(obj, {indent = true, keyorder = json_keyorder}))

  if ContainedObjects then
    fs.mkdir('ContainedObjects')
    fs.chdir('ContainedObjects')
    for i,v in ipairs(ContainedObjects) do
      local safe_dir_name = safe_name(tostring(i), v)
      fs.mkdir(safe_dir_name)
      fs.chdir(safe_dir_name)
      recursive_write_luaxmlstate(v)
      fs.chdir('..')
    end
    fs.chdir('..')
  end

  if States then
    fs.mkdir('States')
    fs.chdir('States')
    for k,v in pairs(States) do
      local safe_dir_name = safe_name(k, v)
      fs.mkdir(safe_dir_name)
      fs.chdir(safe_dir_name)
      recursive_write_luaxmlstate(v)
      fs.chdir('..')
    end
    fs.chdir('..')
  end
end

---

local args = {...}

if #args == 0 then
  print('Usage: lua dumpmod.lua <mod_file.json> <output_dir>')
  os.exit(0)
end

local input_json_filename = args[1]
local output_dir = args[2]

local dest_mode = fs.attributes(output_dir, 'mode')

if dest_mode then
  error('destination exists. Delete it before running dumpmod.lua')
end

local file = io.open(input_json_filename):read('a')
local game_object = json.decode(file)

fs.mkdir(output_dir)
fs.chdir(output_dir)

fs.mkdir('ObjectStates')
fs.chdir('ObjectStates')

for i,obj in ipairs(game_object.ObjectStates) do
  local safe_dir_name = safe_name(tostring(i), obj)
  fs.mkdir(safe_dir_name)
  fs.chdir(safe_dir_name)
  recursive_write_luaxmlstate(obj)
  fs.chdir('..')
end
fs.chdir('..')

write_luaxmlstate(game_object)

game_object.ObjectStates = {}
write_file('global.json', json.encode(game_object, {indent = true, keyorder = json_keyorder}))

