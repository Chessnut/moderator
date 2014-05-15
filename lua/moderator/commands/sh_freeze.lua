local COMMAND = {}
	COMMAND.name = "Toggle Freeze"
	COMMAND.tip = "Freezes or thaws a player at their position."
	COMMAND.icon = "lock"
	COMMAND.aliases = {"lock", "unfreeze", "thaw"}
	COMMAND.example = "!freeze Bot01 0 - Unfreezes Bot01."

	function COMMAND:OnRun(client, arguments, target, alias)
		local force

		if (arguments[1]) then
			force = util.tobool(arguments[1])
		end

		if (alias == "unfreeze" or alias == "thaw") then
			force = false
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				if (force != nil) then
					v:Freeze(force)
				else
					v:Freeze(!v:IsFrozen())
				end
			end
		else
			if (force != nil) then
				target:Freeze(force)
			else
				target:Freeze(!target:IsFrozen())
			end
		end

		if (force != nil) then
			moderator.NotifyAction(client, target, "has "..(force and "frozen" or "thawed"))
		else
			moderator.NotifyAction(client, target, "has toggle frozen")
		end
	end
moderator.commands.freeze = COMMAND