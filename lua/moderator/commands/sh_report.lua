if (SERVER) then
	util.AddNetworkString("mod_ReportList")
	util.AddNetworkString("mod_ReportAdd")
	util.AddNetworkString("mod_ReportDelete")

	if (!moderator.reports) then
		moderator.reports = moderator.GetData("reports")
	end

	hook.Add("PlayerInitialSpawn", "mod_SendReports", function(client)
		timer.Simple(1, function()
			if (moderator.reports and table.Count(moderator.reports) > 0 and client:CheckGroup("moderator")) then
				net.Start("mod_ReportList")
					net.WriteTable(moderator.reports)
				net.Send(client)
			end
		end)
	end)

	net.Receive("mod_ReportDelete", function(length, client)
		if (!client:CheckGroup("moderator")) then return end

		local index = net.ReadUInt(16)

		moderator.reports[index] = nil
		moderator.SetData("reports", moderator.reports)

		local players = moderator.GetPlayersByGroup("moderator")

		if (#players > 0) then
			net.Start("mod_ReportDelete")
				net.WriteUInt(index, 16)
			net.Send(players)
		end
	end)
else
	net.Receive("mod_ReportList", function(length)
		moderator.reports = net.ReadTable()
	end)

	net.Receive("mod_ReportAdd", function(length)
		moderator.reports = moderator.reports or {}
		moderator.reports[net.ReadUInt(16)] = net.ReadTable()
		moderator.updateReports = true
	end)

	net.Receive("mod_ReportDelete", function(length)
		if (moderator.reports) then
			moderator.reports[net.ReadUInt(16)] = nil
			moderator.updateReports = true
		end
	end)
end

local COMMAND = {}
	COMMAND.name = "Report"
	COMMAND.tip = "Creates a new report for administrators to see."
	COMMAND.noTarget = true
	COMMAND.noArrays = true
	COMMAND.usage = "<string message>"
	COMMAND.example = "!report I am stuck - Tells all administrators you are stuck."
	COMMAND.hidden = true
	
	function COMMAND:OnRun(client, arguments)
		local text = table.concat(arguments, " "):sub(1, 250)

		if (#text < 5) then
			return false, "your report must be at least 5 characters long."
		end

		if ((client.modNextReport or 0) < CurTime()) then
			client.modNextReport = CurTime() + 60
		else
			return false, "you must wait "..math.ceil(client.modNextReport - CurTime()).." second(s) before making another report."
		end

		moderator.reports = moderator.reports or {}

		local players = moderator.GetPlayersByGroup("moderator")
		local report = {
			date = os.time(),
			text = text,
			steamID = client:SteamID()
		}
		local index = #moderator.reports + 1

		if (#players > 0) then
			net.Start("mod_ReportAdd")
				net.WriteUInt(index, 16)
				net.WriteTable(report)
			net.Send(players)

			for k, v in pairs(players) do
				moderator.Notify(v, client:Name().." has reported: "..text)
			end
		end

		moderator.reports[index] = report
		moderator.SetData("reports", moderator.reports)

		return false, "your report (#"..index..") has been sent and is awaiting review."
	end
moderator.commands.report = COMMAND