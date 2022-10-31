#!/usr/local/bin/lua
local do_unbundle = false

local json = require 'dkjson'
local fs = require 'lfs'
local url = require 'urlencode'

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
  if not is_nil_or_empty(obj.LuaScriptState) then write_file('state.json', json.encode(json.decode(obj.LuaScriptState), {indent = true})) end

  obj.LuaScript = ""
  obj.LuaScriptState = ""
  obj.XmlUI = ""
end

function recursive_write_luaxmlstate(obj)
  local States = obj.States
  obj.States = nil

  local ContainedObjects = obj.ContainedObjects
  if obj.ContainedObjects then
    obj.ContainedObjects = {}
  end

  write_luaxmlstate(obj)
  write_file('object.json', json.encode(obj, {indent = true, keyorder = json_keyorder}))

  if ContainedObjects then
    fs.mkdir('ContainedObjects')
    fs.chdir('ContainedObjects')
    for i,v in ipairs(ContainedObjects) do
      fs.mkdir(tostring(i))
      fs.chdir(tostring(i))
      recursive_write_luaxmlstate(v)
      fs.chdir('..')
    end
    fs.chdir('..')
  end

  if States then
    fs.mkdir('States')
    fs.chdir('States')
    for k,v in pairs(States) do
      fs.mkdir(k)
      fs.chdir(k)
      recursive_write_luaxmlstate(v)
      fs.chdir('..')
    end
    fs.chdir('..')
  end
end

---

local args = {...}

local input_json_filename = args[1]
local output_dir = args[2]

local dest_mode = fs.attributes(output_dir, 'mode')

if dest_mode then
  error('destination exists')
end

local file = io.open(input_json_filename):read('a')
local game_object = json.decode(file)

fs.mkdir(output_dir)
fs.chdir(output_dir)

fs.mkdir('ObjectStates')
fs.chdir('ObjectStates')

for i,obj in ipairs(game_object.ObjectStates) do
  fs.mkdir(tostring(i))
  fs.chdir(tostring(i))
  recursive_write_luaxmlstate(obj)
  fs.chdir('..')
end
fs.chdir('..')

write_luaxmlstate(game_object)

game_object.ObjectStates = {}
write_file('global.json', json.encode(game_object, {indent = true, keyorder = json_keyorder}))

