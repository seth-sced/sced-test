function onLoad()
  -- Add a button to the object
  local params = {}
  params.click_function = 'toPhaseFour'
  params.function_owner = self
  params.tooltip = '3. Enemy Phase\n\n    3.1 Enemy phase begins.\n\n    3.2 Hunter enemies move.\n\n> PLAYER WINDOW <\n\n    3.3 Next investigator resolves\n      engaged enemy attacks. If an\n      investigator has not yet\n      resolved enemy attacks this\n      phase, return to previous\n      player window. After final\n      investigator resolves engaged\n      enemy attacks, proceed to\n      next player window.\n\n> PLAYER WINDOW <\n\n    3.4 Enemy phase ends.'
  params.width = 600
  params.height = 600
  self.createButton(params)
end

function toPhaseFour()
  self.setState(4)
end