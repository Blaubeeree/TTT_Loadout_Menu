---- TTT Weapon Loadouts Serverside ----
-- Author: Blaubeeree

util.AddNetworkString("loadout_openmenu")
util.AddNetworkString("loadout_submit")
util.AddNetworkString("loadout_echo")
util.AddNetworkString("loadout_received")
util.AddNetworkString("loadout_config")

CreateConVar("loadout_denyMsg", "You're not allowed to use the loadout menu!", FCVAR_ARCHIVE)
CreateConVar("loadout_chatCmd", "!loadout", FCVAR_ARCHIVE)

local primary = {}
local secondary = {}
local grenades = {}

-- Creating Datafiles
if not file.Exists("loadout_menu", "DATA") then
	file.CreateDir("loadout_menu")
end

local ReadMe =
	[[
File Syntax:
{"Weapon-/Grenadename":["Weapon-/Grenadeclass","Iconpath"],"Weapon-/Grenadename":["Weapon-/Grenadeclass","Iconpath"]}
e.g.:
{"M16":["weapon_ttt_m16","vgui/ttt/icon_m16"],"Shotgun":["weapon_zm_shotgun","vgui/ttt/icon_shotgun"],"Scout":["weapon_zm_rifle","vgui/ttt/icon_scout"],"HUGE":["weapon_zm_sledge","vgui/ttt/icon_m249"],"Mac10":["weapon_zm_mac10","vgui/ttt/icon_mac"]}

Outside the "" you can add as much spaces and new lines as you like.
]]
file.Write("loadout_menu/.ReadMe.txt", ReadMe)

local primarydefault = {
	M16 = { "weapon_ttt_m16", "vgui/ttt/icon_m16" },
	Shotgun = { "weapon_zm_shotgun", "vgui/ttt/icon_shotgun" },
	HUGE = { "weapon_zm_sledge", "vgui/ttt/icon_m249" },
	Mac10 = { "weapon_zm_mac10", "vgui/ttt/icon_mac" },
	Scout = { "weapon_zm_rifle", "vgui/ttt/icon_scout" },
}
if not file.Exists("loadout_menu/primary.txt", "DATA") then
	file.Write("loadout_menu/primary.txt", util.TableToJSON(primarydefault))
end

local secondarydefault = {
	["Five Seven"] = { "weapon_zm_pistol", "vgui/ttt/icon_pistol" },
	Glock = { "weapon_ttt_glock", "vgui/ttt/icon_glock" },
	Deagle = { "weapon_zm_revolver", "vgui/ttt/icon_deagle" },
}
if not file.Exists("loadout_menu/secondary.txt", "DATA") then
	file.Write("loadout_menu/secondary.txt", util.TableToJSON(secondarydefault))
end

local grenadesdefault = {
	Incendinary = { "weapon_zm_molotov", "vgui/ttt/icon_nades" },
	Discombobulator = { "weapon_ttt_confgrenade", "vgui/ttt/icon_nades" },
	Smoke = { "weapon_ttt_smokegrenade", "vgui/ttt/icon_nades" },
}
if not file.Exists("loadout_menu/grenades.txt", "DATA") then
	file.Write("loadout_menu/grenades.txt", util.TableToJSON(grenadesdefault))
end

-- Reading Datafiles
primary = util.JSONToTable(file.Read("loadout_menu/primary.txt", "DATA"))
secondary = util.JSONToTable(file.Read("loadout_menu/secondary.txt", "DATA"))
grenades = util.JSONToTable(file.Read("loadout_menu/grenades.txt", "DATA"))

if not primary then
	primary = {}
	ErrorNoHalt("[Error] Error in data/loadout_menu/primary.txt\n")
end
if not secondary then
	secondary = {}
	ErrorNoHalt("[Error] Error in data/loadout_menu/secondary.txt\n")
end
if not grenades then
	grenades = {}
	ErrorNoHalt("[Error] Error in data/loadout_menu/grenades.txt\n")
end

-- Send config to connecting players
hook.Add("PlayerSpawn", "Loadout_Datafiles_Send", function(ply)
	net.Start("loadout_config")
	net.WriteString(GetConVar("loadout_denyMsg"):GetString())
	net.WriteTable(primary)
	net.WriteTable(secondary)
	net.WriteTable(grenades)
	net.Broadcast()
end)

net.Receive("loadout_submit", function(len, ply)
	local tbl = net.ReadTable()

	local empty = true
	for _ in pairs(tbl) do
		empty = false
	end

	if empty then
		ply:SetPData("TTTLoadoutOn", false)
		return
	end

	ply:SetPData("TTTLoadoutOn", true) -- PData persists so we use it for a more permanent approach
	ply:SetPData("TTTPrimary", tbl.primary or "")
	ply:SetPData("TTTSecondary", tbl.secondary or "")
	ply:SetPData("TTTGrenade", tbl.grenade or "")
end)

hook.Add("TTTBeginRound", "loadout_distribute", function()
	for k, ply in pairs(player.GetAll()) do
		if ply:GetPData("TTTLoadoutOn", false) == "true" and
			not ply:IsSpec() and
			ply:Alive() and
			ply:canUseLoadout()
		then
			-- Grab the loadouts from PData
			local p = ply:GetPData("TTTPrimary", "")
			local s = ply:GetPData("TTTSecondary", "")
			local g = ply:GetPData("TTTGrenade", "")

			print(ply:Nick() .. " has been given a loadout!")

			if p ~= "" then
				for _, wep in pairs(ply:GetWeapons()) do
					if wep.Kind == WEAPON_HEAVY then
						ply:StripWeapon(wep:GetClass())
					end
					ply:Give(p)
					ply:SetAmmo(weapons.Get(p).Primary.ClipMax, weapons.Get(p).Primary.Ammo)
				end
			end

			if s ~= "" then
				for _, wep in pairs(ply:GetWeapons()) do
					if wep.Kind == WEAPON_PISTOL then
						ply:StripWeapon(wep:GetClass())
					end
					ply:Give(s)
					ply:SetAmmo(weapons.Get(s).Primary.ClipMax, weapons.Get(s).Primary.Ammo)
				end
			end

			if g ~= "" then
				for _, wep in pairs(ply:GetWeapons()) do
					if wep.Kind == WEAPON_NADE then
						ply:StripWeapon(wep:GetClass())
					end
					ply:Give(g)
				end
			end

			net.Start("loadout_received")
			net.WriteString(GetConVar("loadout_chatCmd"):GetString())
			net.Send(ply)
		end
	end
end)

--// Opens the loadout menu
hook.Add("PlayerSay", "loadout_chatcommand", function(ply, text, public)
	local text = string.lower(text)
	if text:lower() == GetConVar("loadout_chatCmd"):GetString() then
		net.Start("loadout_openmenu")
		net.Send(ply)
	end
end)

--// Tells the player what their loadout is
-- TODO change command with convar (maybe together with "loadout_chatCmd" convar)
hook.Add("PlayerSay", "loadout_weaponprint", function(ply, text, public)
	local text = string.lower(text)
	if text:lower() == "!loadoutprint" then
		local p = ply:GetPData("TTTPrimary", "none")
		local s = ply:GetPData("TTTSecondary", "none")
		local g = ply:GetPData("TTTGrenade", "none")
		local tab = { p, s, g }

		net.Start("loadout_echo")
		net.WriteTable(tab)
		net.Send(ply)

		return false
	end
end)