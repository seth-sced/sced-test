function onLoad()
  -- Add a button to the object
  local params = {}
  params.click_function = 'toPhaseOne'
  params.function_owner = self
  params.tooltip = ''
  params.width = 600
  params.height = 600
  self.createButton(params)
end

function toPhaseOne()
  for _, tracker in ipairs(getObjectsWithTag("LinkedPhaseTracker")) do
    tracker.setState(1)
  end
end