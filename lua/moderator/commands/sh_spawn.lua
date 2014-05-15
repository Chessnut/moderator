local COMMAND = {}
	COMMAND.name = "Spawn Player"
	COMMAND.tip = "Spawns a player whether or not they are alive."
	COMMAND.icon = "lightbulb"
	COMMAND.example = "!spawn #dead - Spawns everyone who is dead."
	COMMAND.aliases = {"revive"}

	function COMMAND:OnRun(client, arguments, target)
		local function Action(target)
			target:Spawn()
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has spawned")
	end
moderator.commands.spawn = COMMAND