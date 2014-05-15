local COMMAND = {}
	COMMAND.name = "Toggle Noclip"
	COMMAND.tip = "Toggles whether or not a player has noclip."
	COMMAND.targetIsOptional = true
	COMMAND.icon = "layers"
	COMMAND.usage = "[bool enabled]"
	COMMAND.example = "!noclip #alive - Makes everyone who is alive in noclip mode."

	function COMMAND:OnRun(client, arguments, target)
		if (!IsValid(target)) then
			target = client
		end

		local force

		if (arguments[1] != nil) then
			force = util.tobool(arguments[1])
		end
		
		local function Action(target)
			if (force) then
				target:SetMoveType(force and MOVETYPE_NOCLIP or MOVETYPE_WALK)
			else
				target:SetMoveType(target:GetMoveType() == MOVETYPE_NOCLIP and MOVETYPE_WALK or MOVETYPE_NOCLIP)
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		if (force != nil) then
			moderator.NotifyAction(client, target, "has "..(force and "enabled" or "disabled").." noclip for")
		else
			moderator.NotifyAction(client, target, "has toggled noclip for")
		end
	end
moderator.commands.noclip = COMMAND