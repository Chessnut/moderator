include("sh_util.lua")
include("sh_moderator.lua")

CreateClientConVar("mod_clearoncommand", "1", true, true)

if (IsValid(moderator.menu)) then
	moderator.menu:Close()
	moderator.menu = nil
	moderator.menu = vgui.Create("mod_Menu")
	MsgN("Reloaded moderator panel.")
end

net.Receive("mod_NotifyAction", function(length)
	local client = player.GetByID(net.ReadUInt(4))

	if (!IsValid(client)) then
		return
	end

	local target = net.ReadTable()
	local action = net.ReadString()
	local hasNoTarget = net.ReadBit() == 1
	local output = {client, color_white, " "}

	if (action:find("*", nil, true)) then
		local exploded = string.Explode("*", action)

		output[#output + 1] = exploded[1]
		table.Add(output, moderator.TableToList(target))
		output[#output + 1] = exploded[2]
	else
		output[#output + 1] = action.." "
		table.Add(output, moderator.TableToList(target, nil, hasNoTarget))
	end

	output[#output + 1] = "."
	chat.AddText(unpack(output))
end)

net.Receive("mod_Notify", function(length)
	chat.AddText(LocalPlayer(), color_white, ", "..net.ReadString())
end)

do
	moderator.bans = moderator.bans or {}

	net.Receive("mod_BanList", function()
		moderator.bans = net.ReadTable()
	end)

	net.Receive("mod_BanAdd", function()
		local steamID = net.ReadString()
		local data = net.ReadString()

		moderator.bans[steamID] = von.deserialize(data)
		moderator.updateBans = true
	end)

	net.Receive("mod_BanRemove", function()
		local steamID = net.ReadString()

		moderator.bans[steamID] = nil
		moderator.updateBans = true
	end)

	net.Receive("mod_BanAdjust", function()
		local steamID = net.ReadString()
		local key = net.ReadString()
		local index = net.ReadUInt(8)
		local value = net.ReadType(index)

		if (moderator.bans[steamID]) then
			moderator.bans[steamID][key] = value
			moderator.updateBans = true
		end
	end)

	function moderator.AdjustBan(steamID, key, value)
		if (!LocalPlayer():CheckGroup("superadmin")) then return end

		net.Start("mod_BanAdjust")
			net.WriteString(steamID)
			net.WriteString(key)
			net.WriteType(value)
		net.SendToServer()
	end
end

do
	net.Receive("mod_AdminMessage", function(length)
		chat.AddText(Color(255, 50, 50), "[ADMIN] ", player.GetByID(net.ReadUInt(8)), color_white, ": "..net.ReadString())
	end)

	net.Receive("mod_AllMessage", function(length)
		chat.AddText(Color(255, 50, 50), "[ALL] ", player.GetByID(net.ReadUInt(8)), color_white, ": "..net.ReadString())
	end)
end