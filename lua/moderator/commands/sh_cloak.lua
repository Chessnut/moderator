local COMMAND = {}
	COMMAND.name = "Toggle Cloak"
	COMMAND.tip = "Toggles whether or not a player is hidden."
	COMMAND.icon = "eye"
	COMMAND.usage = "[bool enabled]"
	COMMAND.example = "!cloak Ghost 1 - Makes the player 'Ghost' invisible."

	function COMMAND:OnRun(client, arguments, target)
		local force

		if (arguments[1] != nil) then
			force = util.tobool(arguments[1])
		end

		local function Action(target)
			target:SetNoDraw(!target:GetNoDraw())
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		if (force != nil) then
			moderator.NotifyAction(client, target, "has "..(!force and "un" or "").."cloaked")
		else
			moderator.NotifyAction(client, target, "toggled cloaking for")
		end
	end
moderator.commands.cloak = COMMAND