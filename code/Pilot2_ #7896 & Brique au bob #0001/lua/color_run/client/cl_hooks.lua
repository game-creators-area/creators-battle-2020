print("dc") --

hook.Add( "PlayerFootstep", "ColorRun:Hooks:PlayerFootstep", function ( ply ) 
	if IsValid(ply) and ColorRun and ColorRun.CLIENT and ColorRun.CLIENT.InGame then
      return true
   end
end )
