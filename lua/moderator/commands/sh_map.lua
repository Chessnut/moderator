--[[
	Moderator Map Command
	Last Updated: 10/31/2015
	Purpose: A command that allows the client to change the map to an existing one on the server.
]]

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
		
		if map && file.Exists("maps/"..map..".bsp", "GAME") && map != currentmap then -- Need to see if the file exists naturally, and we also need to check to see if the current map is the one they're trying to change it to.
			moderator.NotifyAction(client, nil, "has changed the map to "..map)
			
			timer.Simple(0.5, function() -- We do a timer just to add a slight delay.
				RunConsoleCommand("changelevel", map)
			end)
		elseif map == currentmap then
			client:ChatPrint("You can't change the map to the map we're already on!")
		else -- If all else fails, the map just doesn't exist.
			client:ChatPrint("That is not a valid map!")
		end
	end
moderator.commands.map = COMMAND