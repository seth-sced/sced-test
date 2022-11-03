function onLoad()
  -- Add a button to the object
  local params = {}
  params.click_function = 'toPhaseOne'
  params.function_owner = self
  params.tooltip = '4. Upkeep Phase\n\n    4.1 Upkeep phase begins.\n\n> PLAYER WINDOW <\n\n    4.2 Reset actions.\n\n    4.3 Ready each exhausted card.\n\n    4.4 Each investigator draws 1\n      card and gains 1 resource.\n\n    4.5 Each investigator checks\n      hand size.\n\n    4.6 Upkeep phase ends.\n      Round ends.'
  params.width = 600
  params.height = 600
  self.createButton(params)
end

function toPhaseOne()
  self.setState(1)
end