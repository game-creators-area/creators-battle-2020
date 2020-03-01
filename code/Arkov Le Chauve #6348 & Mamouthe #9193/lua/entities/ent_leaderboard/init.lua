AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/hunter/plates/plate2x3.mdl" )
	self:SetColor( color_black )
	self:SetMaterial( "models/shiny" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:SetModelScale( 1 )
	self:SetMaterial( "models/shiny" )
	self:SetColor( color_black )
	self:DropToFloor()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end  