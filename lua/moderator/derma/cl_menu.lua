local PANEL = {}
	local gradient = Material("vgui/gradient-r")
	local gradient2 = Material("gui/gradient")
	
	surface.CreateFont("mod_TitleFont", {
		size = 32,
		font = "Tahoma",
		weight = 200
	})
	
	surface.CreateFont("mod_TextFont", {
		size = 16,
		font = "Tahoma",
		weight = 200
	})

	surface.CreateFont("mod_SubTitleFont", {
		size = 24,
		font = "Tahoma",
		weight = 200
	})

	local sideWidthFraction = 0.325
	
	function PANEL:ToggleSideBar()
		local lastHidden = !self.sideHidden
		self.sideHidden = !self.sideHidden

		local width = (ScrW() * 0.45 * sideWidthFraction)

   		self.anim = self:NewAnimation(0.175)
        self.anim.Think = function(animation, panel, fraction)
        	if (lastHidden) then
        		fraction = 1 - fraction
    		end
    		
    		fraction = math.Clamp(fraction, 0, 1)

    		self.side:SetWide(width * fraction)
    		self.scroll:SetWide(self.scroll.realWidth + (width - self.side:GetWide()))
       	end
       	
       	self.side:SetWide(50)
	end
	
	function PANEL:Init()
		local w, h = math.max(ScrW() * 0.45, 640), math.max(ScrH() * 0.5, 600)
		
		moderator.menu = self
		
		self:SetTitle("")
		self:SetPos(-w, (ScrH() * 0.5) - (h * 0.5))
		self:SetSize(w, h)
		self:MakePopup()
		self:DockPadding(0, 0, 0, 0)
		self:ShowCloseButton(false)
		self:SetDraggable(true)
		self:SetDeleteOnClose(false)
		self:SetKeyBoardInputEnabled(false)
		self.Paint = function() end
		
		self.side = self:Add("DPanel")
		self.side:SetWide(w * sideWidthFraction)
		self.side:Dock(LEFT)
		self.side.Paint = function(this, w, h)
			surface.SetDrawColor(moderator.color)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(25, 25, 25, 55)
			surface.DrawOutlinedRect(0, 0, w + 1, h)
			
			surface.SetDrawColor(25, 25, 25, 25)
			surface.SetMaterial(gradient)
			surface.DrawTexturedRect(w - 24, 0, 24, h)
		end
		
		self.titleBar = self.side:Add("DPanel")
		self.titleBar:SetTall(48)
		self.titleBar:Dock(TOP)
		self.titleBar.Paint = function(this, w, h)
			surface.SetDrawColor(255, 255, 255, 4)
			surface.DrawLine(0, h - 2, w, h - 2)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(5, 5, 5, 120)
			surface.DrawLine(0, h - 1, w, h - 1)
		end
		
		self.titleBar.text = self.titleBar:Add("DLabel")
		self.titleBar.text:SetText("Moderator")
		self.titleBar.text:Dock(FILL)
		self.titleBar.text:SetFont("mod_TitleFont")
		self.titleBar.text:SetContentAlignment(5)
		self.titleBar.text:SetTextColor(Color(255, 255, 255))
		self.titleBar.text:SetExpensiveShadow(2, Color(5, 5, 5, 150))
		
		self.body = self:Add("DPanel")
		self.body:Dock(FILL)
		self.body.Paint = function(this, w, h)
			surface.SetDrawColor(236, 240, 241)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(25, 25, 25, 150)
			surface.DrawOutlinedRect(-1, 0, w + 1, h)
		end
		
		self.scroll = self.body:Add("DScrollPanel")
		self.scroll:SetPos(0, 48)
		self.scroll.realWidth = w - (w * sideWidthFraction) - 1
		self.scroll.realHeight = h - 43
		self.scroll:SetSize(self.scroll.realWidth, h - 43)
		self.scroll.AddHeader = function(this, text, parent, update)
			local label = (IsValid(parent) and parent or self.scroll):Add("DLabel")
			label:SetText(text or "Label")
			label:SetFont("mod_SubTitleFont")
			label:Dock(TOP)
			label:SetTextColor(Color(0, 0, 0, 230))
			label:SetExpensiveShadow(1, Color(255, 255, 255, 255))
			label:DockMargin(5, 5, 5, 5)

			if (update) then
				label.Think = function(this)
					if ((this.nextUpdate or 0) < CurTime()) then
						this.nextUpdate = CurTime() + 1
						label:SetText(update())
					end
				end
			end
		end
		self.scroll.ShowMessage = function(this, text)
			surface.SetFont("mod_SubTitleFont")
			local w, h = surface.GetTextSize(text)

			local message = this:Add("DLabel")
			message:SetDark(true)
			message:SetText(text)
			message:SetFont("mod_SubTitleFont")
			message:SizeToContents()
			message:SetPos(this:GetWide() / 2 - w/2, this:GetTall() / 2 - h/2)
			message:SetAlpha(150)
		end

		self.headerTitle = "None"
		
		local colorDark = Color(25, 25, 25, 180)
		
		self.header = self.body:Add("DPanel")
		self.header:SetTall(48)
		self.header:Dock(TOP)
		self.header.Paint = function(this, w, h)
			surface.SetDrawColor(25, 25, 25, 15)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(255, 255, 255, 20)
			surface.DrawLine(0, h - 2, w, h - 2)
			
			surface.SetDrawColor(5, 5, 5, 60)
			surface.DrawLine(0, h - 1, w, h - 1)
			
			draw.SimpleText(self.headerTitle or "", "mod_SubTitleFont", w * 0.5, h * 0.5, colorDark, 1, 1)
		end

		self.grab = self.header:Add("EditablePanel")
		self.grab:Dock(FILL)
		self.grab.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT) then
				self.dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
			end
		end
		self.grab.OnMouseReleased = function(this)
			self.dragging = nil
		end
		self.grab.Think = function(this)
			if (!input.IsMouseDown(MOUSE_LEFT)) then self.dragging = nil return end

			if (self.dragging) then
				local mouseX, mouseY = math.Clamp(gui.MouseX(), 1, ScrW() - 1), math.Clamp(gui.MouseY(), 1, ScrH() - 1)
				local x = math.Clamp(mouseX - self.dragging[1], 0, ScrW() - w)
				local y = math.Clamp(mouseY - self.dragging[2], 0, ScrH() - h)

				self:SetPos(x, y)
			end
		end

		self.sideToggle = self.header:Add("DImageButton")
		self.sideToggle:SetImage("moderator/menu.png")
		self.sideToggle.DoClick = function(this)
			self:ToggleSideBar()
		end
		self.sideToggle:DockMargin(16, 16, 16, 16)
		self.sideToggle:SetWide(16)
		self.sideToggle:SetAlpha(230)
		self.sideToggle:Dock(LEFT)
		
		self.close = self.header:Add("DImageButton")
		self.close:SetWide(16)
		self.close:SetImage("moderator/leave.png")
		self.close.DoClick = function(this)
			self:Close()
		end
		self.close:DockMargin(16, 16, 16, 16)
		self.close:SetAlpha(230)
		self.close:Dock(RIGHT)

		self.tabs = {}

		for k, v in SortedPairs(moderator.menus, true) do
			if (v.adminOnly and !LocalPlayer():CheckGroup(v.group or "moderator")) then
				continue
			end

			if (v.ShouldDisplay) then
				if (v:ShouldDisplay() == false) then
					continue
				end
			end

			self.tabs[k] = self.side:Add("mod_MenuTab")
			self.tabs[k]:SetText(v.name)
			self.tabs[k].DoClick = function(this)
				if (self.tabID == k) then return end
				
				self.tabID = k
				moderator.lastTab = k

				for k2, v2 in pairs(self.tabs) do
					if (this != v2) then
						v2.selected = false
						v2:SetTextColor(self.selected and Color(20, 20, 20) or Color(240, 240, 240, 250))
					end
				end

				this.selected = true
				this:SetTextColor(Color(20, 20, 20))

				self.scroll:Clear()
				self.scroll:DockPadding(0, 0, 0, 0)
				self.scroll:DockMargin(0, 0, 0, 0)

				self:SetKeyBoardInputEnabled(false)

				if (v.Layout) then
					local allowKeyboard = v:Layout(self.scroll)

					if (allowKeyboard) then
						self:SetKeyBoardInputEnabled(true)
					end
				end

				self.headerTitle = v.name
			end
		end

		local lastTab = moderator.lastTab

		if (lastTab) then
			if (self.tabs[lastTab]) then
				self.tabs[lastTab]:DoClick()
			end
		else
			for k, v in pairs(moderator.menus) do
				if (v.autoSelect) then
					self.tabs[k]:DoClick()
				end
			end
		end

		self:MoveTo((ScrW() * 0.5) - (self:GetWide() * 0.5), (ScrH() * 0.5) - (self:GetTall() * 0.5), 0.1, 0, 0.75)
	end

	function PANEL:Think()
		local group = moderator.GetGroup()
			if (self.deltaGroup and self.deltaGroup != group) then
				self:RefreshMenu()
			end
		self.deltaGroup = group
	end

	function PANEL:RefreshMenu()
		local lastTab = moderator.lastTab or self.tabID
		local selected

		for k, v in pairs(self.tabs) do
			v:Remove()
		end

		self.tabs = {}
		self.scroll:Clear()

		for k, v in SortedPairs(moderator.menus, true) do
			if (v.adminOnly and !LocalPlayer():CheckGroup(v.group or "moderator")) then
				continue
			end
			
			if (v.ShouldDisplay) then
				if (v:ShouldDisplay() == false) then
					continue
				end
			end

			self.tabs[k] = self.side:Add("mod_MenuTab")
			self.tabs[k]:SetText(v.name)
			self.tabs[k].DoClick = function(this)
				self.tabID = k
				moderator.lastTab = k

				for k2, v2 in pairs(self.tabs) do
					if (this != v2) then
						v2.selected = false
						v2:SetTextColor(self.selected and Color(20, 20, 20) or Color(240, 240, 240, 250))
					end
				end

				this.selected = true
				this:SetTextColor(Color(20, 20, 20))

				self.scroll:Clear(true)

				if (v.Layout) then
					v:Layout(self.scroll)
				end

				self.headerTitle = v.name
			end
		end

		if (lastTab) then
			if (self.tabs[lastTab]) then
				self.tabs[lastTab]:DoClick()
			end
		else
			for k, v in pairs(moderator.menus) do
				if (v.autoSelect) then
					self.tabs[k]:DoClick()
				end
			end
		end
	end

	function PANEL:OnClose()
		local x, y = self:LocalToScreen(0, 0)

		self:SetVisible(true)
		self:MoveTo(-self:GetWide(), y, 0.1, 0, 0.75, function()
			self:Remove()
			moderator.menu = nil
		end)
	end
vgui.Register("mod_Menu", PANEL, "DFrame")

local PANEL = {}
	function PANEL:Init()
		self:SetTall(48)
		self:DockMargin(0, 1, 0, 0)
		self:Dock(TOP)
		self:SetFont("mod_SubTitleFont")
		self:SetTextColor(Color(240, 240, 240, 250))
		self:SetExpensiveShadow(1, Color(25, 25, 25, 50))
	end

	function PANEL:OnCursorEntered()
		self.entered = true
	end

	function PANEL:OnCursorExited()
		self.entered = false
	end

	function PANEL:DoClick()
		self.selected = !self.selected
		self:SetTextColor(self.selected and Color(20, 20, 20) or Color(240, 240, 240, 250))
	end

	function PANEL:Paint(w, h)
		if (self.selected) then
			surface.SetDrawColor(236, 240, 241)
			surface.DrawRect(0, 0, w, h)
		end

		if (self.entered) then
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawRect(0, 0, w, h)
		end
	end
vgui.Register("mod_MenuTab", PANEL, "DButton")

concommand.Add("mod_menu", function()
	if (IsValid(moderator.menu)) then
		if (moderator.menu.OnClose) then
			moderator.menu:OnClose()
		end

		moderator.menu:Close()
	else
		vgui.Create("mod_Menu")
	end
end)