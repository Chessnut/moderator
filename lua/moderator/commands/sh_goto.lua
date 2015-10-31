local COMMAND = {}
	COMMAND.name = "Go To"
	COMMAND.tip = "Teleports you to a player's position."
	COMMAND.icon = "arrow_down"
	COMMAND.usage = "[bool toAimPos]"
	COMMAND.example = "!goto #random - Teleports you to a random player."

	function COMMAND:OnRun(client, arguments, target)
		local toAim = util.tobool(arguments[1] or false)

		local function Action(target)
			client.modPos = client.modPos or client:GetPos()
			client:SetVelocity(Vector())
			
			if (toAim) then
				client:SetPos(target:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 4))
			else
				local data = {}
					data.start = target:GetShootPos() + target:GetAimVector()*24
					data.endpos = data.start + target:GetAimVector()*64
					data.filter = target
				local trace = util.TraceLine(data)

				client:SetPos(trace.HitPos + Vector(0, 0, 4))
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has gone to")
	end

	function COMMAND:OnClick(menu, client)
		menu:AddOption("To Player", function()
			self:Send(client)
		end)
		menu:AddOption("To Aim", function()
			self:Send(client, true)
		end)
	end
moderator.commands.goto = COMMAND