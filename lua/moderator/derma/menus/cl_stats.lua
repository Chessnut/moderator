local CATEGORY = {}
	CATEGORY.name = "Statistics"
	CATEGORY.adminOnly = true

	-- http://rosettacode.org/wiki/Averages/Median#Lua
	function median(numlist)
		if type(numlist) ~= 'table' then return numlist end
		table.sort(numlist)
		if #numlist %2 == 0 then return (numlist[#numlist/2] + numlist[#numlist/2+1]) / 2 end
		return numlist[math.ceil(#numlist/2)]
	end

	function CATEGORY:Layout(panel)
		local graph = panel:Add("mod_Graph")
		graph:SetTall(250)
		graph:Dock(TOP)
		graph:DockMargin(4, 4, 4, 0)
		graph:SetMaxX(10)
		graph:SetIntervalY(20)
		graph:SetupLine(1, Color(230, 25, 25), "Average Ping")
		graph:SetupLine(2, Color(30, 50, 220), "Your Ping")
		graph:SetupLine(3, Color(230, 180, 25), "Median Ping")
		graph:SetTitle("Ping")
		graph:SetupLegend()
			
		timer.Create("mod_PingCheck", 0.75, 0, function()
			if (!IsValid(graph)) then return timer.Remove("mod_PingCheck") end
				
			local average = 0
			local pingList = {}

			for k, v in pairs(player.GetAll()) do
				average = average + v:Ping()
				pingList[#pingList + 1] = v:Ping()
			end
			
			average = average / #player.GetAll()
			
			graph:AddPoint(math.floor(average))
			graph:AddPoint(LocalPlayer():Ping(), 2)
			graph:AddPoint(median(pingList), 3)
		end)

		local graph = panel:Add("mod_Graph")
		graph:SetTall(250)
		graph:Dock(TOP)
		graph:DockMargin(4, 4, 4, 0)
		graph:SetMaxX(10)
		graph:SetIntervalY(10)
		graph:SetupLine(1, Color(80, 200, 25), "Volume")
		graph:SetTitle("Server Volume (Excluding You)")
		graph:SetupLegend()
			
		timer.Create("mod_VolumeCheck", 0.75, 0, function()
			if (!IsValid(graph)) then return timer.Remove("mod_VolumeCheck") end
				
			local total = 0

			for k, v in pairs(player.GetAll()) do
				local volume = v:VoiceVolume()

				if (volume > 0.05) then
					total = total + volume
				end
			end
			
			graph:AddPoint(math.Round(total * 100))
		end)

		panel:AddHeader("Active Bans: "..table.Count(moderator.bans), nil, function()
			return "Active Bans: "..table.Count(moderator.bans)
		end)
		panel:AddHeader("Active Reports: "..table.Count(moderator.reports or {}), nil, function()
			return "Active Reports: "..table.Count(moderator.reports or {})
		end)
		panel:AddHeader("Players: "..#player.GetAll().."/"..game.MaxPlayers(), nil, function()
			return "Players: "..#player.GetAll().."/"..game.MaxPlayers()
		end)

		local function GetOnlineStaff()
			local i = 0

			for k, v in pairs(player.GetAll()) do
				if (v:CheckGroup("moderator")) then
					i = i + 1
				end
			end

			return i
		end

		panel:AddHeader("Staff Online: "..GetOnlineStaff(), nil, function()
			return "Staff Online: "..GetOnlineStaff()
		end)
	end	
moderator.menus.stats = CATEGORY