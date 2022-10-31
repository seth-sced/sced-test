local json = require 'dkjson'
local json_keyorder = require 'keyorder'

local args = {...}

local input_filename = args[1]
local output_filename = args[2]

local file <close> = io.open(input_filename, 'r')
local content = file:read('a')
local obj = json.decode(content)

local new_content = json.encode(obj, {indent=true,keyorder=json_keyorder})
local output <close> = io.open(output_filename, 'w')
output:write(new_content)


