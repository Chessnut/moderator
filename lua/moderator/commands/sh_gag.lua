local COMMAND = {}
	COMMAND.name = "Toggle Gag"
	COMMAND.tip = "Toggles whether or not a player is able to chat."
	COMMAND.icon = "user_comment"
	COMMAND.usage = "[bool gagged]"
	COMMAND.example = "!gag #all 1 - Gags everyone."

	function COMMAND:OnRun(client, arguments, target)
		local force

		if (arguments[1] != nil) then
			force = util.tobool(arguments[1])
		end

		local function Action(target)
			target.modGagged = forced != nil and forced or !target.modGagged
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		if (force != nil) then
			moderator.NotifyAction(client, target, "has "..(force and "gagged" or "ungagged"))
		else
			moderator.NotifyAction(client, target, "toggle gagged")
		end
	end

	hook.Add("PlayerSay", "mod_GagFilter", function(speaker, text)
		if (speaker.modGagged and text:sub(1, 1) != "!") then
			return ""
		end
	end)
moderator.commands.gag = COMMAND