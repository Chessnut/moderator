local COMMAND = {}
	COMMAND.name = "Toggle Godmode"
	COMMAND.tip = "Toggles whether or not a player has godmode."
	COMMAND.icon = "star"
	COMMAND.usage = "[bool enabled]"
	COMMAND.example = "!god #me 1 - Forces godmode on you."

	function COMMAND:OnRun(client, arguments, target)
		local force

		if (arguments[1] != nil) then
			force = util.tobool(arguments[1])
		end

		local function Action(target)
			target.modGod = forced != nil and forced or !target.modGod

			if (target.modGod) then
				target:GodEnable()
			else
				target:GodDisable()
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
			moderator.NotifyAction(client, target, "has "..(force and "enabled" or "disabled").." godmode for")
		else
			moderator.NotifyAction(client, target, "has toggled godmode for")
		end
	end
moderator.commands.god = COMMAND