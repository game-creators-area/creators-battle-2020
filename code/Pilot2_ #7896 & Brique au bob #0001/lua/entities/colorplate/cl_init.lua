include( "shared.lua" )

function ENT:Draw()
	self:DrawShadow( false )
	self:DestroyShadow()
	if not self:Getishidden() then
		self:DrawModel()
	end
end
