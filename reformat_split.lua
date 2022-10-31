local json = require 'dkjson'
local json_keyorder = require 'keyorder'

local file <close> = io.open('testing/Split231.json', 'r')
local content = file:read('a')
local obj = json.decode(content)

local new_content = json.encode(obj, {indent=true,keyorder=json_keyorder})
local output <close> = io.open('testing/Split231_2.json', 'w')
output:write(new_content)


