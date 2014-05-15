local CATEGORY = {}
	CATEGORY.name = "Settings"

	function CATEGORY:Layout(panel)
		panel:AddHeader("Color Options")

		local selection = panel:Add("DIconLayout")
		selection:SetTall(200)
		selection:DockMargin(4, 8, 4, 16)
		selection:Dock(TOP)
		selection:SetSpaceX(2)
		selection:SetSpaceY(2)

		for k, v in ipairs(moderator.colorsSorted) do
			local color = v[2]
			local button = selection:Add("DButton")
			button:SetSize(64, 28)
			button.Paint = function(this, w, h)
				surface.SetDrawColor(color)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawOutlinedRect(0, 0, w, h)

				surface.SetDrawColor(255, 255, 255, 15)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
			end
			button:SetTextColor(color_white)
			button:SetExpensiveShadow(1, Color(0, 0, 0, 100))
			button:SetText("")
			button.DoClick = function(this)
				RunConsoleCommand("mod_color", v[1])
			end
		end

		panel:AddHeader("Administrative Options")

		local clearOnCommand = panel:Add("DCheckBoxLabel")
		clearOnCommand:SetText("Clear selection after a command")
		clearOnCommand:SetConVar("mod_clearoncommand")
		clearOnCommand:Dock(TOP)
		clearOnCommand:SetDark(true)
		clearOnCommand:DockMargin(4, 8, 4, 0)
	end
moderator.menus.SETTINGS = CATEGORY