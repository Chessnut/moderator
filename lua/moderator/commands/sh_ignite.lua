local COMMAND = {}
	COMMAND.name = "Ignite"
	COMMAND.tip = "Sets a player on fire for a certain amount of time."
	COMMAND.icon = "fire"
	COMMAND.usage = "[number length]"
	COMMAND.example = "!ignite #all 1337 - Ignites everyone for 1337 seconds."

	function COMMAND:OnRun(client, arguments, target)
		local specified = arguments[1] != nil
		local time = math.max(tonumber(arguments[1]) or 30, 1)

		local function Action(target)
			target:Ignite(time)
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		if (specified) then
			moderator.NotifyAction(client, target, "has ignited * for "..time.." second"..(time == 1 and "" or "s"))
		else
			moderator.NotifyAction(client, target, "has ignited")
		end
	end
moderator.commands.ignite = COMMAND

local COMMAND = {}
	COMMAND.name = "Extinguish"
	COMMAND.tip = "Extinguishes a player so they are not on fire."
	COMMAND.icon = "water"
	COMMAND.aliases = {"unignite"}

	function COMMAND:OnRun(client, arguments, target)
		local function Action(target)
			target:Extinguish()
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has extinguished")
	end
moderator.commands.extinguish = COMMAND