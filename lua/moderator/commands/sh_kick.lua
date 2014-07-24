local COMMAND = {}
	COMMAND.name = "Kick Player"
	COMMAND.tip = "Kicks a player from the server."
	COMMAND.icon = "door_open"
	COMMAND.usage = "[string reason]"
	COMMAND.example = "!kick Troll trolling - Kicks the player 'Troll' for trolling."

	function COMMAND:OnRun(client, arguments, target)
		local reason = "no reason"

		if (#arguments > 0) then
			reason = table.concat(arguments, " ")
		end

		local oldReason = reason
		reason = "You have been kicked by "..(IsValid(client) and client:Name() or "Console").." for "..reason

		if (type(target) == "table") then
			moderator.NotifyAction(client, target, "has kicked * for "..oldReason)
			
			for k, v in pairs(target) do
				v:Kick(reason)
			end
		else
			moderator.NotifyAction(client, target, "has kicked * for "..oldReason)
			target:Kick(reason)
		end
	end

	if (CLIENT) then
		local reasons = {
			"Harrassment",
			"Breaking a rule",
			"Spamming"
		}
		local history = util.JSONToTable(cookie.GetString("mod_KickReasons", "")) or {}

		function COMMAND:OnClick()
			local menu = self.menu
			local menu2 = menu:AddSubMenu("Reasons")

			for i = 1, #reasons do
				local reason = reasons[i]

				menu2:AddOption(reason, function()
					self:Send(reason:lower())
				end)
			end

			menu2 = menu:AddSubMenu("History")

			for i = 1, #history do
				local reason = history[i]

				menu2:AddOption(reason, function()
					self:Send(reason:lower())
				end)
			end

			menu:AddOption("No reason", function()
				self:Send()
			end)
			menu:AddOption("Specify", function()
				Derma_StringRequest("Specify Reason", "Specify a reason in the box below.", "", function(text)
					self:Send(text)

					table.insert(history, text)
					cookie.Set("mod_KickReasons", util.TableToJSON(history))
				end)
			end)
		end
	end
moderator.commands.kick = COMMAND