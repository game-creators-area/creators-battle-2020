include("mini_jeu_config/mini_jeu_config.lua")
AddCSLuaFile("mini_jeu_config/mini_jeu_config.lua")

util.AddNetworkString("MJeu.Action")
util.AddNetworkString("MJeu.Notification")


--[[ Custom Functions ]]

local function MJeuNotif(ply, text, notifType, length, sound)
	net.Start("MJeu.Notification")
		net.WriteString(text)
		net.WriteInt(notifType, 4)
		net.WriteInt(length, 5)
		net.WriteString(sound or "")
	net.Send(ply)
end


local function MJeuVictory(players, winner, looser)
	net.Start("MJeu.Action")
		net.WriteString("gameEnded")
		net.WriteEntity(winner)
		net.WriteEntity(looser)
	net.Send(players) -- 2 players normally

	timer.Remove("MJeuTimerGame") -- Removing timer for the game
end





--[[ Hooks ]]

local function MJeuPlayerDeath(victim, inflictor, attacker)
	if attacker.MJeuInGame then
		local playersList = {}
		table.insert(playersList, victim)
		table.insert(playersList, attacker)

		MJeuVictory(playersList, attacker, victim)

		timer.Simple(2, function()
			for _, v in pairs(playersList) do
				v:Spawn()

				v:SetModel(v.MJeuPreviousStuff.Skin)
				v:SetHealth(v.MJeuPreviousStuff.Health)
				v:SetPos(v.MJeuPreviousStuff.Pos)
				v:SetEyeAngles(v.MJeuPreviousStuff.Ang)
				v:SetArmor(v.MJeuPreviousStuff.Armor)
				v:SetRunSpeed(v.MJeuPreviousStuff.RunSpeed)
				v:SetJumpPower(v.MJeuPreviousStuff.JumpForce)

				for _, swep in pairs(v.MJeuPreviousStuff.Weapons) do
			 		local actualSwepString = string.Explode("[", tostring(swep))[3] -- keep only "weapon_crossbow]"
			 		actualSwepString = string.Replace(actualSwepString, "]", "" )
				end

				v.MJeuInGame = false
			end
		end)
	end
end
hook.Add( "PlayerDeath", "MJEU.PlayerDeath", MJeuPlayerDeath )


local function MJeuInitialSpawn(ply)
	ply:SetNWEntity("MJeu.Mate", game.GetWorld())
	ply.MJeuInGame = false
end
hook.Add( "PlayerInitialSpawn", "MJEU.PlayerInitialSpawn", MJeuInitialSpawn )



local function MJeuEntityTakeDamage(target, damage)
	if damage:IsFallDamage() and target.MJeuInGame and not MJeu.Misc.FallDamage then -- Désactivation des dégtas de chute si désiré
		damage:SetDamage(0)
	elseif damage:GetAttacker().MJeuInGame and not target.MJeuInGame then -- Si un mec dans la partie tire sur quelqu'un qui n'est pas dans la partie
		damage:SetDamage(0)
	elseif not damage:GetAttacker().MJeuInGame and target.MJeuInGame then -- Si un mec qui n'est pas dans la partie tire sur quelqu'un dans la partie
		damage:SetDamage(0)
	end
end
hook.Add( "EntityTakeDamage", "MJEU.EntityTakeDamage", MJeuEntityTakeDamage )


local function MJeuCommand( ply, text )
	local playerInput = string.Explode( " ", text )

	if playerInput[1] == MJeu.Misc.CommandMenu then 

		if not ply:GetNWEntity("MJeu.Mate"):IsWorld() then
			net.Start("MJeu.Action")
				net.WriteString("openConfigMenu")
				if ply.MJeuIsMaster then
					net.WriteBool(true)
				else
					net.WriteBool(false)
				end
			net.Send(ply)
		else
				MJeuNotif(ply, "You are not in a group !", 1, 4)
		end

	elseif playerInput[1] == MJeu.Misc.CommandLeave then 

		if not ply:GetNWEntity("MJeu.Mate"):IsWorld() then -- si y a quelqu'un dans le groupe
			local mate = ply:GetNWEntity("MJeu.Mate")
			mate:SetNWEntity("MJeu.Mate", game.GetWorld())
			ply:SetNWEntity("MJeu.Mate", game.GetWorld())

			mate.MJeuIsMaster = nil
			ply.MJeuIsMaster = nil

			MJeuNotif(mate, ply:Nick().." have leave your group !", 3, 4)
			MJeuNotif(ply, "You have leave your group !", 0, 4)
		else
			MJeuNotif(ply, "You are not in a group !", 1, 4)
		end

	elseif playerInput[1] == MJeu.Misc.CommandInvite then

		if not ply:GetNWEntity("MJeu.Mate"):IsWorld() then -- si y a déjà quelqu'un dans son groupe
			MJeuNotif(ply, "There is already "..ply:GetNWEntity("MJeu.Mate"):Nick().." in your group !", 1, 4)
		else
			if not playerInput[2] then
				MJeuNotif(ply, "You have to specify a player name, a steamID or a steamID64", 1, 4)
			else
				local playerFinded = false -- init at false

				for _, v in pairs(player.GetAll()) do
					if (v:Nick() == table.concat(playerInput, " ", 2)) or (v:SteamID() == playerInput[2]) or (v:SteamID64() == playerInput[2]) and v:SteamID64() ~= ply:SteamID64() then
						playerFinded = true
						MJeuNotif(ply, v:Nick().." has received your invitation !", 0, 4)
						ply.MJeuInviteTime = CurTime()

						net.Start("MJeu.Action")
							net.WriteString("invitation")
							net.WriteEntity(ply)
						net.Send(v)
						break
					end
				end

				if not playerFinded then
					MJeuNotif(ply, "No players finded for '"..playerInput[2].."'", 1, 4)
				end
			end
		end
	end
end
hook.Add("PlayerSay", "MJEU.PlayerSay", MJeuCommand)



--[[ Nets message ]]

net.Receive("MJeu.Action", function(len, ply)
	local action = net.ReadString()

	if action == "invitationAccepted" then
		local originalSender = net.ReadEntity()

		ply:SetNWEntity("MJeu.Mate", originalSender)
		originalSender:SetNWEntity("MJeu.Mate", ply)
		ply.MJeuIsMaster = false
		originalSender.MJeuIsMaster = true

		MJeuNotif(originalSender, ply:Nick().." has accepted your invitation", 0, 4)
	elseif action == "invitationDenied" then
		local originalSender = net.ReadEntity()

		if not originalSender.MJeuInviteTime == nil then
			if originalSender.MJeuInviteTime + 30 < CurTime() then -- Avoid exploit if client spam with malicious code
				MJeuNotif(originalSender, ply:Nick().." has declined your invitation", 1, 4)
			end
		end
	elseif action == "editParameters" then
		if not ply.MJeuIsMaster then  -- Si le joeuur n'est pas le chef du groupe
			MJeuNotif(ply, "You are not allowed to edit theses settings", 1, 4)
		else
			local armor = net.ReadInt(9)
			local health = net.ReadInt(32)
			local runSpeed = net.ReadInt(16)
			local jumpForce = net.ReadInt(16)
			local weaponChoosed = net.ReadString()
			local skinLeader = net.ReadString()
			local skinPlayer = net.ReadString()

			if armor < MJeu.Armor.MinArmor or armor >  MJeu.Armor.MaxArmor then
				armor = MJeu.Armor.MaxArmor/2
			end

			if health < MJeu.Health.MinHealth or health > MJeu.Health.MaxHealth then
				health = MJeu.Health.MaxHealth/2
			end

			if runSpeed < MJeu.Misc.MinRunSpeed or runSpeed > MJeu.Misc.MaxRunSpeed then
				runSpeed = MJeu.Misc.MaxRunSpeed/2
			end

			if jumpForce < MJeu.Misc.MinJumpForce or jumpForce > MJeu.Misc.MaxJumpForce then
				jumpForce = MJeu.Misc.MaxJumpForce/2
			end

			local weaponAllowed = false
			for _, swep in pairs(MJeu.Weapons.List) do
				if weaponChoosed == swep["WeaponName"] then
					weaponAllowed = true
				end
			end
			if not weaponAllowed then
				local tableRandom = table.Random(MJeu.Weapons.List) -- une des tables d'armes
				weaponChoosed = tableRandom["WeaponName"]
			end

			local skinLeaderAllowed, skinPlayerAllowed = false, false
			for skin, _ in pairs(MJeu.Skins.List) do
				if skinLeader == skin then
					skinLeaderAllowed = true
				end

				if skinPlayer == skin then
					skinPlayerAllowed = true
				end
			end
			if not skinLeaderAllowed then
				skinLeader = table.KeyFromValue( MJeu.Skins.List, true )
			end
			if not skinPlayerAllowed then				
				skinPlayer = table.KeyFromValue( MJeu.Skins.List, true )
			end

			local playersList = {}
			table.insert(playersList, ply)
			table.insert(playersList, ply:GetNWEntity("MJeu.Mate"))

			for _, v in pairs(playersList) do
				v.MJeuPreviousStuff = {
										["Skin"] = v:GetModel(),
										["Health"] = v:Health(),
										["Pos"] = v:GetPos(), 
										["Ang"] = v:EyeAngles(),
										["Armor"] = v:Armor(),
										["RunSpeed"] = v:GetRunSpeed(),
										["JumpForce"] = v:GetJumpPower(),
										["Weapons"] = {},
									}
				-- Conversion en String pour permettre le give plus tard
				for _, swep in pairs(v:GetWeapons()) do
			 		local actualSwepString = string.Explode("[", tostring(swep))[3] -- keep only "weapon_crossbow]"
			 		actualSwepString = string.Replace(actualSwepString, "]", "" ) -- removing the "]"
			 		table.insert(v.MJeuPreviousStuff.Weapons, actualSwepString)
				end


				-- On enlève les armes du joueur
				v:StripWeapons()

				-- On leurs met leur skin respectif
				if v.MJeuIsMaster then
					v:SetModel(skinLeader)
				else
					v:SetModel(skinPlayer)
				end

				-- On leur applique leurs paramètres
				v:SetHealth(health)
				v:SetMaxHealth(health)
				v:SetArmor(armor)
				v:SetRunSpeed(runSpeed)
				v:SetJumpPower(jumpForce)

				v:SetPos(MJeu.Teleportation[i]["Pos"])
				v:SetEyeAngles( MJeu.Teleportation[i]["Ang"] )

				v:Freeze(true)

				-- On give les armes
				for _, wep in pairs(MJeu.Weapons.List) do
					if wep.WeaponName == weaponChoosed then
						v:Give(wep.WeaponEnt)
						v:GiveAmmo(wep.WeaponAmmoQuantity, wep.WeaponAmmoClass)
					end
				end

				net.Start("MJeu.Action")
					net.WriteString("startGame")
				net.Send(v)

				v.MJeuInGame = true
			end

			-- Unfreeze players at timer ending
			timer.Simple(MJeu.Misc.BeginStart, function()
				for _, v in pairs(player.GetAll()) do
					if v:IsFrozen() and v.MJeuInGame then
						v:Freeze(false)
					end
				end
			end)

			-- Ending game if nobody has died
			timer.Create("MJeuTimerGame", MJeu.Misc.MaxTime+2, 1, function()
				for _, v in pairs(player.GetAll()) do
					if v.MJeuInGame and v:Alive() then
						v:Spawn()

						v:StripWeapons()

						v:SetModel(v.MJeuPreviousStuff.Skin)
						v:SetHealth(v.MJeuPreviousStuff.Health)
						v:SetPos(v.MJeuPreviousStuff.Pos)
						v:SetEyeAngles(v.MJeuPreviousStuff.Ang)
						v:SetArmor(v.MJeuPreviousStuff.Armor)
						v:SetRunSpeed(v.MJeuPreviousStuff.RunSpeed)
						v:SetJumpPower(v.MJeuPreviousStuff.JumpForce)

						for _, swep in pairs(v.MJeuPreviousStuff.Weapons) do
					 		v:Give(swep)
						end

						v.MJeuInGame = false
					end
				end
			end)
		end
	end
end)