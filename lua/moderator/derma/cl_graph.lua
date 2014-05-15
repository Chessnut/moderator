local PANEL = {}
	surface.CreateFont("mod_GraphTitle", {
		font = "Tahoma",
		size = 22,
		weight = 800
	})

	function PANEL:Init()
		self.intervalX = 2
		self.intervalY = 2
		
		self.lines = {}
		self.lineData = {}
		
		self.highestY = 0
		self.lowestY = 0
		
		self.title = self:Add("DLabel")
		self.title:Dock(TOP)
		self.title:DockMargin(5, 5, 5, 0)
		self.title:SetFont("mod_GraphTitle")
		self.title:SetText("Graph")
		self.title:SetContentAlignment(5)
		self.title:SetDark(true)
			
		self.canvas = self:Add("DPanel")
		self.canvas:Dock(FILL)
		self.canvas:DockMargin(10, 10, 10, 10)
		self.canvas.Paint = function(this, w, h)
			surface.SetDrawColor(235, 235, 235)
			surface.DrawRect(0, 0, w, h)
			
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawOutlinedRect(0, 0, w, h)
	
			surface.SetDrawColor(250, 250, 250, 200)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
			
			surface.SetDrawColor(0, 0, 0, 50)
			
			for i = 1, self.intervalX do
				local x = w * (i / self.intervalX)
				
				surface.DrawLine(x, 1, x, h - 1)
			end
			
			for i = 1, self.intervalY do
				local y = h * (i / self.intervalY)
				
				surface.DrawLine(1, y, w - 1, y)
			end
			
			for line, data in pairs(self.lines) do
				local lastX, lastY
				
				for x, y in pairs(data) do
					x = x - 1
					
					self.maxY = self.maxY or y
					
					local x2, y2 = w * (x/self.intervalX), h * ((self.maxY - y) / (self.maxY-self.lowestY))
					local color = self.lineData[line].color or color_black
					
					surface.SetDrawColor(color)
					surface.DrawRect(x2 - 2, y2 - 2, 4, 4)
					
					if (lastX and lastY) then
						surface.DrawLine(lastX, lastY, x2, y2)
					end
					
					local mX = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
					
					if (math.abs(mX - x2) <= 10) then
						local offset = 20
						
						if ((y2 + 10) >= h - 20) then
							offset = -20
						end
						
						draw.SimpleTextOutlined(y, "DermaDefault", x2, y2 + offset, color, 1, 1, 1, color_white)
					end
						
					lastX, lastY = x2, y2
				end	
			end
		end
	
		self.legend = self:Add("DPanel")
		self.legend:Dock(RIGHT)
		self.legend:SetWide(120)
		self.legend:DockMargin(0, 9, 10, 10)
		self.legend:SetDrawBackground(false)
	end
	
	function PANEL:SetupLegend()
		for k, v in SortedPairsByMemberValue(self.lineData, "text") do
			local panel = self.legend:Add("DPanel")
			panel:Dock(TOP)
			panel:SetTall(24)
			panel:DockMargin(5, 0, 5, 5)
			panel:SetDrawBackground(false)
			
			local lineColor = v.color
			local color = panel:Add("DPanel")
			color:SetPos(2, 2)
			color:SetSize(20, 20)
			color.Paint = function(this, w, h)
				surface.SetDrawColor(lineColor)
				surface.DrawRect(0, 0, w, h)
				
				surface.SetDrawColor(0, 0, 0)
				surface.DrawOutlinedRect(0, 0, w, h)
			end
			
			local label = panel:Add("DLabel")
			label:SetPos(28, 5)
			label:SetText(v.text)
			label:SetDark(true)
			label:SizeToContents()
		end
	end
	
	function PANEL:SetupLine(line, color, text)
		self.lineData[line] = {color = color, text = text or "Unknown"}
		self.lines[line] = {}
	end
	
	function PANEL:SetTitle(title)
		self.title:SetText(title)
	end

	function PANEL:SetIntervalY(interval)
		self.intervalY = interval
	end
	
	function PANEL:SetMaxY(max)
		self.maxY = max
	end
	
	function PANEL:SetMaxX(max)
		self.intervalX = max
	end
	
	function PANEL:Paint(w, h)
		surface.SetDrawColor(240, 240, 240)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function PANEL:AddPoint(y, line)
		line = line or 1
		
		if (!self.lines[line]) then return end
		
		if (y < self.lowestY or y > self.highestY) then
			if (y > 0) then
				self.highestY = y
				self:SetMaxY(math.ceil(self.highestY / self.intervalY) * self.intervalY)
			else
				self.lowestY = -math.ceil(math.abs(y) / self.intervalY) * self.intervalY
			end
		end
		
		table.insert(self.lines[line], y)
		
		if (#self.lines[line] > (self.intervalX + 1)) then
			table.remove(self.lines[line], 1)
		end
	end
vgui.Register("mod_Graph", PANEL, "DPanel")