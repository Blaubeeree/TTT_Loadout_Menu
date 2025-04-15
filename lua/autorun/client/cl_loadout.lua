---- TTT Weapon Loadouts Clientside ----
-- Author: Blaubeeree

local version = "2025/04/15"
local menuOpen = false

net.Receive("loadout_config", function(len, client)
	local denyMsg = net.ReadString()
	local primary = net.ReadTable()
	local secondary = net.ReadTable()
	local grenades = net.ReadTable()

	-- Create a fancy font to use
	surface.CreateFont("WeaponCategory", {
		font = "Arial",
		size = 20,
		weight = 1000,
		antialias = true,
	})

	-- Prints a colored chat message
	local function chatMessage(args)
		chat.AddText(Color(200, 50, 200), "Loadout: ", Color(255, 255, 255), args)
	end

	net.Receive("loadout_openmenu", function(len, client)
		openLoadoutMenu()
	end)

	net.Receive("loadout_echo", function(len, client)
		local tab = net.ReadTable()
		local selectedprimary = tab[1]
		local selectedsecondary = tab[2]
		local selectedgrenade = tab[3]

		chatMessage(
			"Your loadout includes: " .. selectedprimary .. ", " .. selectedsecondary .. ", and " .. selectedgrenade
		)
	end)

	net.Receive("loadout_received", function(len, client)
		chatMessage(
			"Recieved loadout weapons! Type " .. net.ReadString() .. " to change your loadout or disable them entirely."
		)
	end)

	function openLoadoutMenu()
		local client = LocalPlayer()
		local pChoice, sChoice, gChoice

		if not client:canUseLoadout() then
			return chatMessage(denyMsg)
		end

		if menuOpen then return end -- prevents menu to open multible times
		menuOpen = true

		-- Creating the actual frame
		local frame = vgui.Create("DFrame") -- frame was declared earlier, so this can be local
		frame:SetSize(500, 300)
		frame:Center()
		frame:SetTitle("TTT Loadout")
		frame:MakePopup()
		frame.Paint = function(self, w, h)
			-- The actual panel and then the primary area. Colors are defined above
			draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 10, 230))
			draw.RoundedBox(0, 10, 30, w - 30, 30, Color(34, 42, 60))
			draw.RoundedBox(0, 10, 65, w - 30, 75, Color(44, 62, 80))
			-- Secondary area
			draw.RoundedBox(0, 10, 150, w / 2.3, 30, Color(34, 42, 60))
			draw.RoundedBox(0, 10, 185, w / 2.3, 75, Color(44, 62, 80))
			-- Grenade area
			draw.RoundedBox(0, 263, 150, w / 2.3, 30, Color(34, 42, 60))
			draw.RoundedBox(0, 263, 185, w / 2.3, 75, Color(44, 62, 80))
		end

		------ BUTTONS ------
		local btnSubmit = vgui.Create("DButton", frame)
		btnSubmit:SetText("Submit")
		btnSubmit:SetPos(400, 265)
		btnSubmit:SetSize(80, 30)
		btnSubmit:SetTooltip("Confirm your selection of weapons for your loadout")
		btnSubmit.DoClick = function()
			-- Grabs choices, puts em into a table, and sends the table to the server
			chatMessage("Loadout changes confirmed!")

			local tbl = {}
			tbl.primary = pChoice
			tbl.secondary = sChoice
			tbl.grenade = gChoice

			net.Start("loadout_submit")
			net.WriteTable(tbl)
			net.SendToServer()

			frame:Close()
		end

		local btnDisable = vgui.Create("DButton", frame)
		btnDisable:SetText("Disable")
		btnDisable:SetPos(10, 265)
		btnDisable:SetSize(80, 30)
		btnDisable:SetTooltip("Disables loadouts")
		btnDisable.DoClick = function()
			chatMessage("Disabled your loadouts! Submit new ones to enable again.")

			net.Start("loadout_submit")
			net.SendToServer()

			frame:Close()
		end

		------ PRIMARY WEAPONS ------
		local lblPrimary = vgui.Create("DLabel", frame)
		lblPrimary:SetPos(20, 37)
		lblPrimary:SetColor(color_white)
		lblPrimary:SetFont("WeaponCategory")
		lblPrimary:SetText("Primary")
		lblPrimary:SizeToContents()

		local scrollPrimary = vgui.Create("DHorizontalScroller", frame)
		scrollPrimary:SetSize(frame:GetWide() - 30, 65)
		scrollPrimary:SetPos(15, 70)

		for name, tbl in pairs(primary) do
			local class = tbl[1]
			local icon = tbl[2]
			local btnWeapon = vgui.Create("DImageButton", frame)
			btnWeapon:SetSize(64, 64)
			btnWeapon:SetTooltip(name)
			btnWeapon:SetImage(icon or "vgui/ttt/icon_nades.vtf")
			btnWeapon.DoClick = function()
				surface.PlaySound("buttons/button14.wav")

				pChoice = class
				chatMessage("Selected " .. name .. "!")
			end

			scrollPrimary:AddPanel(btnWeapon)
		end

		------ SECONDARY WEAPONS ------
		local lblSecondary = vgui.Create("DLabel", frame)
		lblSecondary:SetPos(20, 157)
		lblSecondary:SetColor(color_white)
		lblSecondary:SetFont("WeaponCategory")
		lblSecondary:SetText("Secondary")
		lblSecondary:SizeToContents()

		local scrollSecondary = vgui.Create("DHorizontalScroller", frame)
		scrollSecondary:SetSize(frame:GetWide() / 2 - 45, 65)
		scrollSecondary:SetPos(15, 190)

		for name, tbl in pairs(secondary) do
			local class = tbl[1]
			local icon = tbl[2]
			local btnWeapon = vgui.Create("DImageButton", frame)
			btnWeapon:SetSize(64, 64)
			btnWeapon:SetTooltip(name)
			btnWeapon:SetImage(icon or "vgui/ttt/icon_nades.vtf")
			btnWeapon.DoClick = function()
				surface.PlaySound("buttons/button14.wav")

				sChoice = class
				chatMessage("Selected " .. name .. "!")
			end

			scrollSecondary:AddPanel(btnWeapon)
		end

		------ EXTRA WEAPONS ------
		local lblGrenades = vgui.Create("DLabel", frame)
		lblGrenades:SetPos(275, 157)
		lblGrenades:SetColor(color_white)
		lblGrenades:SetFont("WeaponCategory")
		lblGrenades:SetText("Grenade")
		lblGrenades:SizeToContents()

		local scrollGrenades = vgui.Create("DHorizontalScroller", frame)
		scrollGrenades:SetSize(frame:GetWide() / 2 - 45, 65)
		scrollGrenades:SetPos(270, 190)

		for name, tbl in pairs(grenades) do
			local class = tbl[1]
			local icon = tbl[2]
			local btnWeapon = vgui.Create("DImageButton", frame)
			btnWeapon:SetSize(64, 64)
			btnWeapon:SetImage(icon or "vgui/ttt/icon_id")
			btnWeapon:SetTooltip(name)
			btnWeapon.DoClick = function()
				surface.PlaySound("buttons/button14.wav")

				gChoice = class
				chatMessage("Selected " .. name .. "!")
			end

			scrollGrenades:AddPanel(btnWeapon)
		end
		function frame:OnClose()
			menuOpen = false
		end
	end

	concommand.Add("loadout_open", function(client)
		openLoadoutMenu()
	end)

	concommand.Add("loadout_version", function(client)
		print("**** Blaubeeree's Weapon Loadout Addon ****")
		print("Version " .. version)
	end)

	if TTT2 then
		AddTTT2AddonDev("76561198329270449")

		bind.Register(
			"loadout_open",
			function()
				openLoadoutMenu()
			end,
			function() end,
			"Other Bindings",
			"Loadout Menu",
			97
		)
	else
		CreateClientConVar(
			"loadout_key",
			"F6",
			true,
			false,
			"Set a key to open the Loadout Menu. (F1 - F12)"
		)
		local keys_pressed = {}
		hook.Add("Think", "Loadout_CheckKeyPress", function()
			for i = 92, 103 do
				if input.IsKeyDown(i) then
					if keys_pressed[i] then return end
					if input.GetKeyName(i) == GetConVar("loadout_key"):GetString() then
						openLoadoutMenu()
					end
					keys_pressed[i] = true
				elseif keys_pressed[i] then
					keys_pressed[i] = nil
				end
			end
		end)
	end
end)