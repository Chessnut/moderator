local COMMAND = {}
	COMMAND.name = "Slap"
	COMMAND.tip = "Slaps a player with a specified amount of force."
	COMMAND.icon = "lightning"
	COMMAND.usage = "[number force]"
	COMMAND.example = "!slap #random 500 - Slaps a random player with 500 force."

	function COMMAND:OnRun(client, arguments, target)
		local specified = arguments[1] != nil
		local force = math.Clamp(tonumber(arguments[1]) or 100, 1, 10000)

		local function Action(target)
			local direction = Vector(math.random(-force, force), math.random(-force, force), math.max(force, 250))

			target:SetVelocity(direction)
			target:ViewPunch(direction:GetNormal():Angle() * math.Clamp(force / 4000, 0.01, 0.2))
			target:EmitSound("physics/body/body_medium_impact_hard"..math.random(1, 6)..".wav")
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		if (specified) then
			moderator.NotifyAction(client, target, "has slapped * with "..force.." force")
		else
			moderator.NotifyAction(client, target, "has slapped")
		end
	end
moderator.commands.slap = COMMAND