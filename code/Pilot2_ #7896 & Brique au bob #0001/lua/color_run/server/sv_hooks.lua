local function GenerateZone()
    if not file.Exists( "color_run/maps/" ..game.GetMap() ..".json", "DATA" ) then return end

    local json = file.Read( "color_run/maps/" ..game.GetMap() ..".json", "DATA" )
    local unjson = util.JSONToTable( json )

    if unjson["zone"] and unjson["zone"]["start"] and unjson["zone"]["end"] then
        ColorRun:GenerateNewFloor( unjson["zone"]["start"] + Vector( 0, 0, 100 ), unjson["zone"]["end"] + Vector( 0, 0, 100 ) )
    end
    if unjson["npc"] and unjson["npc"]["position"] and unjson["npc"]["angle"] then
        local ent = ents.Create( "npc_colorrun" )
        ent:SetPos( unjson["npc"]["position"] )
        ent:SetAngles( unjson["npc"]["angle"] )
        ent:Spawn()
    end
    return unjson
end

hook.Add( "InitPostEntity", "ColorRun:Hooks:InitPostEntity:LoadColorRunZone", function() 
    local unjson = GenerateZone()
    
    if not unjson or not unjson["tpzone"] or not unjson["tpzone"]["start"] or not unjson["tpzone"]["end"] then return end
    ColorRun.ZonePos = ColorRun.ZonePos or {}
    ColorRun.ZonePos["tppos"] = {}
    ColorRun.ZonePos["tppos"]["start"] = unjson["tpzone"]["start"]
    ColorRun.ZonePos["tppos"]["end"] = unjson["tpzone"]["end"]
end )

hook.Add( "PostCleanupMap", "ColorRun:Hooks:PostCleanUpMap:LoadColorRunZone", GenerateZone )

hook.Add( "PlayerDisconnected", "ColorRun:Hooks:PlayerDisconnected:RefreshQueue", function( ply )
    if ply.queue then
        ColorRun:RefreshQueue(ply, 2)
    end
end )

hook.Add("PlayerSpawn", "ColorRun:Hooks:PlayerSpawn", function(p)
    if not p.ingame then return end
    if not IsValid( ColorRun.game["owner"] ) then return end

    if not ColorRun.game["players"]["alive"][p] then
        ColorRun.game["players"]["died"][p] = nil
        ColorRun.game["players"]["alive"][p] = true
    end
end)

hook.Add( "Move", "ColorRun:Hooks:Move", function(p, mv)
    if not ColorRun.game or not ColorRun.game["players"] or not ColorRun.game["players"]["alive"] or not ColorRun.game["players"]["alive"][p] then return end
    if not p.ingame then return end
    if not ColorRun.ZonePos["vector1"] or not ColorRun.ZonePos["vector2"] then return end

    if not p:GetPos():WithinAABox(ColorRun.ZonePos["vector1"] , ColorRun.ZonePos["vector2"] - Vector(0,0, 1500)) then
        mv:SetOrigin( p.lastpos )
    end
end )

hook.Add( "PlayerInitialSpawn", "ColorRun:Hooks:PlayerInitialSpawn:SendPlatePos", function( ply )
    timer.Simple( 5, function()
        if ColorRun.ZonePos and ColorRun.ZonePos["plates_pos"] then
            ColorRun:SendNet( ColorRun.ENUMS.SendPlatesPos, function()
                net.WriteTable( ColorRun.ZonePos["plates_pos"] )
            end, ply )
        end
    end )
end )

local function randomAlivePlayers()
    local rand = math.random( 1, #ColorRun.game["players"]["alive"] )
    local tbl = {}
    for k, v in pairs( ColorRun.game["players"]["alive"] ) do
        tbl[#tbl + 1] = k
    end
    return tbl[rand]
end

local spectating = {}
hook.Add( "PlayerDeath", "ColorRun:Hooks:PlayerDeath:SpectacteMode", function( ply )
    if not ColorRun.game or not ColorRun.game["players"] then return end
    if not ColorRun.game["players"]["all"] or not ColorRun.game["players"]["all"][ply] then return end
    if not ply.ingame then return end

    ColorRun.game["players"]["alive"][ply] = nil
    ColorRun.game["players"]["died"][ply] = true

end )