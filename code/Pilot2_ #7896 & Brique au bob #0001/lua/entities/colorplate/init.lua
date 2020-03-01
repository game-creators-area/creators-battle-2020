AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube075x075x025.mdl" )
	self:SetMaterial("models/debug/debugwhite")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )  
	self:SetModelScale( self:GetModelScale() * 1.014, 1 )
	local phys = self:GetPhysicsObject()
	phys:EnableMotion( false ) 
end

function ENT:CanProperty()
 	return false
end

function ENT:SetToWhite( )
	local c = ColorRun.game["round"].currentcolor
	if self:GetColor().r == c.r and self:GetColor().g == c.g and self:GetColor().b == c.b then
		ColorRun.game["valid_plates"][#ColorRun.game["valid_plates"] + 1] = self
		return
	end
	self:SetColor( Color( 255, 255, 255 ) )
	self.iswhite = true	
end

function ENT:Touch( ent )
	if IsValid( ent ) and ent:GetClass() ~= "colorplate" and not ent:IsPlayer() then ent:Remove() end
	if ent:IsPlayer() and not ColorRun.game or not ColorRun.game["players"] or not ColorRun.game["players"]["alive"] or not ColorRun.game["players"]["alive"][ent] or table.IsEmpty( ColorRun.game ) or not ColorRun.game["round"] or table.IsEmpty( ColorRun.game["round"] ) or not isnumber( ColorRun.game["round"]["gamemode"] ) then
		if not ColorRun.ZonePos or not ColorRun.ZonePos["tppos"] or not ColorRun.ZonePos["tppos"]["start"] or not ColorRun.ZonePos["tppos"]["end"] then return end

		local x1, y1, z1 = ColorRun.ZonePos["tppos"]["start"]:Unpack()
		local x2, y2, z2 = ColorRun.ZonePos["tppos"]["end"]:Unpack()
		local rand = Vector( math.random( x1, x2 ), math.random( y1, y2 ), math.random( z1, z2 ) )

		while not rand:WithinAABox( ColorRun.ZonePos["tppos"]["start"], ColorRun.ZonePos["tppos"]["end"] ) do
			rand = Vector( math.random( x1, x2 ), math.random( y1, y2 ), Vector( 0, 0, 10 ) )
		end
		
		ent:SetPos( rand )
		return
	end
	if ent:IsPlayer() then
		ent.lastpos = self:GetPos() + Vector(0,0,10)
	end
	local tbl = ColorRun.Gamemodes
	if not ColorRun.game or not ColorRun.game["round"] or not ColorRun.game["round"]["gamemode"] or ColorRun.game["round"]["gamemode"] == 0 or not isfunction( tbl[ColorRun.game["round"]["gamemode"]].plateTouch ) then return end
	
	tbl[ColorRun.game["round"]["gamemode"]].plateTouch( self, ent )
end

hook.Add("CanTool", "ColorRun:Hooks:CanTool", function ( ply, tr, tool )
	if IsValid( tr.Entity ) and tr.Entity:GetClass() == "colorplate" then
		return false
	end
end)

hook.Add( "PhysgunPickup", "ColorRun:Hooks:PhysgunPickup", function( ply, ent )
	if ent:GetClass() ~= "colorplate" and ent:GetClass() ~= "colorrun_speaker" then return end
	return false
end )