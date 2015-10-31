local CATEGORY = {}
	CATEGORY.name = "Groups"
	CATEGORY.adminOnly = true

	function CATEGORY:Layout(panel)
		panel:AddHeader("Group")

		local choose = panel:Add("DComboBox")
			choose:Dock(TOP)
			choose:DockMargin(4, 4, 4, 4)
			choose:SetValue("Choose a Group")
		panel.choose = choose

		local first = true
		local UpdateGroupAccess

		local content = panel:Add("DListLayout")
			content:Dock(TOP)
			content:SetDrawBackground(true)
			content:DockMargin(4, 4, 4, 4)
		panel.content = content

		local lastY = panel:AddHeader("Parent", content):GetTall() + 4

		local parent = content:Add("DListView")
			local line = {}
			local excluded = {}
			local delta

			parent:Dock(TOP)
			parent:SetTall(120)
			parent:DockMargin(4, 0, 4, 4)
			parent.choices = {}
			parent:AddColumn("Group")
			parent:AddColumn("Is Parent")
			parent.Think = function(this)
				for k, v in pairs(moderator.groups) do
					if (!IsValid(line[k]) and moderator.lastGroup != k and !excluded[k]) then
						local groupTable = moderator.GetGroupTable(moderator.lastGroup)
						local otherGroupTable = moderator.GetGroupTable(k)

						if ((otherGroupTable.immunity or 0) > (groupTable.immunity or 0)) then
							excluded[k] = true
							
							return
						end

						line[k] = this:AddLine(v.name, "")
						line[k].group = k

						this:SortByColumn(1)
					elseif (IsValid(line[k]) and moderator.lastGroup == k) then
						this:RemoveLine(line[k]:GetID())
						this:SortByColumn(1)

						line[k] = nil
					end

					if (IsValid(line[k]) and moderator.lastGroup) then
						local groupTable = moderator.GetGroupTable(moderator.lastGroup)

						line[k]:SetColumnText(2, groupTable.inherit == k and "✔" or "")
					end
				end
			end
			parent.OnClickLine = function(this, line, selected)
				if (!moderator.lastGroup) then return end

				local groupTable = moderator.GetGroupTable(moderator.lastGroup)
				local otherGroupTable = moderator.GetGroupTable(line.group)
				
				if (selected and line.group != groupTable.inherit) then
					if ((otherGroupTable.immunity or 0) > (groupTable.immunity or 0)) then
						return
					end

					moderator.UpdateGroup(moderator.lastGroup, "inherit", line.group)

					timer.Simple(0.1, function()
						UpdateGroupAccess(moderator.lastGroup)
					end)
				end
			end
		panel.parent = parent

		panel:AddHeader("Name", content)

		local name = content:Add("DTextEntry")
			name:Dock(TOP)
			name:SetTall(24)
			name:DockMargin(4, 0, 4, 4)
		panel.name = name

		panel:AddHeader("Icon", content)

		local icons = content:Add("DIconBrowser")
			icons:SetTall(256)
			icons:DockMargin(4, 0, 4, 4)
			icons:Dock(TOP)
		panel.icons = icons

		panel:AddHeader("Immunity", content)

		local immunity = content:Add("DNumberWang")
			immunity:Dock(TOP)
			immunity:DockMargin(4, 0, 4, 4)
			immunity:SetDecimals(0)
			immunity:SetMinMax(0, 99)
		panel.immunity = immunity

		panel:AddHeader("Permissions", content)

		local permissions = content:Add("DListView")
		permissions:Dock(TOP)
		permissions:DockMargin(4, 0, 4, 4)
		permissions:SetTall(256)
		permissions:AddColumn("Name")
		permissions:AddColumn("Allowed")

		function UpdateGroupAccess(data)
			permissions:Clear()

			for k, v in SortedPairsByMemberValue(moderator.commands, "name") do
				local hasAccess = moderator.HasPermission(k, nil, data)
				local line = permissions:AddLine(v.name or "", hasAccess and "✔" or "")
				line.command = k
				line.Think = function(this)
					if (data != "owner" and moderator.groups[data].access) then
						line:SetColumnText(2, moderator.groups[data].access[k] and "✔" or "")
					end
				end
			end
		end

		panel.choices = {}

		choose.OnSelect = function(this, index, value, data)
			if (panel.delete) then
				panel.delete:Remove()
			end

			if (!data or value == "New...") then
				Derma_StringRequest("New Group", "Enter a group identifier for this new group.", "", function(text)
					if (#text < 1 or !text:find("%S")) then
						return moderator.Notify("You did not provide a valid group identifier.")
					end

					moderator.UpdateGroup(text, "create")
				end)

				return
			end

			moderator.lastGroup = data

			local groupTable = moderator.GetGroupTable(data)
			local lastName = ""
			local lastImmunity = 0

			name:SetText(groupTable.name)
			name.OnEnter = function(this)
				local value = this:GetText()
				if (lastName == value) then return end

				moderator.UpdateGroup(data, "name", value)
				choose.Choices[panel.choices[data]] = value
				choose:SetValue(value)
				lastName = value
			end

			icons:SelectIcon("icon16/"..(groupTable.icon or "user")..".png")
			icons:ScrollToSelected()
			icons.OnChange = function(this)
				moderator.UpdateGroup(data, "icon", this:GetSelectedIcon():sub(8, -5))
			end

			immunity:SetValue(groupTable.immunity or 0)
			immunity.OnEnter = function(this)
				local value = this:GetValue()

				if (data == "owner") then return end
				if (lastImmunity == value) then return end
				
				moderator.UpdateGroup(data, "immunity", math.Clamp(math.floor(value), 0, 99))
				lastImmunity = value
			end

			permissions.OnClickLine = function(this, line)
				if (data != "owner") then
					groupTable.access = groupTable.access or {}

					if (groupTable.access[line.command]) then
						moderator.UpdateGroup(data, "access", {line.command})
					else
						moderator.UpdateGroup(data, "access", {line.command, true})
					end
				end
			end

			UpdateGroupAccess(data)

			if (LocalPlayer():CheckGroup("owner") and !moderator.defaultGroups[data]) then
				local delete = content:Add("DButton")
					delete:Dock(TOP)
					delete:SetTall(24)
					delete:DockMargin(4, 4, 4, 0)
					delete:SetText("Delete Group")
					delete:SetImage("icon16/delete.png")
					delete.DoClick = function(this)
						Derma_Query("Are you sure you want to delete this group? It can NOT be undone!", "Delete Group",
						"No", function() end,
						"Yes", function()
							moderator.UpdateGroup(data, "delete")
						end)
					end
				panel.delete = delete
			end

			local found

			for k, v in pairs(moderator.groups) do
				if (groupTable == v) then continue end

				if (groupTable.inherit == k) then
					if (parent.choices[k]) then
						found = true
						parent:ChooseOptionID(parent.choices[k])

						break
					end
				end
			end

			if (!found and parent.choices.none) then
				parent:ChooseOptionID(parent.choices.none)
			end
		end

		local groupTable = moderator.GetGroupTable(moderator.lastGroup or "owner")

		for k, v in SortedPairsByMemberValue(moderator.groups, "immunity", true) do
			if (k == "__SortedIndex") then
				continue
			end

			if (!moderator.lastGroup) then
				panel.choices[k] = choose:AddChoice(v.name, k, first)
				first = false
			elseif (moderator.lastGroup == k) then
				panel.choices[k] = choose:AddChoice(v.name, k, true)
			else
				panel.choices[k] = choose:AddChoice(v.name, k)
			end
		end

		choose:AddChoice("New...")

		return true
	end

	function CATEGORY:ShouldDisplay()
		return LocalPlayer():CheckGroup("owner")
	end
moderator.menus.groups = CATEGORY