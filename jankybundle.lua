-- module options
-- none

--[[
  janky.bundle(root filename, {search_paths})
  janky.unbundle(root filename)
]]

-- dependencies
local json = require('dkjson')
local assert, table, string, ipairs, pairs, io, error =
      assert, table, string, ipairs, pairs, io, error

local print = print


-- block environment
local _ENV = nil

local janky = {version = 'jankybundle 0.0.1'}

local bundle_code = [[
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
  local loadingPlaceholder = {[{}] = true}

  local register
  local modules = {}

  local require
  local loaded = {}

  register = function(name, body)
    if not modules[name] then
      modules[name] = body
    end
  end

  require = function(name)
    local loadedModule = loaded[name]

    if loadedModule then
      if loadedModule == loadingPlaceholder then
        return nil
      end
    else
      if not modules[name] then
        if not superRequire then
          local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
          error('Tried to require ' .. identifier .. ', but no such module has been registered')
        else
          return superRequire(name)
        end
      end

      loaded[name] = loadingPlaceholder
      loadedModule = modules[name](require, loaded, register, modules)
      loaded[name] = loadedModule
    end

    return loadedModule
  end

  return require, loaded, register, modules
end)(nil)
]]

local register_format = [[
__bundle_register("%s", function(require, _LOADED, __bundle_register, __bundle_modules)
%s
end)
]]

local return_format = [[
return __bundle_require("%s")
]]

local function get_module_code(require_text, search_root)
  if require_text:find('\n') then
    error('bad require')
  end
  local extensions = {'', '.lua', '.ttslua'}
  for i, ext in ipairs(extensions) do
    local filename = ('%s/%s%s'):format(search_root, require_text, ext)
    local file <close> = io.open(filename)
    if file then
      return file:read('a')
    end
  end
  return nil
end

local function get_next_lua_string(code, init)
  local find_index, _, quote_char = code:find([=[(['"])]=], init)
  if not find_index then return nil end

  local _, end_index, quote_char = code:find([=[(['"])]=], find_index + 1)
  if not _ then return nil end

  return find_index, end_index, code:sub(find_index + 1, end_index - 1)
end

--[[
  the module dictionary datastructure has the following semantics
  the keys are the strings that are require()d by source
  when the require() statement is first processed the value is set to false to
indicate that the source hasn't been recovered
  when the source is loaded the module source is used as the value
  an empty string is used as the value when the source can't be loaded
]]
local function get_required_modules(script_source)
  local required_modules = {}

  local search_start = 1
  repeat
    local end_index
    search_start, end_index = script_source:find('%f[%a]require%f[^%a]', search_start)
    if search_start then
      local next_string = ''
      local str_start, str_end, str = get_next_lua_string(script_source, end_index)
      if str then
        required_modules[str] = false
      end
      search_start = str_end and str_end + 1
    end
  until not search_start or search_start >= #script_source

  return required_modules
end

local function all_modules_have_source_or_cant_be_found(module_dictionary)
  for module_name, src in pairs(module_dictionary) do
    if not src then return false end
  end
  return true
end

local function merge_module_dict(lhs, rhs)
  for mod, src in pairs(rhs) do
    lhs[mod] = lhs[mod] or src
  end
  return lhs
end

--[[
  take a filename,
  process it for 'require' statements
  output string consisting of 'bundled' code
  settings = {search_root = 'absolute_path_to_require_code'}

  return fail on error
]]
function janky.bundle(root_module_name, filename, settings)
  local root_module_file <close> = io.open(filename)
  if not root_module_file then return nil end


  local root_module_code = root_module_file:read('a')
  if not root_module_code then return nil end

  -- process file for require statements
  local required_modules = get_required_modules(root_module_code)

  -- get source for required modules
  repeat
    local newly_required_modules = {}
    for module_name, src in pairs(required_modules) do
      local module_code = get_module_code(module_name, settings.search_root)
      if module_code then
        required_modules[module_name] = module_code
        local nrm = get_required_modules(module_code)
        merge_module_dict(newly_required_modules, nrm)
      else
        print('Warning: while bundling: ' .. filename .. ' jankybundle could not find module code for ' .. module_name)
        required_modules[module_name] = ''
      end
    end
    merge_module_dict(required_modules, newly_required_modules)
  until all_modules_have_source_or_cant_be_found(required_modules)

  local required_module_count = 0
  for m,s in pairs(required_modules) do required_module_count = required_module_count + 1 end
  if required_module_count == 0 then
    return root_module_code
  end


  local bundle_data = {rootModuleName = root_module_name, version = janky.version}
  -- local result = ('-- Bundled by jankybundle %s\n%s'):format(json.encode(bundle_data), bundle_code)
  local result = '-- Bundled by luabundle {"version":"1.6.0"}\n'
  result = result .. bundle_code

  result = result .. register_format:format(root_module_name, root_module_code)

  for module_name, module_code in pairs(required_modules) do
    result = result .. register_format:format(module_name, module_code)
  end

  result = result .. return_format:format(root_module_name)
  return result
end

--[[
  take a string containing 'bundled' code
  output string of 'root' code
  return fail on error
]]
function janky.tryunbundle(bundled_code)
  local root_module_name = string.match(bundled_code, '"rootModuleName":"([^"]*)"')
  if not root_module_name then root_module_name = '__root' end

  local pattern = ('__bundle_register("%s"'):format(root_module_name)
  local root_code_start, root_code_end, capture = string.find(bundled_code, pattern, 1, true)
  if not root_code_start then return nil end

  root_code_start = string.find(bundled_code, '\n', root_code_start, true)
  if not root_code_start then return nil end

  root_code_start = root_code_start + 1

  local root_code_end = string.find(bundled_code, ('__bundle_register('), root_code_start, true)
  if not root_code_end then return nil end

  root_code_end = root_code_end - 7
  if not (root_code_end >= root_code_start) then return nil end

  local root_code = string.sub(bundled_code, root_code_start, root_code_end)
  return root_code
end

return janky
