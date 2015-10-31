function moderator.ShowQuickMenu()
	gui.EnableScreenClicker(true)

	local menu = DermaMenu()
		for k, v in SortedPairsByMemberValue(moderator.commands, "name") do
			if (k != "__SortedIndex" and !v.noTarget and !v.hidden) then
				local command, option = menu:AddSubMenu(v.name)

				for k2, v2 in ipairs(player.GetAll()) do
					if (v.OnClick) then
						local menu = command:AddSubMenu(v2:Name())

						function v:Send(client, ...)
							local target = {client}

							for k3, v3 in pairs(moderator.selected) do
								if (k3 != v2) then
									target[#target + 1] = k3
								end
							end

							moderator.SendCommand(k, target, ...)
						end

						v:OnClick(menu, v2)
					else
						command:AddOption(v2:Name(), function()
							moderator.SendCommand(k, v2)
						end)
					end
				end

				local icon = Material("icon16/"..(v.icon or "brick")..".png")

				option.PaintOver = function(this, w, h)
					surface.SetDrawColor(color_white)
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(3, 3, 16, 16)
				end
			end
		end

		menu.OnRemove = function(this)
			gui.EnableScreenClicker(false)
		end
	menu:Open()

	moderator.quickMenu = menu
end

concommand.Add("+mod_quickmenu", function(client, command, arguments)
	moderator.ShowQuickMenu()
end)

concommand.Add("-mod_quickmenu", function(client, command, arguments)
	if (IsValid(moderator.quickMenu)) then
		moderator.quickMenu:Remove()
	end
end)