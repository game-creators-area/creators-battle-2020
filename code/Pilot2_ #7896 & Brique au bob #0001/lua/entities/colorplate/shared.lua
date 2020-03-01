DEFINE_BASECLASS("base_entity")
ENT.Type 			= "anim"

ENT.PrintName		= "colorplate"
ENT.Author			= "Pilot2"
ENT.Category		= "Color Run"

ENT.Spawnable 		= false
ENT.AdminOnly 		= false

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "ishidden" )

end