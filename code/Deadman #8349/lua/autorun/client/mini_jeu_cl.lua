include("mini_jeu_config/mini_jeu_config.lua")
AddCSLuaFile("mini_jeu_config/mini_jeu_config.lua")

--[[ Derma ]]

local mainPanelInvitationInvitation -- Defining here otherwise timer can't erase it
local function MJeuDrawInvitation(sender)
	mainPanelInvitation = vgui.Create( "DFrame" )
	mainPanelInvitation:SetSize( ScrW()/8, ScrH()/8 )
	mainPanelInvitation:SetPos( ScrW()/1.145, ScrH()/2 )
	mainPanelInvitation:ShowCloseButton( false )
	mainPanelInvitation:SetTitle( "" )
	mainPanelInvitation.Paint = function(w, h)
		surface.SetDrawColor( 0, 0, 0, 80 )
		surface.DrawTexturedRect( 0, 0, 512, 512 )

		draw.SimpleText("Invitation", "DermaDefaultBold", ScrW()/8/2.5, ScrH()/8/16, Color(255,255,255,255) )
		draw.RoundedBox( 4, ScrW()/8/13, ScrH()/8/5.5, ScrW()/8/1.15, ScrH()/512, Color(255,255,255,255) )
		draw.SimpleText(sender:Nick(), "DermaDefaultBold", ScrW()/8/2.2, ScrH()/8/3, Color(255,255,255,255) )
		draw.SimpleText("has invited you to his group", "DermaDefault", ScrW()/8/4, ScrH()/8/2, Color(255,255,255,255) )
	end

	local acceptButton = vgui.Create( "DButton", mainPanelInvitation )
	acceptButton:SetText( "Accept" )
	acceptButton:SetFont("DermaDefault")
	acceptButton:CenterVertical(0.8)
	acceptButton:CenterHorizontal(0.2)
	acceptButton:SetSize( ScrW()/20, ScrH()/32 )
	acceptButton:SetTextColor( Color(255,255,255,255) )	
	acceptButton.Paint = function(w, h)
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawRect( 0, 0, 512, 512 )
	end
	acceptButton.DoClick = function()
		mainPanelInvitation:Remove()

		timer.Remove("MJeu.Invitation.Timer")

		net.Start("MJeu.Action")
			net.WriteString("invitationAccepted")
			net.WriteEntity(sender)
		net.SendToServer()
	end

	local denyButton = vgui.Create( "DButton", mainPanelInvitation )
	denyButton:SetText( "Deny" )
	denyButton:SetFont("DermaDefault")
	denyButton:CenterVertical(0.8)
	denyButton:CenterHorizontal(0.7)
	denyButton:SetSize( ScrW()/20, ScrH()/32 )
	denyButton:SetTextColor( Color(255,255,255,255) )
	denyButton.Paint = function(w, h)
		surface.SetDrawColor( 255, 0, 0, 255 )
		surface.DrawRect( 0, 0, 512, 512 )
	end
	denyButton.DoClick = function()
		mainPanelInvitation:Remove()

		timer.Remove("MJeu.Invitation.Timer")

		net.Start("MJeu.Action")
			net.WriteString("invitationDenied")
			net.WriteEntity(sender)
		net.SendToServer()
	end
end


local function MJeuDrawmainPanel(isMaster)
	gui.EnableScreenClicker( true ) -- active la souris

	local mainPanel = vgui.Create( "DFrame" )
	mainPanel:SetSize( ScrW()/2, ScrH()/2 )
	mainPanel:CenterVertical(0.5)
	mainPanel:CenterHorizontal(0.5)
	mainPanel:ShowCloseButton( false )
	mainPanel:SetTitle( "" )
	mainPanel.Paint = function(w, h)
		surface.SetDrawColor( 254, 254, 226, 255 )
		surface.DrawRect( 0, 0, ScrW()/2, ScrH()/2 )
	end

	local armorSliderLabel = vgui.Create( "DLabel", mainPanel )
	armorSliderLabel:CenterVertical(0.13)
	armorSliderLabel:CenterHorizontal(0.14)
	armorSliderLabel:SetTextColor( Color( 0, 0, 0, 255) )
	armorSliderLabel:SetText( "Armor" )

	local armorSlider = vgui.Create( "DNumSlider", mainPanel )
	armorSlider:CenterVertical(0.2)
	armorSlider:CenterHorizontal(0.0001)
	armorSlider:SetSize( ScrW()/8, ScrH()/64 )
	armorSlider:SetText( "" )
	armorSlider:SetMin( MJeu.Armor.MinArmor )
	armorSlider:SetMax( MJeu.Armor.MaxArmor )
	armorSlider:SetValue( MJeu.Armor.MaxArmor/2 )
	armorSlider:SetDecimals( 0 ) -- 0: Decimal not allowed


	local healthSliderLabel = vgui.Create( "DLabel", mainPanel )
	healthSliderLabel:CenterVertical(0.33)
	healthSliderLabel:CenterHorizontal(0.14)
	healthSliderLabel:SetTextColor( Color( 0, 0, 0, 255) )
	healthSliderLabel:SetText( "Health" )

	local healthSlider = vgui.Create( "DNumSlider", mainPanel )
	healthSlider:CenterVertical(0.4)
	healthSlider:CenterHorizontal(0.0001)
	healthSlider:SetSize( ScrW()/8, ScrH()/64 )
	healthSlider:SetText( "" )
	healthSlider:SetMin( MJeu.Health.MinHealth )
	healthSlider:SetMax( MJeu.Health.MaxHealth )
	healthSlider:SetValue( MJeu.Health.MaxHealth/2 )
	healthSlider:SetDecimals( 0 ) -- 0: Decimal not allowed


	local runSpeedSliderLabel = vgui.Create( "DLabel", mainPanel )
	runSpeedSliderLabel:CenterVertical(0.53)
	runSpeedSliderLabel:CenterHorizontal(0.14)
	runSpeedSliderLabel:SetTextColor( Color( 0, 0, 0, 255) )
	runSpeedSliderLabel:SetText( "Run Speed" )

	local runSpeedSlider = vgui.Create( "DNumSlider", mainPanel )
	runSpeedSlider:CenterVertical(0.6)
	runSpeedSlider:CenterHorizontal(0.0001)
	runSpeedSlider:SetSize( ScrW()/8, ScrH()/64 )
	runSpeedSlider:SetText( "" )
	runSpeedSlider:SetMin( MJeu.Misc.MinRunSpeed )
	runSpeedSlider:SetMax( MJeu.Misc.MaxRunSpeed )
	runSpeedSlider:SetValue( MJeu.Misc.MaxRunSpeed/2 )
	runSpeedSlider:SetDecimals( 0 ) -- 0: Decimal not allowed


	local jumpForceLabel = vgui.Create( "DLabel", mainPanel )
	jumpForceLabel:CenterVertical(0.73)
	jumpForceLabel:CenterHorizontal(0.14)
	jumpForceLabel:SetTextColor( Color( 0, 0, 0, 255) )
	jumpForceLabel:SetText( "Jump Force" )

	local jumpForceSlider = vgui.Create( "DNumSlider", mainPanel )
	jumpForceSlider:CenterVertical(0.8)
	jumpForceSlider:CenterHorizontal(0.0001)
	jumpForceSlider:SetSize( ScrW()/8, ScrH()/64 )
	jumpForceSlider:SetText( "" )
	jumpForceSlider:SetMin( MJeu.Misc.MinJumpForce )
	jumpForceSlider:SetMax( MJeu.Misc.MaxJumpForce )
	jumpForceSlider:SetValue( MJeu.Misc.MaxJumpForce/2 )
	jumpForceSlider:SetDecimals( 0 ) -- 0: Decimal not allowed

	local weaponsList
	if MJeu.Weapons.MasterDecide then
		weaponsList = vgui.Create( "DComboBox", mainPanel )
		weaponsList:CenterVertical(0.13)
		weaponsList:CenterHorizontal(0.3)
		weaponsList:SetSize( ScrW()/16, ScrH()/54 )
		weaponsList:SetValue( "Choose a weapon" )
		weaponsList:AddChoice( "Random Weapon" )
		for _, v in pairs(MJeu.Weapons.List) do
			weaponsList:AddChoice( v.WeaponName )
		end
	end

	local modelsListLeaderLabel = vgui.Create( "DLabel", mainPanel )
	modelsListLeaderLabel:CenterVertical(0.35)
	modelsListLeaderLabel:CenterHorizontal(0.5)
	modelsListLeaderLabel:SetTextColor( Color( 0, 0, 0, 255) )
	modelsListLeaderLabel:SetText( "Model Selector (Leader)" )
	modelsListLeaderLabel:SizeToContents()

	local modelsListLeader = vgui.Create( "DModelSelect", mainPanel )
	modelsListLeader:CenterVertical(0.5)
	modelsListLeader:CenterHorizontal(0.45)
	modelsListLeader:SetModelList( MJeu.Skins.List, "", false, true )
	modelsListLeader:SetSize(200, 200)


	local modelsListPlayerLabel = vgui.Create( "DLabel", mainPanel )
	modelsListPlayerLabel:CenterVertical(0.35)
	modelsListPlayerLabel:CenterHorizontal(0.75)
	modelsListPlayerLabel:SetTextColor( Color( 0, 0, 0, 255) )
	modelsListPlayerLabel:SetText( "Model Selector (Player)" )
	modelsListPlayerLabel:SizeToContents()

	local modelsListPlayer = vgui.Create( "DModelSelect", mainPanel )
	modelsListPlayer:CenterVertical(0.5)
	modelsListPlayer:CenterHorizontal(0.7)
	modelsListPlayer:SetModelList( MJeu.Skins.List, "", false, true )
	modelsListPlayer:SetSize(200, 200)



	local crossClose = vgui.Create( "DButton", mainPanel )
	crossClose:SetText( "X" )
	crossClose:SetFont("DermaLarge")
	crossClose:CenterVertical(0.05)
	crossClose:CenterHorizontal(0.98)
	crossClose:SetSize( ScrW()/60, ScrH()/32 )
	crossClose:SetTextColor( Color(255,0,0,255) )
	crossClose.Paint = function(w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, 512, 512 )
	end
	crossClose.DoClick = function()
		mainPanel:Remove()
		gui.EnableScreenClicker( false ) -- désactive la souris
	end

	local closeMenuButton = vgui.Create( "DButton", mainPanel )
	if isMaster then
		closeMenuButton:SetText( "Start Game" )
	else
		closeMenuButton:SetText( "Close" )
	end
	closeMenuButton:SetFont("DermaDefault")
	closeMenuButton:CenterVertical(0.92)
	closeMenuButton:CenterHorizontal(0.9)
	closeMenuButton:SetSize( ScrW()/20, ScrH()/32 )
	closeMenuButton:SetTextColor( Color(255,255,255,255) )
	closeMenuButton.Paint = function(w, h)
		if isMaster then
			surface.SetDrawColor( 0, 255, 0, 255 )
		else
			surface.SetDrawColor( 0, 0, 255, 255 )
		end
		surface.DrawRect( 0, 0, 512, 512 )
	end
	closeMenuButton.DoClick = function()
		if isMaster then
			net.Start("MJeu.Action")
				net.WriteString("editParameters")
				net.WriteInt(armorSlider:GetValue(), 9)
				net.WriteInt(healthSlider:GetValue(), 32)
				net.WriteInt(runSpeedSlider:GetValue(), 16)
				net.WriteInt(jumpForceSlider:GetValue(), 16)
				if MJeu.Weapons.MasterDecide then
					net.WriteString(weaponsList:GetValue())
				else
					net.WriteString("") -- Random
				end
				if MJeu.Skins.ChangeSkin then
					net.WriteString(modelsListLeader:GetValue())
					net.WriteString(modelsListPlayer:GetValue())
				else
					net.WriteString("") -- Random
					net.WriteString("") -- Random
				end
			net.SendToServer()
		end

		mainPanel:Remove()
		gui.EnableScreenClicker( false ) -- désactive la souris
	end
end

local mainPanelTimer -- Defining here to allow erase below
local function MJeuDrawTimer()
	timer.Create("MJeuGameTimer", MJeu.Misc.MaxTime-1, 1, function()
		if mainPanelTimer:IsValid() then
			mainPanelTimer:Remove()
		end
	end)


	mainPanelTimer = vgui.Create( "DFrame" )
	mainPanelTimer:SetSize( ScrW()/16, ScrH()/32 )
	mainPanelTimer:CenterVertical(0.02)
	mainPanelTimer:CenterHorizontal(0.5)
	mainPanelTimer:ShowCloseButton( false )
	mainPanelTimer:SetTitle( "" )
	mainPanelTimer.Paint = function(w, h)
		surface.SetDrawColor( 0, 0, 0, 80 )
		surface.DrawTexturedRect( 0, 0, 512, 512 )

		draw.SimpleText("Time left: "..math.Round(timer.TimeLeft("MJeuGameTimer"), 1), "DermaDefaultBold", ScrW()/85, ScrH()/8/16, Color(255,255,255,255) )
	end
end


--[[ Custom functions ]]

local function MJeuNotifications(text, notifType, length, sound)
	if sound ~= "" then
		notification.AddLegacy( text, notifType, length )
		surface.PlaySound( sound )
	else
		notification.AddLegacy( text, notifType, length )
		surface.PlaySound( "buttons/button15.wav" )
	end
end

local function MJeuStartGame()
	chat.AddText(Color(255,255,255), "Game starting in "..MJeu.Misc.BeginStart)

	timer.Create("MJeuStartGame", 1, MJeu.Misc.BeginStart, function()
		if timer.RepsLeft("MJeuStartGame") > 0 then
			chat.AddText(Color(255,255,255), "Game starting in "..timer.RepsLeft("MJeuStartGame"))
		else
			chat.AddText(Color(255,100,100), "GET READY FOR RUMBLEEEE")
			chat.PlaySound()

			MJeuDrawTimer()
		end
	end)
end

local function MJeuGameFinished(winner, looser)
	timer.remove("MJeuGameTimer")
	if LocalPlayer() == winner then
		chat.AddText(Color(100,255,100), "Congratulations, you have beat "..looser:Nick().." !")
	else
		chat.AddText(Color(255,100,100), "Oh no , you have been beaten by "..winner:Nick().." !")
	end
	chat.PlaySound()
end


--[[ Net messages ]]

net.Receive("MJeu.Notification", function()
	MJeuNotifications(net.ReadString(), net.ReadInt(4), net.ReadInt(5), net.ReadString())
end)

net.Receive("MJeu.Action", function()
	local action = net.ReadString()

	if action == "invitation" then
		MJeuDrawInvitation(net.ReadEntity())

		timer.Create("MJeu.Invitation.Timer", 30, 1, function() mainPanelInvitation:Remove() surface.PlaySound( "buttons/button15.wav" ) end)
	elseif action == "openConfigMenu" then
		MJeuDrawmainPanel(net.ReadBool())
	elseif action == "startGame" then
		MJeuStartGame()
	elseif action == "gameEnded" then
		MJeuGameFinished(net.ReadEntity(), net.ReadEntity())
	end
end)