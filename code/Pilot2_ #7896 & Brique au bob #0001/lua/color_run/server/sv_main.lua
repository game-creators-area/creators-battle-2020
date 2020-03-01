local waiting_invite = {}

local teams = {
    ["owners"] = {},
    ["members"] = {}
}

ColorRun.queue = {}
ColorRun.game = ColorRun.game or {}

local function InvertTable( tbl )
    local invert = {}
    if table.IsEmpty(tbl) then
        return nil
    end
    for k, v in pairs( tbl ) do
        invert[v] = k
    end
    return invert
end

function ColorRun:GetPlayerTeam( steamid64 )
    if not teams["members"][steamid64] then return {} end

    local team_table = table.Copy( teams )
    local team = {}
    local team_id = team_table["members"][steamid64]
    local owner_id = team_table["owners"][team_id]

    team[steamid64] = owner_id == steamid64 and "owner" or "member"
    
    team_table["members"][steamid64] = nil
    
    local invert = InvertTable( team_table["members"] )
    if not invert then return end
    team[invert[team_id]] = owner_id == invert[team_id] and "owner" or "member"
    
    return team
end

ColorRun:RegisterCallback( ColorRun.ENUMS.InviteTeam, function( ply )
    local entity = net.ReadEntity()
    if entity == ply then return end
    if waiting_invite[ply:SteamID64()] then ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "already_invited" ):format(entity:Nick()), 0, 5 ) return end
    if ply.NextInviteColorRunTeam and ply.NextInviteColorRunTeam >= CurTime() then return end

    ColorRun:NotifyPlayer( entity, ( ColorRun:GetTranslation( "invited_by" ) ):format( ply:Name() ), 1 )
    ColorRun:NotifyPlayer( ply, ( ColorRun:GetTranslation( "invited_who" ) ):format( entity:Name() ), 2, 10 )

    waiting_invite[ply:SteamID64()] = entity:SteamID64()
    ply.NextInviteColorRunTeam = CurTime() + 10
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CancelInvite, function( ply )
    if not waiting_invite[ply:SteamID64()] then return end

    local player = player.GetBySteamID64( waiting_invite[ply:SteamID64()] )
    waiting_invite[ply:SteamID64()] = nil
    
    if IsValid( player ) and player:IsPlayer() then
        ColorRun:NotifyPlayer( player, ( ColorRun:GetTranslation( "canceled_by" ) ):format( ply:Name() ), 0, 10 )
    end
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.AcceptInvite, function( ply )
    if not table.HasValue( waiting_invite, ply:SteamID64() ) then return end
    local invert = InvertTable( waiting_invite ) -- Reverse the invite to get the "host" steamid
    if not invert[ply:SteamID64()] then return end
    
    local team_id = #teams["owners"] + 1
    teams["owners"][team_id] = invert[ply:SteamID64()]  -- Set the "owner" as owner
    teams["members"][ply:SteamID64()] = team_id         -- Set the "guest" as member
    teams["members"][invert[ply:SteamID64()]] = team_id  -- Set the "owner" as member
    
    waiting_invite[invert[ply:SteamID64()]] = nil
    
    ColorRun:NotifyPlayer( player.GetBySteamID64( teams["owners"][team_id] ), ( ColorRun:GetTranslation( "member_join" ) ):format( ply:Name() ), 0, 5 )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.KickMember, function( ply )
    local type = net.ReadInt(3)

    local team_id = teams["members"][ply:SteamID64()]
    local owner_id = teams["owners"][team_id]
    
    teams["members"][ply:SteamID64()] = nil
    local invert = InvertTable( teams["members"] )
    local victim = invert[team_id]

    teams["members"][victim] = nil
    teams["owners"][team_id] = nil

    local player = player.GetBySteamID64( victim )
    ColorRun:NotifyPlayer( ply, type == 1 and ColorRun:GetTranslation( "you_has_kick" ):format( player:Name() ) or ColorRun:GetTranslation( "you_left_team" ), 0, 5 )
    ColorRun:NotifyPlayer( player, type == 1 and ColorRun:GetTranslation( "you_get_kick" ):format( ply:Name() ) or ColorRun:GetTranslation( "left_team" ):format( ply:Name() ), 0, 5 )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.JoinQueue, function( ply )
    local read = net.ReadInt( 3 )
    ColorRun:RefreshQueue( ply, read )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CreateGame, function( ply )
    local receivedGameOptions = ColorRun:ReadTable()

    if IsValid(ColorRun.queue["owner"]) then
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "alreadyqueuec" ), 0, 3 )
        return
    end 
    if receivedGameOptions.players_max > ColorRun.Config.maxPlayers then
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "maxplayersreached" ):format( ColorRun.Config.maxPlayers ), 0, 3 )
        return
    end
    if receivedGameOptions.round_amount > ColorRun.Config.maxRounds then
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "maxroundsreached" ):format( ColorRun.Config.maxRounds ), 0, 3 )
        return
    end

    ColorRun.queue = {
        ["owner"] = ply,
        ["settings"] = {
            ["gamemodes"] = {
                [1] = receivedGameOptions["gamemodes"][1] == 1 and true or false,
                [2] = receivedGameOptions["gamemodes"][2] == 1 and true or false,
                [3] = receivedGameOptions["gamemodes"][3] == 1 and true or false,
                [4] = receivedGameOptions["gamemodes"][4] == 1 and true or false,
            },
            ["players_max"] = math.abs(receivedGameOptions.players_max) or ColorRun.Config.maxPlayers,
            ["round_amount"] = math.abs(receivedGameOptions.round_amount) or ColorRun.Config.maxRounds,
            ["bonuses"] = receivedGameOptions.bonuses == 1 and true or false,
            ["duos"] = receivedGameOptions.duos == 1 and true or false,
        },
        ["players"] = {}
    }

    ColorRun:RefreshQueue( ply, 1, true )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CreateZone, function( ply )
    if not ply:IsSuperAdmin() then return end

    local vector1 = net.ReadVector()
    local vector2 = net.ReadVector()

    ColorRun:GenerateNewFloor( vector1 + Vector( 0, 0, 100 ), vector2 + Vector( 0, 0, 100 ) )
    
    if not file.IsDir( "color_run/maps", "DATA" ) then
        file.CreateDir( "color_run/maps" )
    end
    local tbl = {}
    if file.Exists( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) then
        tbl = util.JSONToTable( file.Read( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) )
    else
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "admin_tool_create_npc" ), 0, 5 )
    end
    tbl["zone"] = {}
    tbl["zone"]["start"] = vector1
    tbl["zone"]["end"] = vector2
    file.Write( "color_run/maps/" ..game.GetMap() ..".json", util.TableToJSON( tbl ) )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CreateNPC, function( ply )
    local ang = net.ReadInt( 10 )
    if not ply:IsSuperAdmin() then return end

    local vec = ply:GetEyeTrace().HitPos

    local ent = ents.Create( "npc_colorrun" )
    ent:SetPos( vec )
    ent:SetAngles( Angle( 0, ang, 0 ) )
    ent:Spawn()

    if not file.IsDir( "color_run/maps", "DATA" ) then
        file.CreateDir( "color_run/maps" )
    end
    local tbl = {}
    if file.Exists( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) then
        tbl = util.JSONToTable( file.Read( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) )
    else
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "admin_tool_create_zone" ), 0, 5 )
    end
    tbl["npc"] = {}
    tbl["npc"]["position"] = vec
    tbl["npc"]["angle"] = Angle( 0, ang, 0 )
    file.Write( "color_run/maps/" ..game.GetMap() ..".json", util.TableToJSON( tbl ) )
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.CreateTPZone, function( ply )
    if not ply:IsSuperAdmin() then return end

    local vector1 = net.ReadVector()
    local vector2 = net.ReadVector()

    if ColorRun.ZonePos then
        ColorRun.ZonePos["tppos"] = {}
        ColorRun.ZonePos["tppos"]["start"] = vector1
        ColorRun.ZonePos["tppos"]["end"] = vector2
    else
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "admin_tool_need_create_zone" ), 0, 5 )
    end
    
    if not file.IsDir( "color_run/maps", "DATA" ) then
        file.CreateDir( "color_run/maps" )
    end
    local tbl = {}
    if file.Exists( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) then
        tbl = util.JSONToTable( file.Read( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) )
    else
        ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "admin_tool_create_npc" ), 0, 5 )
    end
    tbl["tpzone"] = {}
    tbl["tpzone"]["start"] = vector1
    tbl["tpzone"]["end"] = vector2
    file.Write( "color_run/maps/" ..game.GetMap() ..".json", util.TableToJSON( tbl ) )
end )

hook.Add( "PlayerDisconnected", "ColorRun:Hooks:PlayerDisconnected:QuitTeam", function( ply )
    if waiting_invite[ply:SteamID64()] then table.remove( waiting_invite, ply:SteamID64() ) end
    if teams["members"][ply:SteamID64()] then
        local team_id = teams["members"][ply:SteamID64()]
        teams["members"][ply:SteamID64()] = nil
        teams["owners"][team_id] = nil
        local invert = InvertTable( teams["members"] )
        local playersteamid = invert[team_id]
        teams["members"][playersteamid] = nil
        local player = player.GetBySteamID64( playersteamid )
        if IsValid( player ) and player:IsPlayer() then
            ColorRun:NotifyPlayer( player, ( ColorRun:GetTranslation( "member_disconnect" ) ):format( ply:Name() ), 0, 5 )
        end
    end    
end )

concommand.Remove("kill")
concommand.Add("kill", function(ply)
    if ply.ingame then return end
    ply:Kill()
end)