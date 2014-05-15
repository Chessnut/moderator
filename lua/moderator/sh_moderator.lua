-- Originally found in dev branch for Garry's Mod but we need it here
-- for the live version as well.
do
	local function pluralizeString(str, quantity)
		return str .. ((quantity ~= 1) and "s" or "")
	end

	function string.NiceTime( seconds )

		if ( seconds == nil ) then return "a few seconds" end

		if ( seconds < 60 ) then
			local t = math.floor( seconds )
			return t .. pluralizeString(" second", t);
		end

		if ( seconds < 60 * 60 ) then
			local t = math.floor( seconds / 60 )
			return t .. pluralizeString(" minute", t);
		end

		if ( seconds < 60 * 60 * 24 ) then
			local t = math.floor( seconds / (60 * 60) )
			return t .. pluralizeString(" hour", t);
		end

		if ( seconds < 60 * 60 * 24 * 7 ) then
			local t = math.floor( seconds / (60 * 60 * 24) )
			return t .. pluralizeString(" day", t);
		end

		if ( seconds < 60 * 60 * 24 * 7 * 52 ) then
			local t = math.floor( seconds / (60 * 60 * 24 * 7) )
			return t .. pluralizeString(" week", t);
		end

		local t = math.floor( seconds / (60 * 60 * 24 * 7 * 52) )
		return t .. pluralizeString(" year", t);

	end
end

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