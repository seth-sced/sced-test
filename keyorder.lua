local json_keyorder = { 'SaveName', 'EpochTime', 'Date', 'VersionNumber',
'GameMode', 'GameType', 'GameComplexity', 'PlayingTime', 'PlayerCounts', 'Tags',
'Gravity', 'PlayArea', 'Table', 'Sky', 'SkyURL', 'Note', 'TabStates',
'MusicPlayer', 'GUID', 'Name', 'Transform', 'Nickname', 'Description',
'GMNotes', 'AltLookAngle', 'ColorDiffuse', 'LayoutGroupSortIndex', 'Value',
'Locked', 'Grid', 'Snap', 'IgnoreFoW', 'MeasureMovement', 'DragSelectable',
'Autoraise', 'Sticky', 'Tooltip', 'GridProjection', 'HideWhenFaceDown',
'Lighting', 'Hands', 'CardID', 'SidwaysCard', 'DeckIDs', 'CustomDeck', 'Text',
'CustomImage', 'ComponentTags', 'Turns', 'CameraStates', 'DecalPallet',
'FogColor', 'FogHidePointers', 'FogReverseHiding', 'FogSeethrough',
-- global and most objects

'x', 'y', 'z', 'r', 'g', 'b',

'CustomDecal',

'ImageURL', 'ImageSecondaryURL', 'ImageScalar', 'WidthScale', 'CustomToken',

'Thickness', 'MergeDistancePixels', 'StandUp', 'Stackable',

'title', 'body', 'color', 'visibleColor', 'id', -- TabStates

'FaceURL', 'BackURL', 'NumWidth', 'NumHeight', 'BackIsHidden', 'UniqueBack',
-- Deck

'Enable', 'Type', 'TurnOrder', 'Reverse', 'SkipEmpty', 'DisableInteractions',
'PassTurns', 'TurnColor', -- Turns

'Lines', 'Color', 'Opacity', 'ThickLines', 'Snapping', 'Offset', 'BothSnapping',
'xSize', 'ySize', 'PosOffset', -- Grid

'LightIntensity', 'LightColor', 'AmbientIntensity', 'AmbientType',
'AmbientSkyColor', 'AmbientEquatorColor', 'AmbientGroundColor',
'ReflectionIntensity', 'LutIndex', 'LutContribution', -- Lighting

'RepeatSont', 'PlaylistEntry', 'CurrentAudioTitle', 'CurrentAudioURL',
'AudioLibrary', -- MusicPlayer

'Item1','Item2',

'displayed', 'normalized', -- ComponentTags.labels

'Position', 'Rotation', 'Distance', 'Zoomed', 'AbsolutePosition', -- CameraStates

'MeshURL', 'DiffuseURL', 'NormalURL', 'ColliderURL', 'Convex', -- CustomMesh

'AssetbundleURL', 'AssetbundleSecondaryURL', 'MaterialIndex', 'MeshIndex', 'TypeIndex',
'LoopingEffectIndex', --CustomAssetbundle

'Number',

'CustomMesh', 'CustomShader', 'CastShadows', -- CustomMesh

'SpecularColor', 'SpecularIntensity', 'SpecularSharpness', 'FresnelStrength',
 -- CustomShader

'StaticFriction', 'DynamicFriction', 'Bounciness', 'FrictionCombine',
'BounceCombine', -- PhysicsMaterial
'Mass', 'Drag', 'AngularDrag', 'UseGravity', -- Rigidbody

'DisableUnused', 'Hiding', -- Hands

'colorstate', 'fontSize', -- Text

'PDFUrl', 'PDFPassword', 'PDFPage', 'PDFPageOffset', --CustomPDF

'Bag', 'CustomPDF',

'LuaScript', 'LuaScriptState', 'XmlUI', 'AttachedDecals', 'CustomUIAssets',
'Decals', 'SnapPoints', 'ObjectStates', 'States', 'ContainedObjects',
'PhysicsMaterial', 'Rigidbody',


'posX', 'posY', 'posZ', 'rotX', 'rotY', 'rotZ', 'scaleX', 'scaleY', 'scaleZ',

'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15',
'16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28',
'29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41',
'42', '43', '44', '45', '46', '47', '48', '49', '50'
}

local sorted_keys = {}
for i,key in ipairs(json_keyorder) do
  sorted_keys[#sorted_keys + 1] = key
end
table.sort(sorted_keys)
local dup = {}
for i=2,#sorted_keys do
  if sorted_keys[i] == sorted_keys[i-1] then
    dup[#dup + 1] = sorted_keys[i]
  end
end

if #dup > 0 then
  local err = 'duplicate keys: '
  for i, key in ipairs(dup) do
    err = err .. key .. ' '
  end
  error(err)
end

function keyorder_for_CustomDeck(CustomDeck)
  local keys = sorted_keys_for_obj(CustomDeck)
  return keys
end
function keyorder_for_placement_bag_state(state)
  local keys = sorted_keys_for_obj(state.ml)
  if keys then
    keys[#keys + 1] = 'lock'
    keys[#keys + 1] = 'pos'
    keys[#keys + 1] = 'position'
    keys[#keys + 1] = 'rot'
    keys[#keys + 1] = 'rotation'
    keys[#keys + 1] = 'x'
    keys[#keys + 1] = 'y'
    keys[#keys + 1] = 'z'
  end
  return keys
end

function sorted_keys_for_obj(obj)
  if not obj then return nil end
  if #obj > 0 then return nil end

  local keys = {}
  for k,_ in pairs(obj) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  return keys
end

return json_keyorder
