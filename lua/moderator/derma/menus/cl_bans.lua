local CATEGORY = {}
	CATEGORY.name = "Bans"
	CATEGORY.adminOnly = true

	function CATEGORY:Layout(panel)
		panel.Think = function(this)
			if (moderator.updateBans) then
				this:Clear(true)
				self:Layout(panel)
				moderator.updateBans = nil
			end
		end

		if (!moderator.bans or table.Count(moderator.bans) == 0) then
			return panel:ShowMessage("There are currently no bans to view.")
		end

		local function PaintHeader(this, w, h)
			surface.SetDrawColor(255, 255, 255, 5)
			surface.DrawRect(0, 0, w, h)
		end

		panel.bans = panel:Add("DListView")
		panel.bans:Dock(FILL)
		panel.bans:DockMargin(4, 4, 4, 0)
		panel.bans:AddColumn("Date")
		panel.bans:AddColumn("Name")
		panel.bans:AddColumn("Admin")
		panel.bans:AddColumn("Expires In")
		panel.bans:SetHeaderHeight(28)
		panel.bans:SetDataHeight(24)

		local lines

		local function PopulateList()
			panel.bans:Clear()

			lines = {}
			panel.lines = {}

			for k, v in SortedPairsByMemberValue(moderator.bans, "date") do
				local line = panel.bans:AddLine(os.date("%c", v.date), v.name, v.admin, string.NiceTime((v.date + v.length) - os.time()))
				line:SetToolTip("Reason: "..v.reason.."\nSteamID: "..k.."\nLength: "..string.NiceTime(v.length))
				line.ban = v
				line.steamID = k

				if (v.length > 0) then
					lines[line] = {
						date = v.date,
						length = v.length
					}
				else
					line:SetColumnText(4, "Never")
				end

				panel.lines[k] = line:GetID()
			end

			local nextUpdate = 0

			panel.bans.OnRowRightClick = function(this, index, line)
				local menu = DermaMenu()
					local steamID64 = util.SteamIDTo64(line.steamID)

					menu:AddOption("Open Steam Profile", function()
						gui.OpenURL("http://steamcommunity.com/profiles/"..steamID64)
					end):SetImage("icon16/world.png")
					menu:AddSpacer()
					menu:AddOption("Change Reason", function()
						Derma_StringRequest("Change Reason", "Enter the new ban reason.", line.ban.reason, function(text)
							if (text == "") then
								text = "no reason"
							end

							moderator.AdjustBan(line.steamID, "reason", text)
						end)
					end):SetImage("icon16/tag_orange.png")
					menu:AddOption("Adjust Time", function()
						Derma_StringRequest("Change Time", "Enter the new ban time.", "1m", function(text)
							if (text == "") then
								text = "1m"
							end

							moderator.AdjustBan(line.steamID, "length", text)
						end)
					end):SetImage("icon16/clock.png")
					
					local remove = menu:AddSubMenu("Remove Ban")
					remove:AddOption("Confirm", function()
						net.Start("mod_BanRemove")
							net.WriteString(line.steamID)
						net.SendToServer()
					end):SetImage("icon16/delete.png")
				menu:Open()
			end
			panel.bans.Think = function()
				if (nextUpdate <= CurTime()) then
					nextUpdate = CurTime() + 1

					for k, v in pairs(lines) do
						local difference = (v.date + v.length) - os.time()
						k:SetColumnText(4, string.NiceTime(difference))

						if (difference <= 0) then
							moderator.bans[k.steamID] = nil
							moderator.updateBans = true
						end
					end
				end
			end
		end

		PopulateList()
	end
moderator.menus.bans = CATEGORY