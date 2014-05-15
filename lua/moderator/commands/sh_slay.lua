local COMMAND = {}
	COMMAND.name = "Slay"
	COMMAND.tip = "Slays the specified target."
	COMMAND.icon = "bin"
	COMMAND.example = "!slay #alive - Slays everyone who is alive."
	COMMAND.aliases = {"kill"}

	function COMMAND:OnRun(client, arguments, target)
		local force

		if (arguments[1] != nil) then
			force = util.tobool(arguments[1])
		end

		local function Action(target)
			if (force) then
				target:KillSilent()
			else
				target:Kill()
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has slayed")
	end
moderator.commands.slay = COMMAND