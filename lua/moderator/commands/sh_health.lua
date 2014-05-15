local COMMAND = {}
	local name = "Health"
	local name2 = name:lower()

	COMMAND.name = "Set "..name
	COMMAND.tip = "Sets the "..name2.." of a player."
	COMMAND.icon = "heart"
	COMMAND.usage = "[number health]"
	COMMAND.example = "!health #all 100 - Sets everyone's health to 100."

	function COMMAND:OnRun(client, arguments, target)
		local amount = math.floor(tonumber(arguments[1]) or 100)

		local function Action(target)
			target["Set"..name](target, amount)

			if (amount == 0) then
				target:Kill()
			end
		end

		if (type(target) == "table") then
			for k, v in pairs(target) do
				Action(v)
			end
		else
			Action(target)
		end

		moderator.NotifyAction(client, target, "has set the "..name2.." of * to "..amount)
	end

	function COMMAND:OnClick()
		local menu = self.menu
		
		for i = 1, 10 do
			menu:AddOption((i * 10).." "..name, function()
				self:Send(i * 10)
			end)
		end

		menu:AddOption("Specify", function()
			Derma_StringRequest("Set "..name, "Specify the amount of "..name2.." to set.", 100, function(text)
				self:Send(tonumber(text) or 100)
			end)
		end)
	end
moderator.commands[name2] = COMMAND