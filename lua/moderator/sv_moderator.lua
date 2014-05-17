include("sh_util.lua")
include("sh_moderator.lua")

AddCSLuaFile("sh_util.lua")
AddCSLuaFile("sh_moderator.lua")

util.AddNetworkString("mod_NotifyAction")
util.AddNetworkString("mod_Notify")
util.AddNetworkString("mod_AdminMessage")
util.AddNetworkString("mod_AllMessage")

function moderator.NotifyAction(client, target, action)
	local hasNoTarget = target == nil

	net.Start("mod_NotifyAction")
		net.WriteUInt(IsValid(client) and client:EntIndex() or 0, 4)

		if (type(target) != "table") then
			target = {target}
		end

		net.WriteTable(target)
		net.WriteString(action)
		net.WriteBit(hasNoTarget)
	net.Broadcast()
end

function moderator.Notify(receiver, message)
	net.Start("mod_Notify")
		net.WriteString(message)
	if (receiver) then
		if (type(receiver) == "Entity" and !IsValid(receiver)) then
			return MsgN("[moderator] "..message:sub(1, 1):upper()..message:sub(2))
		end

		net.Send(receiver)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerSay", "mod_PlayerSay", function(client, text)
	if (text:sub(1, 1) == "!") then
		text = text:sub(2)

		if (text:sub(1, 4):lower() == "menu") then
			client:ConCommand("mod_menu")

			return ""
		end

		if (text:sub(1, 4):lower() == "help") then
			client:ChatPrint("[moderator] Help has been printed in your console.")
			client:ConCommand("mod help")

			return ""
		end
		
		local command = text:match("([_%w]+)")

		if (command) then
			command = command:lower()
			
			local arguments = text:sub(#command + 1)
			local result, message = moderator.ParseCommand(client, command, arguments)

			if (message) then
				moderator.Notify(client, message..".")
			end
		end

		return ""
	elseif (text:sub(1, 1) == "@") then
		local players = moderator.GetPlayersByGroup("moderator")
		players[#players + 1] = client

		text = text:sub(2)

		if (text:sub(1, 1) == " ") then
			text = text:sub(2)
		elseif (text:sub(1, 1) == "@" and client:CheckGroup("moderator")) then
			text = text:sub(2)

			if (text:sub(1, 1) == " ") then
				text = text:sub(2)
			end

			net.Start("mod_AllMessage")
				net.WriteUInt(client:EntIndex(), 8)
				net.WriteString(text)
			net.Broadcast()

			return ""
		end

		net.Start("mod_AdminMessage")
			net.WriteUInt(client:EntIndex(), 8)
			net.WriteString(text)
		net.Send(players)

		return ""
	end
end)