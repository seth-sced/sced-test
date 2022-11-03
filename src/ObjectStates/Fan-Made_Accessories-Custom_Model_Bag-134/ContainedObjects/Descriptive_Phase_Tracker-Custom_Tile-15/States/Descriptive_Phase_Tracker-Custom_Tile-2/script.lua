function onLoad()
  -- Add a button to the object
  local params = {}
  params.click_function = 'toPhaseThree'
  params.function_owner = self
  params.tooltip = '2. Investigation Phase\n\n    2.1 Investigation phase begins.\n\n> PLAYER WINDOW <\n\n    2.2 Next investigator’s turn begins.\n\n> PLAYER WINDOW <\n\n        2.2.1 Active investigator may take\n          an action, if able. If an action\n          was taken, return to previous\n          player window. If no action was\n          taken, proceed to 2.2.2.\n\n        2.2.2 Investigator’s turn ends.\n          If an investigator has not yet\n          taken a turn this phase, return\n          to 2.2. If each investigator has\n          taken a turn this phase,\n          proceed to 2.3.\n\n    2.3 Investigation phase ends.'
  params.width = 600
  params.height = 600
  self.createButton(params)
end

function toPhaseThree()
  self.setState(3)
end