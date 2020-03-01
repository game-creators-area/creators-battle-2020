MJeu = MJeu or {}


--[[ Skins ]]
MJeu.Skins = {}
MJeu.Skins.ChangeSkin = true -- TRUE: Player will change theirs skins,  FALSE: They will be defined by a skin below
MJeu.Skins.List = {
	["models/player/alyx.mdl"] = true,
	["models/player/eli.mdl"] = true,
	["models/player/kleiner.mdl"] = true,
	["models/player/monk.mdl"] = true,
	["models/player/mossman_arctic.mdl"] = true,
	["models/player/police_fem.mdl"] = true,
	["models/player/combine_soldier.mdl"] = true,
	["models/player/charple.mdl"] = true,
	["models/player/soldier_stripped.mdl"] = true,
	["models/player/zombie_classic.mdl"] = true,
	["models/player/Group01/female_06.mdl"] = true,
}


--[[ Weapons ]]
MJeu.Weapons = {}
MJeu.Weapons.MasterDecide = true -- TRUE: Master will choose weapons from below,   FALSE: Random weapons
MJeu.Weapons.List = { -- WeaponName MUST BE UNIQUE !
	{
		["WeaponName"] = ".357 Magnum", 
		["WeaponEnt"] = "weapon_357",
		["WeaponAmmoClass"] = "357",
		["WeaponAmmoQuantity"] = 50
	},
	{
		["WeaponName"] = "Shotgun", 
		["WeaponEnt"] = "weapon_shotgun",
		["WeaponAmmoClass"] = "Buckshot",
		["WeaponAmmoQuantity"] = 30
	},
	{
		["WeaponName"] = "SMG", 
		["WeaponEnt"] = "weapon_smg1",
		["WeaponAmmoClass"] = "SMG1",
		["WeaponAmmoQuantity"] = 180
	},
	{
		["WeaponName"] = "Crossbow", 
		["WeaponEnt"] = "weapon_crossbow",
		["WeaponAmmoClass"] = "XBowBolt",
		["WeaponAmmoQuantity"] = 10
	},
}


--[[ Armor ]]
MJeu.Armor = {}
MJeu.Armor.MinArmor = 0 -- Minimum value for the armor
MJeu.Armor.MaxArmor = 255 -- Maximum value for the armor (MAX 255 due to gmod limitation)


--[[ Health ]]
MJeu.Health = {}
MJeu.Health.MinHealth = 0 -- Minimum health for players
MJeu.Health.MaxHealth = 400 -- Maximum health for players


--[[ Teleportation ]]
MJeu.Teleportation = {
	{
		["Pos"] = Vector(1414.103516, 6045.661133, 32.366211),
		["Ang"] = Angle(0, -90, 0 )
	},
	{
		["Pos"] = Vector(1329.910156, 2267.940674, 32.031250),
		["Ang"] = Angle(0, 90, 0)
	}
	-- DO NOT ADD ANYTHING HERE !!!
}


--[[ Miscellaneous ]]
MJeu.Misc = {}
MJeu.Misc.CommandInvite = "!invite" -- Command to invite someone format: "!invite <pseudo | steamid | steamid64>"
MJeu.Misc.CommandMenu = "!game" -- Command to open configuration panel and start game (you must have someone in your group)
MJeu.Misc.CommandLeave = "!leave" -- Command to open configuration panel (you must have someone in your group)

MJeu.Misc.MinRunSpeed = 100 -- Minimum run speed (minimum 7 or player won't be able to move)
MJeu.Misc.MaxRunSpeed = 400 -- Maximum run speed
MJeu.Misc.MinJumpForce = 30 -- Minimum jump force
MJeu.Misc.MaxJumpForce = 800 -- Maximum jump force
MJeu.Misc.BeginStart = 3 -- Seconds before starting
MJeu.Misc.MaxTime = 10 -- Maximum time for the game (in seconds)

MJeu.Misc.FallDamage = false -- TRUE: Fall damage activated,   FALSE: Fall damage desactivated