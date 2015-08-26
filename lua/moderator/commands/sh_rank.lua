local COMMAND = {}
	COMMAND.name = "Set Rank"
	COMMAND.icon = "group"
	COMMAND.usage = "<string rank>"
	COMMAND.example = "!setrank #moderator admin - Promotes all moderators to administrators."

	function COMMAND:OnRun(client, arguments, target)
		local group = arguments[1] or "user"

		if (!moderator.groups[group]) then
			return moderator.Notify(client, "you provided an invalid usergroup.")
		end

		local function Action(target)
			moderator.SetGroup(target, group)
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has placed * in the "..group.." usergroup")
	end

	function COMMAND:OnClick(menu, client)
		for k, v in SortedPairsByMemberValue(moderator.groups, "immunity") do
			menu:AddOption(v.name, function()
				self:Send(client, k)
			end):SetImage("icon16/"..(v.icon or "user")..".png")
		end
	end
moderator.commands.setrank = COMMAND

if (SERVER) then
	concommand.Add("mod_setrank", function(client, command, arguments)
		if (!IsValid(client) or client:IsUserGroup("owner")) then
			if (!arguments[1]) then
				return MsgN("You did not enter a valid name.")
			end

			local target = moderator.FindPlayerByName(arguments[1], false, 1)

			if (IsValid(target)) then
				local group = arguments[2] or "user"
				if (!moderator.groups[group]) then group = "user" end

				moderator.SetGroup(target, group)
				MsgN("You have set the usergroup of "..target:Name().." to "..group)
				moderator.Notify(target, "you have been placed in the "..group.." usergroup.")
			else
				MsgN("You did not enter a valid player.")
			end
		end
	end)
end
