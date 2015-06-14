local COMMAND = {}
	COMMAND.name = "Map"
	COMMAND.icon = "map"
	COMMAND.hidden = true
	COMMAND.noTarget = true
	COMMAND.usage = "<string map>"
	COMMAND.example = "!map map - Set the current map."

	function COMMAND:OnRun(client, arguments)
		local map = arguments[1]
		local currentmap = game.GetMap()
		
		if map && file.Exists("maps/"..map..".bsp", "GAME") then
			moderator.NotifyAction(client, nil, "has changed the map to "..map)
			
			timer.Simple(0.5, function()
				RunConsoleCommand("changelevel", map)
			end)
		elseif map == currentmap then
			client:ChatPrint("You can't change the map to the map we're already on!")
		else
			client:ChatPrint("That is not a valid map!")
		end
	end
moderator.commands.map = COMMAND