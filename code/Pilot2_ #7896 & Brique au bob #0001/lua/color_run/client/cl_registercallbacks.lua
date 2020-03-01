ColorRun:RegisterCallback( ColorRun.ENUMS.InitGame, function()
    local tbl = ColorRun:ReadTable()

    if tbl.mate and IsValid( tbl.mate ) then
        LocalPlayer().mate = tbl.mate
    end
    ColorRun.GamemodesUtils = ColorRun.GamemodesUtils or {}
    ColorRun.GamemodesUtils["gameSettings"] = tbl["gameSettings"]

    ColorRun.CLIENT = ColorRun.CLIENT or {}
    ColorRun.CLIENT.InGame = true
end)

ColorRun:RegisterCallback( ColorRun.ENUMS.StartRound, function()
    local tbl = ColorRun:ReadTable()
    local tblplayers = net.ReadTable()

    ColorRun.GamemodesUtils = ColorRun.GamemodesUtils or {}
    ColorRun.GamemodesUtils["gamemode"] = tbl.gamemode
    ColorRun.GamemodesUtils["currentRound"] = tbl.roundid

    ColorRun.GamemodesUtils["general"] = ColorRun.GamemodesUtils["general"] or {}
    ColorRun.GamemodesUtils["general"]["launched_time"] = CurTime()
    ColorRun.GamemodesUtils["general"]["countdown"] = CurTime()

    ColorRun.GamemodesUtils["players"] = tblplayers
    
    if ColorRun.Gamemodes[ColorRun.GamemodesUtils["gamemode"]]["ClientsideCheck"] then
        ColorRun.Gamemodes[ColorRun.GamemodesUtils["gamemode"]]["ClientsideCheck"]()
    end
end)

ColorRun:RegisterCallback( ColorRun.ENUMS.EndGame, function()
    ColorRun.CLIENT = ColorRun.CLIENT or {}
    ColorRun.CLIENT.InGame = false
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.SendPlatesPos, function()
    local tbl = net.ReadTable()
    
    ColorRun.PlatesPos = tbl
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.SendConquestInfos, function()
    local player1 = net.ReadEntity()
    local color = net.ReadColor()
    local player2 = net.ReadEntity()

    ColorRun.CLIENT = ColorRun.CLIENT or {}

    ColorRun.CLIENT.Conquest = ColorRun.CLIENT.Conquest or {}
    ColorRun.CLIENT.Conquest[player1] = {
        ["color"] = color,
        ["mate"] = player2
    }
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.Debug, function()
    local tbl = net.ReadTable()
    for k,v in pairs(tbl) do
        if istable(v) then
            PrintTable(v)
        else
            print(tostring(v))
        end
    end
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.ColorToGO, function()
    local col = net.ReadColor()

    ColorRun.GamemodesUtils = ColorRun.GamemodesUtils or {}
    ColorRun.GamemodesUtils[1] = ColorRun.GamemodesUtils[1] or {}
    ColorRun.GamemodesUtils[1]["ColorToGo"] = col
end )

ColorRun:RegisterCallback( ColorRun.ENUMS.MusicInteract, function()
    local music_id = net.ReadInt( 6 )

    LocalPlayer():EmitSound( "colorrun_music_" ..music_id )
end )