local CATEGORY = {}
	CATEGORY.name = "Players"
	CATEGORY.autoSelect = true

	moderator.selected = {}
	moderator.list = moderator.list or {}

	function CATEGORY:Layout(panel)
		panel.search = panel:Add("DTextEntry")
		panel.search:Dock(TOP)
		panel.search:DockMargin(4, 4, 4, 0)
		panel.search.OnTextChanged = function(this)
			local text = this:GetText()

			if (text == "") then
				self:ListPlayers(panel.scroll)
			else
				local players = {}

				for k, v in ipairs(player.GetAll()) do
					if (moderator.StringMatches(v:Name(), text)) then
						players[k] = v
					end
				end

				self:ListPlayers(panel.scroll, players)
			end
		end
		panel.search:SetToolTip("Search for players by their name.")

		panel.contents = panel:Add("DPanel")
		panel.contents:DockMargin(4, 4, 4, 4)
		panel.contents:Dock(TOP)
		panel.contents:SetTall(panel:GetTall() - 38)

		local function PaintButton(this, w, h)
			surface.SetDrawColor(255, 255, 255, 80)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(255, 255, 255, 120)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

			surface.SetDrawColor(0, 0, 0, 60)
			surface.DrawOutlinedRect(0, 0, w, h)

			if (this.entered) then
				surface.SetDrawColor(0, 0, 0, 25)
				surface.DrawRect(0, 0, w, h)
			end
		end

		panel.actions = panel.contents:Add("DScrollPanel")
		panel.actions:Dock(RIGHT)
		panel.actions:SetWide(panel:GetWide() * 0.335)
		panel.actions.Paint = PaintButton
		panel.actions:DockMargin(0, 4, 4, 4)
		panel.actions:DockPadding(0, 1, 0, 0)

		for k, v in SortedPairsByMemberValue(moderator.commands, "name") do
			if (v.hidden or !moderator.HasPermission(k)) then
				continue
			end

			local button = panel.actions:Add("DButton")
			button:Dock(TOP)
			button:SetTall(28)
			button.Paint = PaintButton
			button:DockMargin(2, 2, 2, 0)
			button.OnCursorEntered = function(this)
				this.entered = true
			end
			button.OnCursorExited = function(this)
				this.entered = nil
			end
			button:SetText(v.name)
			button.DoClick = function()
				if (table.Count(moderator.selected) > 0) then
					local target = {}

					for k, v in pairs(moderator.selected) do
						target[#target + 1] = k
					end

					local function Send(...)
						moderator.SendCommand(k, target, ...)
					end

					if (v.OnClick) then
						v.menu = DermaMenu()
							function v:Send(...)
								Send(...)
							end

							v:OnClick()
						v.menu:Open()
						v.menu = nil
					else
						Send()
					end
				end
			end

			if (v.tip) then
				button:SetToolTip(v.tip)
			end

			if (v.icon) then
				button:SetImage("icon16/"..v.icon..".png")
			end
		end

		panel.scroll = panel.contents:Add("DScrollPanel")
		panel.scroll:Dock(FILL)
		panel.scroll:SetWide(panel:GetWide() * 0.6 - 11)

		self.deltaCount = #player.GetAll()

		panel.Think = function()
			local count = #player.GetAll()

			if (self.deltaCount != count) then
				local players = player.GetAll()
				local text = (IsValid(panel.search) and panel.search:GetText() or "")

				if (text != "") then
					players = {}

					for k, v in ipairs(player.GetAll()) do
						if (moderator.StringMatches(v:Name(), text)) then
							players[k] = v
						end
					end
				end

				self:ListPlayers(panel.scroll, players)
			end

			self.deltaCount = count
		end

		self:ListPlayers(panel.scroll)

		return true
	end

	function CATEGORY:ListPlayers(scroll, players, callback)
		if (!IsValid(scroll)) then
			return
		end

		moderator.list = {}
			local oldSelected = moderator.selected
		moderator.selected = {}

		scroll:Clear()
		players = players or player.GetAll()

		for k, v in SortedPairs(players) do
			local item = scroll:Add("mod_Player")
			item:Dock(TOP)
			item:SetPlayer(v)
			item.index = #moderator.list + 1

			if (callback) then
				callback(k, item)
			end

			if (oldSelected[v]) then
				moderator.selected[v] = true
			end

			moderator.list[item.index] = item
		end
	end

	local PANEL = {}
		function PANEL:Init()
			self:SetTall(36)
			self:DockPadding(2, 2, 2, 2)
			self:DockMargin(4, 4, 4, 0)
			
			self.avatar = self:Add("AvatarImage")
			self.avatar:Dock(LEFT)
			self.avatar:SetWide(32)
			
			self.icon = self:Add("DImage")
			self.icon:Dock(LEFT)
			self.icon:SetWide(16)
			self.icon:DockMargin(4, 8, 0, 8)
			self.icon:SetImage("icon16/group.png")

			self.name = self:Add("DLabel")
			self.name:SetFont("mod_TextFont")
			self.name:Dock(LEFT)
			self.name:DockMargin(3, 0, 0, 0)
			self.name:SetDark(true)
			self.name:SetText("Unknown Player")
			self.name:SizeToContents()
			
			self.checked = self:Add("DButton")
			self.checked:Dock(RIGHT)
			self.checked:SetText("")
			self.checked:SetWide(19)
			self.checked:DockMargin(6, 6, 8, 6)
			self.checked.DoClick = function(this)
				moderator.selected[self.player] = !moderator.selected[self.player]

				if (!moderator.selected[self.player]) then
					moderator.selected[self.player] = nil
				end
			end
			self.checked.Paint = function(this, w, h)
				surface.SetDrawColor(250, 250, 250, 150)
				surface.DrawRect(0, 0, w, h)
				
				surface.SetDrawColor(0, 0, 0, 120)
				surface.DrawOutlinedRect(0, 0, w, h)
				
				if (moderator.selected[self.player]) then
					surface.SetDrawColor(50, 195, 50, 220 + math.sin(RealTime() * 1.8)*15)
					surface.DrawRect(2, 2, w - 4, h - 4)
				end
			end
		end
		
		function PANEL:Think()
			if (IsValid(self.player)) then
				local name = self.player:Name()
					if (self.deltaName and self.deltaName != name) then
						self.name:SetText(name)
						self.name:SizeToContents()
					end
				self.deltaName = name

				local group = self.player:GetNWString("usergroup", "user")
					if (self.deltaRank and self.deltaRank != group) then
						self.icon:SetImage("icon16/"..moderator.GetGroupIcon(self.player)..".png")
					end
				self.deltaRank = group
			elseif (self.playerSet) then
				self:Remove()
			end
		end

		function PANEL:OnCursorEntered()
			self.entered = true
		end
		
		function PANEL:OnCursorExited()
			self.entered = false
		end
		
		function PANEL:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 20)
			surface.DrawRect(0, 0, w, h)
			
			if (self.entered) then
				surface.SetDrawColor(255, 255, 255, 75)
				surface.DrawRect(0, 0, w, h)
			end
			
			surface.SetDrawColor(0, 0, 0, 60)
			surface.DrawOutlinedRect(0, 0, w, h)
			
			if (self.playerSet) then
				local teamColor = team.GetColor(self.player:Team())
					
				surface.SetDrawColor(teamColor)
				surface.DrawRect(w - 7, 1, 6, h - 2)
			end
		end
		
		function PANEL:SetPlayer(client)
			self.player = client
			self.playerSet = true
			self.avatar:SetPlayer(client)
			
			self.avatar.click = self.avatar:Add("DButton")
			self.avatar.click:SetText("")
			self.avatar.click:Dock(FILL)
			self.avatar.click.Paint = function() end
			self.avatar.click.DoClick = function(this)
				if (!IsValid(client)) then return end
				
				local menu = DermaMenu()
					local steamID = client:SteamID()
					local steamID64 = client:SteamID64() or "76561197960287930"
					local name = client:Name()

					menu:AddOption("Show Steam Profile", function()
						gui.OpenURL("http://steamcommunity.com/profiles/"..steamID64)
					end):SetImage("icon16/world_link.png")
					menu:AddSpacer()
					menu:AddOption("Copy Name", function()
						if (IsValid(client)) then
							SetClipboardText(client:Name())
						else
							SetClipboardText(name)
						end
					end):SetImage("icon16/tag_blue.png")
					menu:AddSpacer()
					menu:AddOption("Copy SteamID", function()
						SetClipboardText(steamID)
					end):SetImage("icon16/database.png")
					menu:AddOption("Copy CommunityID", function()
						SetClipboardText(steamID64)
					end):SetImage("icon16/database_lightning.png")
				menu:Open()
			end
			self.avatar.click:SetToolTip("Click to view this player's Steam profile.")
			
			self.name:SetText(client:Name())
			self.name:SizeToContents()

			self.icon:SetImage("icon16/"..moderator.GetGroupIcon(client)..".png")
		end
	vgui.Register("mod_Player", PANEL, "DPanel")
moderator.menus.players = CATEGORY

concommand.Add("mod_clearselected", function()
	moderator.selected = {}
end)