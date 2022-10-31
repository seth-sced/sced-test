local janky = require 'jankybundle'
--local bundled_code = janky.bundle('__root', '/Volumes/Blisterpaw/Projects/ArkhamSCED/dump/nounbundle/ObjectStates/104/script.lua', {search_root='/Volumes/Blisterpaw/Projects/ArkhamSCED/SCED/src'})
local bundled_code = io.open('/Volumes/Blisterpaw/Projects/ArkhamSCED/dump/nounbundle/ObjectStates/104/script.lua'):read('a')

print(janky.tryunbundle(bundled_code))

