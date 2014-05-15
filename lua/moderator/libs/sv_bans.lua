moderator.bans = moderator.bans or {}

util.AddNetworkString("mod_BanList")
util.AddNetworkString("mod_BanAdd")
util.AddNetworkString("mod_BanRemove")
util.AddNetworkString("mod_BanAdjust")

hook.Add("Initialize", "mod_BanLoader", function()
	file.CreateDir("moderator")

	local bans = von.deserialize(file.Read("moderator/bans.txt", "DATA") or "")

	if (bans) then
		for k, v in pairs(bans) do
			if (v.length > 0 and (v.date + v.length) <= os.time()) then
				bans[k] = nil
			end
		end

		moderator.bans = bans
	end
end)

function moderator.SaveBans()
	file.CreateDir("moderator")

	for k, v in pairs(moderator.bans) do
		if (v.length > 0 and (v.date + v.length) <= os.time()) then
			moderator.bans[k] = nil
		end
	end

	file.Write("moderator/bans.txt", von.serialize(moderator.bans))
end

hook.Add("ShutDown", "mod_BanSaver", function()
	moderator.SaveBans()
end)

local timeData = {
	{"y", 60 * 60 * 24 * 365},
	{"mo", 60 * 60 * 24 * 30},
	{"w", 60 * 60 * 24 * 7},
	{"d", 60 * 60 * 24},
	{"h", 60 * 60},
	{"m", 60},
	{"s", 1}
}

function moderator.GetTimeByString(data)
	if (!data) then
		return 0
	end

	data = string.lower(data)

	local time = 0

	for i = 1, #timeData do
		local info = timeData[i]

		data = string.gsub(data, "(%d+)"..info[1], function(match)
			local amount = tonumber(match)

			if (amount) then
				time = time + (amount * info[2])
			end

			return ""
		end)
	end

	local seconds = tonumber(string.match(data, "(%d+)")) or 0

	time = time + seconds

	return math.max(time, 0)
end

function moderator.BanPlayer(client, reason, length, admin)
	if (!client) then return end
	
	if (type(length) == "string") then
		length = moderator.GetTimeByString(length)
	end

	local name
	local steamID64

	if (type(client) == "Player") then
		local kickReason = "You have been "..(length == 0 and "permanently" or "temporarily").." banned from this server"

		if (IsValid(admin)) then
			kickReason = kickReason.." by "..admin:Name().." ("..admin:SteamID()..")"
		end

		kickReason = kickReason.." for "..reason

		local steamID = client:SteamID()
			name = client:Name()
			client:Kick(kickReason)
		client = steamID
	else
		name = client
	end
	
	moderator.bans[client] = {
		name = name,
		reason = reason,
		date = os.time(),
		length = length,
		admin = IsValid(admin) and admin:Name() or "Console"
	}

	moderator.SaveBans()
	moderator.SendBans(client)

	return length
end

function moderator.RemoveBan(steamID)
	moderator.bans[steamID] = nil
	moderator.SaveBans()

	local players = moderator.GetPlayersByGroup("moderator")

	if (#players > 0) then
		net.Start("mod_BanRemove")
			net.WriteString(steamID)
		net.Send(players)
	end
end

function moderator.SendBans(steamID)
	local players = moderator.GetPlayersByGroup("moderator")
	local ban = moderator.bans[steamID]

	if (!ban) then return end

	net.Start("mod_BanAdd")
		net.WriteString(steamID)
		net.WriteString(von.serialize(ban))
	net.Send(players)
end

function moderator.AdjustBan(steamID, key, value)
	if (moderator.bans[steamID]) then
		moderator.bans[steamID][key] = value

		local players = moderator.GetPlayersByGroup("moderator")

		if (#players > 0) then
			net.Start("mod_BanAdjust")
				net.WriteString(steamID)
				net.WriteString(key)
				net.WriteType(value)
			net.Send(players)
		end

		moderator.SaveBans()
	end
end

net.Receive("mod_BanAdjust", function(length, client)
	if (!client:CheckGroup("superadmin")) then return end

	local steamID = net.ReadString()
	local key = net.ReadString()
	local index = net.ReadUInt(8)
	local value = net.ReadType(index)

	if (key == "length") then
		value = moderator.GetTimeByString(value)
	end

	moderator.AdjustBan(steamID, key, value)
end)

net.Receive("mod_BanRemove", function(length, client)
	if (!client:CheckGroup("superadmin")) then return end

	moderator.RemoveBan(net.ReadString())
end)

hook.Add("PlayerInitialSpawn", "mod_BanList", function(client)
	timer.Simple(1, function()
		if (!IsValid(client)) then return end

		if (client:CheckGroup("moderator")) then
			net.Start("mod_BanList")
				net.WriteTable(moderator.bans)
			net.Send(client)
		end
	end)
end)

gameevent.Listen("player_connect")

hook.Add("player_connect", "mod_Guardian", function(data)
	local ban = moderator.bans[data.networkid]

	if (ban) then
		if (ban.length == 0 or (ban.date + ban.length) > os.time()) then
			local reason = "You have been banned from this server for: "..ban.reason..". "

			if (ban.length > 0) then
				reason = reason.."Your ban will expire in "..string.NiceTime((ban.date + ban.length) - os.time())
			else
				reason = reason.."Your ban will not expire."
			end

			game.ConsoleCommand("kickid "..data.userid.." "..reason.."\n")
		else
			moderator.bans[data.networkid] = nil
			moderator.SaveBans()
		end
	end
end)