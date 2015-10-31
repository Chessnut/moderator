local COMMAND = {}
	COMMAND.name = "Give Weapon"
	COMMAND.tip = "Gives the target a weapon."
	COMMAND.icon = "gun"
	COMMAND.usage = "<string class>"
	COMMAND.example = "!give #me weapon_physgun - Gives you a physgun."

	local hl2Weapons = {
		["weapon_357"] = ".357 Magnum",
		["weapon_annabelle"] = "Annabelle",
		["weapon_ar2"] = "AR2",
		["weapon_bugbait"] = "Bugbait",
		["weapon_crossbow"] = "Crossbow",
		["weapon_crowbar"] = "Crowbar",
		["weapon_frag"] = "Frag Grenade",
		["weapon_pistol"] = "Pistol",
		["weapon_rpg"] = "RPG Launcher",
		["weapon_shotgun"] = "Shotgun",
		["weapon_slam"] = "SLAM",
		["weapon_smg"] = "SMG",
		["weapon_stunstick"] = "Stunstick",
	}

	function COMMAND:OnRun(client, arguments, target)
		local class = table.concat(arguments, " ")

		if (!weapons.Get(class) and !hl2Weapons[class] and class != "weapon_physgun") then
			class = class:lower()

			if (!weapons.Get(class) and !hl2Weapons[class] and class != "weapon_physgun") then
				return false, "you provided an invalid weapon class."
			end
		end

		local function Action(target)
			target:Give(class)
			target:SelectWeapon(class)
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has given a(n) "..class.." to *")
	end

	function COMMAND:OnClick(menu, client)
		local categories = {}

		for k, v in SortedPairs(weapons.GetList() or {}) do
			local category = v.category or "Miscellaneous"

			if (!categories[category]) then
				categories[category] = menu:AddSubMenu(category)
			end

			categories[category]:AddOption(v.PrintName or k, function()
				self:Send(k)
			end)
		end

		local category = menu:AddSubMenu("Half-Life 2")

		for k, v in SortedPairs(hl2Weapons) do
			category:AddOption(v, function()
				self:Send(client, k)
			end)
		end

		menu:AddSubMenu("Garry's Mod"):AddOption("Physics Gun", function()
			self:Send(client, "weapon_physgun")
		end)
	end
moderator.commands.give = COMMAND