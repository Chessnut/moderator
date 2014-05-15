local COMMAND = {}
	COMMAND.name = "Arm"
	COMMAND.tip = "Restores a player's weapons."
	COMMAND.icon = "basket_put"
	COMMAND.example = "!arm Chessnut - Gives Chessnut default weapons."

	function COMMAND:OnRun(client, arguments, target)
		local function Action(target)
			if (target.modWeapons) then
				for i = 1, #target.modWeapons do
					target:Give(target.modWeapons[i])
				end

				if (target.modWeapons[0]) then
					target:SelectWeapon(target.modWeapons[0])
				end

				target.modWeapons = nil
			else
				hook.Run("PlayerLoadout", target)
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has armed")
	end
moderator.commands.arm = COMMAND