local json = require 'dkjson'
local fs = require 'lfs'

local janky = require 'jankybundle'

local bundle_search_root = ''

function append_item(table, item)
  table[#table+1] = item
end

function read_luaxmlstate(path, obj)
  local script_path = path .. '/script.lua'
  local script_exists = fs.attributes(script_path, 'mode')
  local state <close> = io.open(path .. '/state.json', 'r')
  local ui <close> = io.open(path .. '/ui.xml', 'r')

  if script_exists then
    local bundled_code = janky.bundle('__root', script_path, {search_root = bundle_search_root})
    if not bundled_code then
      print('Warning: failed to bundle ' .. script_path)
    end
    obj.LuaScript = bundled_code or ''
  end
  if state then
    local o = json.decode(state:read('a'))
    obj.LuaScriptState = json.encode(o)
  end
  if ui then obj.XmlUI = ui:read('a') end
end

local skip = {['.'] = true, ['..'] = true}
function read_object_dict(path)
  local dict = {}
  local count = 0
  for entry in fs.dir(path) do
    -- skip anything that's not a directory containing an object.json file

    if not skip[entry] and fs.attributes(('%s/%s/object.json'):format(path, entry), 'mode') then
      local state_key = entry:match('.*-.*-(%d+)')
      assert(state_key)
      dict[state_key] = read_object(path .. '/' .. entry)
      count = count + 1
    end
  end

  -- must have found some states - TTS doesn't handle empty arrays here well
  assert(count > 0)
  return dict
end

function read_object_array(path)
  local array = {}

  local count = 0
  for entry in fs.dir(path) do
    local match = entry:match('.*-.*-(%d+)')
    if match then
      count = count + 1
      array[tonumber(match)] = read_object(path .. '/' .. entry)
    end
  end

  assert(#array == count)
  return array
end

function read_object(path)
  local obj_filename = 'object.json'

  local obj_file <close> = io.open(path .. '/' .. obj_filename, 'r')
  if not obj_file then print('failed to read object at ' .. path) return nil end

  if path:match('%.$') then error('traversing . or ..') end

  local obj = json.decode(obj_file:read('a'))
  read_luaxmlstate(path, obj)

  if fs.attributes(path .. '/ContainedObjects', 'mode') then
    obj.ContainedObjects = read_object_array(path .. '/ContainedObjects')
  end

  if fs.attributes(path .. '/States', 'mode') then
    obj.States = read_object_dict(path .. '/States')
  end
  return obj
end

local args = {...}

if #args == 0 then
  print('Usage: lua buildmod.lua <input_dir> <external_src_dir> <output.json>')
  os.exit(0)
end

local input_dir = args[1]
bundle_search_root = args[2]
local output_json_filename = args[3]

local global_file <close> = io.open(input_dir .. '/global.json')
local global_object = json.decode(global_file:read('a'))
assert(global_object)

read_luaxmlstate(input_dir, global_object)

assert(fs.attributes(input_dir .. '/ObjectStates'))
local objects = read_object_array(input_dir .. '/ObjectStates')

for i,v in ipairs(objects) do
  append_item(global_object.ObjectStates, v)
end

local json_keyorder = require 'keyorder'

local output = json.encode(global_object, {indent = true, keyorder = json_keyorder})
local output_file <close> = io.open(output_json_filename, 'w')
output_file:write(output)
