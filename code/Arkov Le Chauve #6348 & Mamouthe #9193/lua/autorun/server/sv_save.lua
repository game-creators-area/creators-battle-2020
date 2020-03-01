hook.Add( "ShutDown", "SavePosAndScore", function()
  
/*
    Sauvegarde de la position du npc guichetier
*/

    if #ents.FindByClass( "ent_guichetier" ) == 1 then
        for k, v in pairs( ents.FindByClass( "ent_guichetier" ) ) do
            Pos = v:GetPos()
            Angle = v:GetAngles()
            GetPositions = { [1] = { Pos, Angle } }
            GetPositions[2] = nil
        end
        file.CreateDir("am-minigame")
        file.Write( "am-minigame/pos.txt", util.TableToJSON( GetPositions ) ) 
    end

/*
    Sauvegarde des scores pour le leaderboard
*/
    scoredatatable = {}

    for k, v in pairs( player.GetAll() ) do
        scoredatatable[k] = { ent = v, score = v:GetNWInt( "score" ) }
    end

    file.Write( "am-minigame/score.txt", util.TableToJSON( scoredatatable ) )

end )

/*
    Positionnement du npc après un cleanup et après un reboot
*/

hook.Add( "Initialize", "LoadDataWhenStart", function()
    timer.Simple( 6, function()
        if file.Exists( "am-minigame/pos.txt", "DATA" ) then
            GetPositions = util.JSONToTable( file.Read( "am-minigame/pos.txt", "DATA" ) )
            local npc = ents.Create( "ent_guichetier" )
            if ( !IsValid( npc ) ) then return end
            npc:SetModel( "models/gman_high.mdl" )
            npc:SetPos( Vector( GetPositions[1][1] ) )
            npc:SetAngles( Angle( GetPositions[1][2] ) )
            npc:SetHullType( HULL_HUMAN )
            npc:SetHullSizeNormal()
            npc:SetNPCState( NPC_STATE_SCRIPT )
            npc:SetSolid( SOLID_BBOX )
            npc:SetUseType( SIMPLE_USE )
            npc:Spawn()
        end
    end )
end )

hook.Add( "PostCleanupMap", "LoadDataWhenCleanup", function()
    if file.Exists( "am-minigame/pos.txt", "DATA" ) then
        GetPositions = util.JSONToTable( file.Read( "am-minigame/pos.txt", "DATA" ) )
        local npc = ents.Create( "ent_guichetier" )
        if ( !IsValid( npc ) ) then return end
        npc:SetModel( "models/gman_high.mdl" )
        npc:SetPos( GetPositions[1].Pos )
        npc:SetAngle( GetPositions[1].Angle )
        npc:Spawn()
    end
end )

/*
    Chargement du score pour les joueurs
*/

hook.Add( "PlayerInitialSpawn", "LoadScore", function( ply )
    if file.Exists( "am-minigame/score.txt", "DATA" ) then
        scoredatatable = util.JSONToTable( file.Read( "am-minigame/score.txt", "DATA" ) )
        for k, v in pairs( scoredatatable ) do
            if v.ent == ply then
                ply:SetNWInt( "score", v.score )
                break
            end
        end
    else
        ply:SetNWInt( "score", 0 )
    end
end )

/*
    Sauvegarde du score quand le joueur se déconnecte
*/

hook.Add( "PlayerDisconnected", "SaveScoreWhenDisconnect", function( ply )
    if file.Exists( "am-minigame/score.txt", "DATA" ) then
        scoredatatable = util.JSONToTable( file.Read( "am-minigame/score.txt", "DATA" ) )
        for k, v in pairs( scoredatatable ) do
            if v.ent == ply then
                scoredatatable[k] = { ent = v, score = v:GetNWInt( "score" ) }
                break
            end
        end
    else
        scoredatatable = {}
        scoredatatable[1] = { ent = ply, score = ply:GetNWInt( "score" ) }
    end

    file.Write( "am-minigame/score.txt", util.TableToJSON( scoredatatable ) )
end )