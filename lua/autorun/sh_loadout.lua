---- TTT Weapon Loadouts ----
-- Author: Blaubeeree
loadout_menu = {}

timer.Simple(0, function()
	local plymeta = FindMetaTable("Player")
	-- ULX
	if ulx then
		if SERVER then
			ULib.ucl.registerAccess(
				"loadout_menu",
				ULib.ACCESS_ADMIN,
				"Grants access to use the Loadout Menu",
				"Other"
			)
		end

		function plymeta:canUseLoadout()
			if ULib.ucl.query(self, "loadout_menu") then
				return true
			else
				return false
			end
		end
	-- no ULX
	else
		CreateConVar(
			"loadout_everyonecanuse",
			1,
			{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE },
			"1= Everyone can use the Loadout, 0= Only Admins can use the Loadout."
		)

		function plymeta:canUseLoadout()
			if GetConVar("loadout_everyonecanuse"):GetBool() or self:IsAdmin() then
				return true
			else
				return false
			end
		end
	end
end)