moderator.commands = moderator.commands or {}

if (SERVER) then
	util.AddNetworkString("mod_Command")

	function moderator.GetArguments(text, noArrays, delimiter)
		delimiter = delimiter or " "

		local arguments = {}
		local curString = ""
		local inString = false
		local escaping = 0
		local inArray = false

		for i = 1, #text do
			local char = text:sub(i, i)

			if (escaping > i) then
				continue
			end

			if (char == "\\") then
				escaping = i + 1
			elseif (!noArrays and !inString and char == "[") then
				local match = text:sub(i):match("%b[]")

				if (match) then
					local exploded = moderator.GetArguments(match:sub(2, -2), nil, ",")

					for k, v in pairs(exploded) do
						if (type(v) == "string" and (v:sub(1, 1) == " " or v:sub(1, 1) == delimiter)) then
							exploded[k] = v:sub(2)
						end
					end

					arguments[#arguments + 1] = exploded
					curString = ""
					escaping = i + #match
				end
			elseif (char == "'" or char == "\"") then
				if (inString) then
					arguments[#arguments + 1] = curString
					curString = ""
					inString = false
				else
					inString = true
				end
			elseif (inString) then
				curString = curString..char
			elseif (char == delimiter and curString != "" and !inString) then
				arguments[#arguments + 1] = curString
				curString = ""
			elseif (char != " " and char != delimiter) then
				curString = curString..char
			end
		end

		if (curString != "") then
			arguments[#arguments + 1] = curString
		end

		return arguments
	end

	local targetPrefix = "#"
	local targets = {}
	targets["this"] = function(client)
		local target = client:GetEyeTraceNoCursor().Entity

		if (IsValid(target) and target:IsPlayer()) then
			return target
		end
	end
	targets["all"] = function(client)
		return player.GetAll()
	end
	targets["alive"] = function(client)
		local target = {}

		for k, v in pairs(player.GetAll()) do
			if (v:Alive()) then
				target[#target + 1] = v
			end
		end

		return target
	end
	targets["dead"] = function(client)
		local target = {}

		for k, v in pairs(player.GetAll()) do
			if (!v:Alive()) then
				target[#target + 1] = v
			end
		end

		return target
	end
	targets["rand"] = function(client)
		return table.Random(player.GetAll())
	end
	targets["random"] = targets["rand"]
	targets["me"] = function(client)
		return client
	end
	targets["last"] = function(client)
		return client.modLastTarget
	end

	local function GetTargeter(client, info)
		if (info and info:sub(1, 1) == targetPrefix) then
			local targeter = info:lower():sub(2):match("([_%w]+)")
			local result = targets[targeter]

			if (result) then
				return result(client)
			else
				local players = {}

				for k, v in pairs(player.GetAll()) do
					if (moderator.StringMatches(v:GetNWString("usergroup", "user"), targeter)) then
						players[#players + 1] = v
					end
				end

				if (#players > 0) then
					return players
				end
			end
		end
	end

	function moderator.FindCommandTable(command)
		local commandTable = moderator.commands[command]
		local alias

		if (!commandTable) then
			local aliases = {}

			for k, v in pairs(moderator.commands) do
				if (v.aliases) then
					for k2, v2 in pairs(v.aliases) do
						aliases[v2] = k
					end
				end
			end

			if (aliases[command]) then
				alias = command
			end

			command = aliases[command]
			commandTable = moderator.commands[command]
		end

		return commandTable, command, alias
	end

	function moderator.ParseCommand(client, command, arguments)
		local commandTable, command, alias = moderator.FindCommandTable(command)

		if (commandTable) then
			if (!moderator.HasPermission(command, client)) then
				return false, "you are not allowed to use this command"
			end

			arguments = moderator.GetArguments(arguments, commandTable.noArrays)

			local target
			local targetIsArgument

			if (!commandTable.noTarget) then
				target = arguments[1]

				if (type(target) == "table") then
					for i = 1, #target do
						local name = target[i]

						if (type(name) != "string") then
							continue
						end

						local result = GetTargeter(client, name)

						if (result) then
							if (type(result) == "table") then
								target[i] = nil
								table.Add(target, result)
								continue
							else
								target[i] = result
								continue
							end
						end

						local found = moderator.FindPlayerByName(name, nil, commandTable.findLimit)

						if (IsValid(found) and moderator.HasInfluence(client, found, commandTable.strictTargetting)) then
							target[i] = found
						else
							target[i] = nil
						end
					end

					if (table.Count(target) == 0) then
						if (commandTable.targetIsOptional) then
							targetIsArgument = true
						else
							return false, "you are not allowed to target any of these players"
						end
					end
				elseif (target) then
					local result = GetTargeter(client, target)

					if (result) then
						target = result
					else
						target = moderator.FindPlayerByName(target, nil, commandTable.findLimit)
					end

					if (type(target) == "table") then
						for k, v in pairs(target) do
							if (!moderator.HasInfluence(client, v, commandTable.strictTargetting)) then
								target[k] = nil
							end
						end

						if (table.Count(target) == 0) then
							if (commandTable.targetIsOptional) then
								targetIsArgument = true
							else
								return false, "you are not allowed to target any of these players"
							end
						end							
					else
						if (IsValid(target)) then
							if (!moderator.HasInfluence(client, target, commandTable.strictTargetting)) then
								return false, "you are not allowed to target this player"
							end
						elseif (!commandTable.targetIsOptional) then
							return false, "you provided an invalid player"
						end
					end
				elseif (!commandTable.targetIsOptional) then
					return false, "you provided an invalid player"
				end

				if (!targetIsArgument) then
					table.remove(arguments, 1)
				end
			end

			moderator.RunCommand(client, command, arguments, target, alias)
		else
			return false, "you have entered an invalid command"
		end

		return true
	end

	function moderator.RunCommand(client, command, arguments, target, alias)
		local commandTable = moderator.commands[command]

		if (commandTable) then
			if (!moderator.HasPermission(command, client)) then
				return moderator.Notify(client, "you are not allowed to do that.")
			end

			if (client:GetInfoNum("mod_clearoncommand", 1) > 0) then
				client:ConCommand("mod_clearselected")
			end

			local result, message = commandTable:OnRun(client, arguments, target, alias)
			client.modLastTarget = target

			if (result == false) then
				moderator.Notify(client, message)
			end
		else
			moderator.Notify(client, "you have entered an invalid command.")
		end
	end

	net.Receive("mod_Command", function(length, client)
		local command = net.ReadString()
		local arguments = net.ReadTable()
		local target = net.ReadTable()

		if (#target == 1) then
			target = target[1]
		end
		
		moderator.RunCommand(client, command, arguments, target)
	end)

	concommand.Add("mod", function(client, command, arguments)
		if (arguments[1] == "menu") then
			return client:ConCommand("mod_menu")
		end
		
		local command = arguments[1]
		table.remove(arguments, 1)

		if (command and command != "help") then
			command = command:lower()
			
			local result, message = moderator.ParseCommand(client, command, table.concat(arguments, " "))

			if (message) then
				moderator.Notify(client, message..".")
			end
		elseif ((client.modNextHelp or 0) < CurTime()) then
			client.modNextHelp = CurTime() + 5

			local command = arguments[1]

			if (command) then
				local commandTable, command = moderator.FindCommandTable(command:lower())

				if (commandTable) then
					local usage = commandTable.usage or "[none]"

					if (!commandTable.usage and !commandTable.noTarget) then
						usage = "<player> "..usage
					end

					client:PrintMessage(2, "\n\n [moderator] Command Help for: "..command)
					client:PrintMessage(2, " \t• Name: "..(commandTable.name or "No name available."))
					client:PrintMessage(2, " \t• Description: "..(commandTable.tip or "No description available."))
					client:PrintMessage(2, " \t• Usage: "..usage)

					if (commandTable.example) then
						client:PrintMessage(2, " \t• Example: "..commandTable.example)
					end

					if (commandTable.aliases) then
						client:PrintMessage(2, " \t• Alias"..(#commandTable.aliases > 0 and "es" or "")..": "..table.concat(commandTable.aliases, ", "))
					end
				else
					client:PrintMessage(2, " [moderator] That command does not exist.")
				end

				return
			end

			client:PrintMessage(2, [[
       __   __   ___  __       ___  __   __  
 |\/| /  \ |  \ |__  |__)  /\   |  /  \ |__) 
 |  | \__/ |__/ |___ |  \ /--\  |  \__/ |  \ 
 Created by Chessnut - Version ]]..moderator.version..[[                         
			]])
			client:PrintMessage(2, " Command Help:")

			for k, v in SortedPairsByMemberValue(moderator.commands, "name") do
				if (moderator.HasPermission(k, client)) then
					client:PrintMessage(2, " "..k.."			"..(v.tip or "No help available."))
				end
			end

			client:PrintMessage(2, "\n Type 'mod help <command>' to get help with a specific command.\n\n")
		end
	end)
else
	function moderator.SendCommand(command, target, ...)
		if (type(target) != "table") then
			target = {target}
		end

		net.Start("mod_Command")
			net.WriteString(command)
			net.WriteTable({...})
			net.WriteTable(target)
		net.SendToServer()
	end
end