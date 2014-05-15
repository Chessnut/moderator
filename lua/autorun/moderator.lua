moderator = moderator or {}

if (SERVER) then
	include("moderator/sv_moderator.lua")
	AddCSLuaFile("moderator/cl_moderator.lua")

	resource.AddFile("materials/moderator/leave.png")
	resource.AddFile("materials/moderator/menu.png")
else
	include("moderator/cl_moderator.lua")
end