local CATEGORY = {}
	CATEGORY.name = "Reports"
	CATEGORY.adminOnly = true

	function CATEGORY:Layout(panel)
		panel.Think = function(this)
			if (moderator.updateReports) then
				this:Clear()
				self:Layout(this)
				moderator.updateReports = nil
			end
		end

		if (!moderator.reports or table.Count(moderator.reports) == 0) then
			return panel:ShowMessage("There are currently no reports to view.")
		end

		for k, v in SortedPairsByMemberValue(moderator.reports, "date") do
			local panel = panel:Add("mod_ReportPanel")
			panel:Dock(TOP)
			panel:DockMargin(4, 4, 4, 0)
			panel:SetReport(v, k)
		end
	end
moderator.menus.reports = CATEGORY

local PANEL = {}
	function PANEL:Init()
		self:SetTall(36)

		self.avatar = self:Add("AvatarImage")
		self.avatar:SetPos(2, 2)
		self.avatar:SetSize(32, 32)

		self.click = self.avatar:Add("DButton")
		self.click:Dock(FILL)
		self.click.Paint = function() end
		self.click:SetText("")
		self.click:SetToolTip("Click to see options for this player.")

		self.name = self:Add("DLabel")
		self.name:SetText("Loading name...")
		self.name:SetPos(38, 4)
		self.name:SetFont("DermaDefaultBold")
		self.name:SetDark(true)
		self.name:SetAlpha(220)
		self.name:SizeToContents()

		self.time = self:Add("DLabel")
		self.time:SetText("on 0/0/0 00:00:00")
		self.time:SetPos(self.name:GetWide() + 4, 4)
		self.time:SetDark(true)
		self.time:SetAlpha(130)
		self.time:SizeToContents()

		self.desc = self:Add("DLabel")
		self.desc:SetText("Loading description...")
		self.desc:SetPos(38, 14)
		self.desc:SetDark(true)
		self.desc:SetAlpha(220)
		self.desc:SetWide(moderator.menu.scroll:GetWide() - (38 + 6 + 20))

		self.extend = self:Add("DButton")
		self.extend:SetPos(moderator.menu.scroll:GetWide() - 30, 0)
		self.extend:SetSize(24, 38)
		self.extend.Paint = function() end
		self.extend:SetText("")
		self.extend:SetImage("icon16/bullet_go.png")
		self.extend:SetToolTip("Click to view more options for this report.")
	end

	function PANEL:SetReport(report, index)
		if (!report.steamID) then return self:Remove() end

		local found
		local steamID64 = util.SteamIDTo64(report.steamID)

		for k, v in pairs(player.GetAll()) do
			if (v:SteamID() == report.steamID) then
				self.name:SetText("By "..v:Name())
				self.click.DoClick = function(this)
					local menu = DermaMenu()
						menu:AddOption("Go To", function()
							if (!IsValid(v)) then return end

							moderator.SendCommand("goto", v)
						end):SetImage("icon16/arrow_up.png")
						menu:AddOption("Bring", function()
							if (!IsValid(v)) then return end

							moderator.SendCommand("tp", v)
						end):SetImage("icon16/arrow_down.png")
						menu:AddSpacer()
						menu:AddOption("Open Steam Profile", function()
							gui.OpenURL("http://steamcommunity.com/profiles/"..steamID64)
						end):SetImage("icon16/world.png")
					menu:Open()
				end

				found = true

				break
			end
		end

		if (!found) then
			self.click.DoClick = function(this)
				gui.OpenURL("http://steamcommunity.com/profiles/"..steamID64)
			end

			steamworks.RequestPlayerInfo(steamID64)

			timer.Simple(1, function()
				if (IsValid(self)) then
					self.name:SetText("By "..steamworks.GetPlayerName(steamID64))
					self.name:SizeToContents()

					self.time:MoveRightOf(self.name, 2)
					self.time:SetText("on "..os.date("%c", report.date))
					self.time:SizeToContents()
				end
			end)
		end
		
		self.name:SizeToContents()

		self.time:MoveRightOf(self.name, 2)
		self.time:SetText("on "..os.date("%c", report.date))
		self.time:SizeToContents()

		self.avatar:SetSteamID(steamID64)
		self.desc:SetText(report.text)
		self.extend.DoClick = function(this)
			local menu = DermaMenu()
				local desc = menu:AddOption("View Description")
				desc:SetToolTip(table.concat(moderator.SplitStringByLength(report.text, 80), "\n"))
				desc:SetImage("icon16/tag_blue.png")

				menu:AddOption("Remove", function()
					net.Start("mod_ReportDelete")
						net.WriteUInt(index, 16)
					net.SendToServer()
				end):SetImage("icon16/bin.png")
			menu:Open()
		end
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(240, 240, 240)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 90)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
vgui.Register("mod_ReportPanel", PANEL, "DPanel")