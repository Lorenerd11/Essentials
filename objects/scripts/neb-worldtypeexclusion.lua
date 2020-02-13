function init()
  self.excludedWorldTypes = config.getParameter("excludedWorldTypes", {"protectorate"})
  
  for _,excludedWorldType in pairs(self.excludedWorldTypes) do
	--sb.logInfo("Excluded world: %s", excludedWorldType)
    --sb.logInfo("Current World Type is: %s", world.type())
	if excludedWorldType == world.type() then
	else
	  for parameter,value in pairs(config.getParameter("alternativeParameters")) do
		object.setConfigParameter(parameter, value)
	  end
	end
  end
end

function update()
end

function showBeamaxe()
end