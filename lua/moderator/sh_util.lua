function moderator.Include(fileName)
	if (fileName:find("sv_") and SERVER) then
		include(fileName)
	elseif (fileName:find("cl_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	elseif (fileName:find("sh_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		include(fileName)
	end
end

function moderator.IncludeFolder(folder)
	for k, v in pairs(file.Find("moderator/"..folder.."/*.lua", "LUA")) do
		moderator.Include(folder.."/"..v)
	end
end

moderator.IncludeFolder("libs/external")

function moderator.StringMatches(a, b)
	if (a == b) then return true end
	if (a:find(b, nil, true)) then return true end

	a = a:lower()
	b = b:lower()

	if (a == b) then return true end
	if (a:find(b, nil, true)) then return true end

	return false
end

function moderator.FindPlayerByName(name, onlyTableReturns, limit)
	local found = {}
	local i = 0

	for k, v in pairs(player.GetAll()) do
		if (limit and i > limit) then
			break
		end

		if (moderator.StringMatches(v:Name(), name)) then
			found[#found + 1] = v
			i = i + 1
		end
	end

	if (!onlyTableReturns and #found == 1) then
		return found[1]
	elseif (#found > 0) then
		return found
	end
end

function moderator.TableToList(info, word, hasNoTarget)
	word = word or "and"

	local output = {}
	local index = 1
	local maximum = table.Count(info)

	if (maximum == 0 and !hasNoTarget) then
		output[#output + 1] = color_white
		output[#output + 1] = "no one"

		return output
	end

	if (maximum > 1 and maximum == #player.GetAll()) then
		output[#output + 1] = color_white
		output[#output + 1] = "everyone"

		return output
	end

	if (maximum > 0) then
		for k, v in pairs(info) do
			local isLast = index == maximum

			if (isLast and maximum > 1) then
				output[#output + 1] = color_white
				output[#output + 1] = word.." "
			end

			if (v == LocalPlayer()) then
				output[#output + 1]	= team.GetColor(v:Team())
				output[#output + 1] = "you"
			else
				output[#output + 1] = v
			end

			if (!isLast) then
				if (table.Count(info) > 2) then
					output[#output + 1] = color_white
					output[#output + 1] = ", "
				else
					output[#output + 1] = " "
				end
			end

			index = index + 1
		end
	end

	output[#output + 1] = color_white

	return output
end

moderator.data = moderator.data or {}

function moderator.SetData(key, value, noSave)
	moderator.data[key] = value

	if (!noSave) then
		file.CreateDir("moderator")
		file.Write("moderator/"..key..".txt", util.Compress(von.serialize(moderator.data)))
	end
end

function moderator.SplitStringByLength(value, length)
	local output = {}

	while (#value > length) do
		output[#output + 1] = value:sub(1, length)
		value = value:sub(length + 1)
	end

	if (value != "") then
		output[#output + 1] = value
	end

	return output
end

function moderator.GetData(key, default, noCache)
	if (noCache or moderator.data[key] == nil) then
		local contents = file.Read("moderator/"..key..".txt", "DATA")

		if (contents and contents != "") then
			local deserialized = von.deserialize(util.Decompress(contents))

			if (deserialized[key] != nil) then
				moderator.data[key] = deserialized[key]

				return deserialized[key]
			end
		end
	elseif (moderator.data[key] != nil) then
		return moderator.data[key]
	end

	return default
end