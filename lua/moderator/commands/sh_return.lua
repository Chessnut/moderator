local COMMAND = {}
	COMMAND.name = "Return"
	COMMAND.tip = "Returns a player to their position before teleporting."
	COMMAND.icon = "arrow_undo"
	COMMAND.targetIsOptional = true
	COMMAND.example = "!return - Returns you to a position before teleporting."

	function COMMAND:OnRun(client, arguments, target)
		if (!IsValid(target)) then
			target = (IsValid(client.modTarget) and client.modTarget) or client
			client.modTarget = nil
		end

		local function Action(target)
			if (target.modPos) then
				target:SetPos(target.modPos)
				target.modPos = nil
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has returned")
	end
moderator.commands["return"] = COMMAND