TOOL.AddToMenu = true

TOOL.Category = "AM Minigame System"
TOOL.Name = "#tool.tamponneuse_stool.name"

if ( CLIENT ) then
	language.Add( "tool.tamponneuse_stool.name", "Spawn d'Auto-tamponneuses" )
	language.Add( "tool.tamponneuse_stool.desc", "Clic gauche pour faire apparaitre une auto-tamponneuse" )
	language.Add( "tool.tamponneuse_stool.2", "" )
end


function TOOL:LeftClick( trace )
	if (CLIENT) then return true end
	if self:GetOwner():IsAdmin() then
		local tamponneuse = ents.Create( "ctv_tf2_bumper_car_blu" )
		if ( !IsValid( tamponneuse ) ) then return end
		tamponneuse:SetPos( trace.HitPos )
		tamponneuse:Spawn()
	else
		DarkRP.notify( self:GetOwner(), 0, 1.5, "Vous n'avez pas l'autorisation d'utiliser ceci." )
	end
end