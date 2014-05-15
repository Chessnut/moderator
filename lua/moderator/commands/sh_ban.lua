local COMMAND = {}
	COMMAND.name = "Ban"
	COMMAND.tip = "Bans a person from the server."
	COMMAND.icon = "delete"
	COMMAND.limitFind = 1
	COMMAND.usage = "<time length> [string reason]"
	COMMAND.example = "!ban Troll 1w \"being a troll, banned for a week\" - Bans a troll for one week."

	function COMMAND:OnRun(client, arguments, target)
		local time = moderator.GetTimeByString(arguments[1] or 60)
		local reason = arguments[2] or "no reason"

		local function Action(target)
			moderator.BanPlayer(target, reason, time, client)
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		time = moderator.GetTimeByString(time)
		local timeString = time > 0 and "for "..string.NiceTime(time) or "permanently"

		moderator.NotifyAction(client, target, "has banned * "..timeString.." with the reason: "..reason)
	end

	if (CLIENT) then
		local timeDefinitions = {
			{"1 Hour", "1h"},
			{"1 Day", "1d"},
			{"1 Week", "1w"},
			{"1 Month", "1mo"},
			{"1 Year", "1y"},
			{"Permanently", "0"}
		}

		local reasons = {
			"Harrassment",
			"Breaking a rule",
			"Spamming"
		}
		local history = util.JSONToTable(cookie.GetString("mod_BanReasons", "")) or {}

		function COMMAND:OnClick()
			local menu = self.menu

			for i = 1, #timeDefinitions do
				local time = menu:AddSubMenu(timeDefinitions[i][1])
				local reasonsMenu = time:AddSubMenu("Reasons")

				for i2 = 1, #reasons do
					reasonsMenu:AddOption(reasons[i2], function()
						self:Send(timeDefinitions[i][2], reasons[i2])
					end)
				end

				local historyMenu = time:AddSubMenu("History")

				for i2 = 1, #history do
					historyMenu:AddOption(history[i2], function()
						self:Send(timeDefinitions[i][2], history[i2])
					end)
				end

				time:AddOption("Specify", function()
					Derma_StringRequest("Specify Reason", "Specify a reason in the box below.", "", function(text)
						self:Send(timeDefinitions[i][2], text)

						table.insert(history, text)
						cookie.Set("mod_BanReasons", util.TableToJSON(history))
					end)
				end)
			end

			menu:AddOption("Specify", function()
				Derma_StringRequest("Specify Time", "Specify a ban time in the box below.", "", function(time)
					Derma_StringRequest("Specify Reason", "Specify a ban reason in the box below.", "", function(text)
						self:Send(time, text)

						table.insert(history, text)
						cookie.Set("mod_BanReasons", util.TableToJSON(history))
					end)
				end)
			end)
		end
	end
moderator.commands.ban = COMMAND

local COMMAND = {}
	COMMAND.name = "Unban"
	COMMAND.tip = "Removes a ban from the ban list."
	COMMAND.hidden = true
	COMMAND.noTarget = true

	function COMMAND:OnRun(client, arguments)
		local steamID = arguments[1]

		if (!steamID or !steamID:match("STEAM_[0-5]:[0-9]:[0-9]+")) then
			return false, "you need to provide a valid SteamID."
		end

		moderator.RemoveBan(steamID)
	end
moderator.commands.unban = COMMAND
