-- These groups just serve as a default group.
-- Do NOT edit these.
if (!moderator.groups) then
	moderator.groups = {}

	moderator.groups.owner = {
		immunity = 99,
		name = "Owner",
		access = true,
		icon = "key"
	}

	moderator.groups.superadmin = {
		name = "Super Admin",
		inherit = "admin",
		icon = "shield",
		immunity = 15
	}

	moderator.groups.admin = {
		name = "Admin",
		inherit = "moderator",
		icon = "star",
		access = {
			["arm"] = true,
			["armor"] = true,
			["ban"] = true,
			["cloak"] = true,
			["god"] = true,
			["health"] = true,
			["mute"] = true,
			["noclip"] = true,
			["spawn"] = true,
			["strip"] = true
		},
		immunity = 10
	}

	moderator.groups.moderator = {
		name = "Moderator",
		icon = "wrench",
		access = {
			["goto"] = true,
			["tp"] = true,
			["slay"] = true,
			["kick"] = true,
			["freeze"] = true,
			["return"] = true
		},
		inherit = "user",
		immunity = 5
	}

	moderator.groups.user = {
		name = "User",
		immunity = 0,
		access = {
			["report"] = true
		}
	}
end

moderator.defaultGroups = {}
moderator.defaultGroups["owner"] = true
moderator.defaultGroups["superadmin"] = true
moderator.defaultGroups["admin"] = true
moderator.defaultGroups["moderator"] = true
moderator.defaultGroups["user"] = true

moderator.templateGroup = {
	name = "New Group",
	immunity = 0,
	icon = "user"
}

if (SERVER) then
	moderator.groups = table.Merge(moderator.groups, moderator.GetData("groups", {}))

	util.AddNetworkString("mod_Groups")
	util.AddNetworkString("mod_GroupUpdate")
	util.AddNetworkString("mod_GroupCreate")
	util.AddNetworkString("mod_GroupDelete")

	hook.Add("PlayerInitialSpawn", "mod_SendGroups", function(client)
		net.Start("mod_Groups")
			net.WriteTable(moderator.groups)
		net.Send(client)
	end)

	net.Receive("mod_GroupUpdate", function(length, client)
		if (!client:CheckGroup("owner")) then
			return
		end

		local group = net.ReadString()
		local key = net.ReadString()
		local typeIndex = net.ReadUInt(8)
		local value = net.ReadType(typeIndex)

		moderator.UpdateGroup(group, key, value)
	end)

	function moderator.UpdateGroup(group, key, value)
		if (moderator.groups[group]) then
			if (key == "delete") then
				return moderator.DeleteGroup(group)
			elseif (key == "access") then
				local oldValue = value
					key, value = value[1], value[2]
						moderator.groups[group].access = moderator.groups[group].access or {}
						moderator.groups[group].access[key] = value
					key = "access"
				value = oldValue
			else
				moderator.groups[group][key] = value
			end

			net.Start("mod_GroupUpdate")
				net.WriteString(group)
				net.WriteString(key)
				net.WriteType(value)
			net.Broadcast()

			moderator.SetData("groups", moderator.groups)
		elseif (key == "create") then
			moderator.CreateGroup(group)
		end
	end

	function moderator.CreateGroup(group)
		moderator.groups[group] = table.Copy(moderator.templateGroup)
		moderator.SetData("groups", moderator.groups)

		net.Start("mod_GroupCreate")
			net.WriteString(group)
		net.Broadcast()
	end

	function moderator.DeleteGroup(group)
		if (moderator.defaultGroups[group]) then return end

		moderator.groups[group] = nil
		moderator.SetData("groups", moderator.groups)

		for k, v in pairs(player.GetAll()) do
			if (v:IsUserGroup(group)) then
				moderator.SetGroup(v, "user")
			end
		end

		net.Start("mod_GroupDelete")
			net.WriteString(group)
		net.Broadcast()
	end
else
	net.Receive("mod_GroupDelete", function(length)
		local key = net.ReadString()
		local menu = moderator.menu

		moderator.groups[key] = nil

		if (IsValid(menu) and menu.tabID == "groups") then
			if (menu.scroll.choices[key]) then
				table.remove(menu.scroll.choose.Choices, menu.scroll.choices[key])
			end

			if (moderator.lastGroup == key) then
				menu.scroll.choose:ChooseOptionID(1)
			end

			menu.scroll.content.VBar:AnimateTo(0, 0.5, 0, 0.5)
		end
	end)

	net.Receive("mod_GroupCreate", function(length)
		local key = net.ReadString()
		local menu = moderator.menu

		moderator.groups[key] = table.Copy(moderator.templateGroup)

		if (IsValid(menu) and menu.tabID == "groups") then
			menu.scroll.choose.Choices[#menu.scroll.choose.Choices] = nil
			menu.scroll.choices[key] = menu.scroll.choose:AddChoice(moderator.templateGroup.name, key, true)
			menu.scroll.choose:AddChoice("New...")
		end
	end)

	net.Receive("mod_Groups", function(length)
		moderator.groups = table.Merge(moderator.groups, net.ReadTable())
	end)

	net.Receive("mod_GroupUpdate", function()
		local group = net.ReadString()
		local key = net.ReadString()
		local typeIndex = net.ReadUInt(8)
		local value = net.ReadType(typeIndex)

		if (!moderator.groups[group]) then return end

		if (key == "access") then
			key, value = value[1], value[2]

			moderator.groups[group].access = moderator.groups[group].access or {}
			moderator.groups[group].access[key] = value
		else
			local menu = moderator.menu

			if (IsValid(menu) and menu.tabID == "groups") then
				if (key == "immunity") then
					menu.scroll.immunity:SetValue(value)
				elseif (key == "icon") then
					menu.scroll.icons:SelectIcon("icon16/"..value..".png")
					menu.scroll.icons:ScrollToSelected()
				elseif (key == "name") then
					menu.scroll.name:SetValue(value)
				end
			end

			moderator.groups[group][key] = value
		end
	end)

	function moderator.UpdateGroup(group, key, value)
		if (!LocalPlayer():CheckGroup("owner")) then return end

		net.Start("mod_GroupUpdate")
			net.WriteString(group)
			net.WriteString(key)
			net.WriteType(value)
		net.SendToServer()
	end
end

function moderator.GetGroup(client)
	client = client or LocalPlayer()

	local group = client:GetNWString("usergroup", "user")
	if (!moderator.groups[group]) then group = "user" end

	return group
end

function moderator.GetGroupTable(group, default)
	return moderator.groups[group] or (default or moderator.groups.user)
end

function moderator.HasPermission(command, client, group)
	client = client or (CLIENT and LocalPlayer())
	if (!IsValid(client)) then return SERVER end

	group = group or moderator.GetGroup(client)
	local groupTable = moderator.GetGroupTable(group)

	if (type(groupTable.access) == "boolean" and groupTable.access) then
		return true
	end

	if (groupTable.access and groupTable.access[command]) then
		return true
	end

	if (groupTable.inherit and groupTable.inherit != group) then
		local allowed = moderator.HasPermission(command, client, groupTable.inherit)
		
		if (allowed) then
			return allowed
		end
	end

	return false
end

function moderator.HasInfluence(client, target, strict)
	if (client == target) then
		return true
	end
	
	local group = moderator.GetGroupTable(client)
	local targetGroup = moderator.GetGroupTable(target)

	if (targetGroup.immunity) then
		if (!strict) then
			return (group.immunity or 0) >= targetGroup.immunity
		else
			return (group.immunity or 0) > targetGroup.immunity
		end
	else
		return true
	end

	return false
end

function moderator.CheckGroup(client, group)
	if (!IsValid(client) or client:GetNWString("usergroup", "user") == group) then
		return true
	end

	local ourGroupTable = moderator.GetGroupTable(moderator.GetGroup(client))
	if (!outGroupTable) then return false end

	local groupTable = moderator.GetGroupTable(group)
	if (!groupTable) then return false end

	return (ourGroupTable.immunity or 0) >= (groupTable.immunity or 0)
end

function moderator.SetGroup(client, group)
	if (!IsValid(client)) then return end

	group = group or "user"
	if (!moderator.groups[group]) then group = "user" end

	client:SetNWString("usergroup", group)
	client:SetPData("mod_Group", group)
end

function moderator.GetGroupIcon(client)
	local group = moderator.GetGroup(client)
	local groupTable = moderator.GetGroupTable(group)

	return groupTable.icon or "user"
end

function moderator.GetPlayersByGroup(group)
	local players = {}

	for k, v in pairs(player.GetAll()) do
		if (v:CheckGroup(group)) then
			players[#players + 1] = v
		end
	end

	return players
end

do
	local playerMeta = FindMetaTable("Player")
	playerMeta.CheckGroup = moderator.CheckGroup
	playerMeta.IsUserGroup = moderator.CheckGroup

	function playerMeta:IsSuperAdmin()
		return self:CheckGroup("superadmin")
	end

	function playerMeta:IsAdmin()
		return self:CheckGroup("admin")
	end
end

hook.Add("PlayerInitialSpawn", "mod_LoadGroup", function(client)
	local group = client:GetPData("mod_Group", "user")
	if (!moderator.groups[group]) then group = "user" end

	moderator.SetGroup(client, group)
end)