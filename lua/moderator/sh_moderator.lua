if (CLIENT) then
	local rgb = Color

	moderator.colors = {
		red = rgb(192, 57, 43),
		orange = rgb(211, 84, 0),
		yellow = rgb(241, 196, 15),
		green = rgb(39, 174, 96),
		blue = rgb(41, 128, 185),
		purple = rgb(142, 68, 173),
		dark = rgb(43, 45, 50),
		light =  rgb(189, 195, 199)
	}

	moderator.colorsSorted = {
		{"red", rgb(192, 57, 43)},
		{"orange", rgb(211, 84, 0)},
		{"yellow", rgb(241, 196, 15)},
		{"green", rgb(39, 174, 96)},
		{"blue", rgb(41, 128, 185)},
		{"purple", rgb(142, 68, 173)},
		{"dark", rgb(43, 45, 50)},
		{"light", rgb(189, 195, 199)}
	}

	MOD_MAINCOLOR = CreateClientConVar("mod_color", "dark", true)

	cvars.AddChangeCallback("mod_color", function(conVar, previous, value)
		local value = moderator.colors[MOD_MAINCOLOR:GetString()]

		if (value) then
			moderator.color = value
		end
	end)

	moderator.color = moderator.colors.dark

	local value = moderator.colors[MOD_MAINCOLOR:GetString()]

	if (value) then
		moderator.color = value
	end
end

moderator.version = "In-Dev"
moderator.IncludeFolder("libs")
moderator.IncludeFolder("commands")
moderator.IncludeFolder("derma")

-- Include the menus.
do
	if (CLIENT) then
		moderator.menus = {}
	end

	moderator.IncludeFolder("derma/menus")
end