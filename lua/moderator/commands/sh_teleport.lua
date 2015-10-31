local COMMAND = {}
	COMMAND.name = "Teleport"
	COMMAND.tip = "Teleports a player to your position."
	COMMAND.icon = "arrow_up"
	COMMAND.usage = "[bool toAimPos]"
	COMMAND.example = "!bring #alive 1 - Brings everyone to your aim position."
	COMMAND.aliases = {"bring"}

	function COMMAND:OnRun(client, arguments, target)
		local toAim = util.tobool(arguments[1] or false)

		local function Action(target)
			if (target:InVehicle()) then
				target:ExitVehicle()
			end

			target.modPos = target.modPos or target:GetPos()
			target:SetVelocity(Vector())

			client.modTarget = target
			
			if (toAim) then
				target:SetPos(client:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 4))
			else
				local data = {}
					data.start = client:GetShootPos() + client:GetAimVector()*24
					data.endpos = data.start + client:GetAimVector()*64
					data.filter = client
				local trace = util.TraceLine(data)

				target:SetPos(trace.HitPos + Vector(0, 0, 4))
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "teleported * to their "..(toAim and "aim position" or "position"))
	end

	function COMMAND:OnClick(menu, client)
		menu:AddOption("To Me", function()
			self:Send(client)
		end)
		menu:AddOption("To Aim", function()
			self:Send(client, true)
		end)
	end
moderator.commands.tp = COMMAND