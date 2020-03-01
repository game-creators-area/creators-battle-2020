ColorRun.Gamemodes[1] = { -- Color Shuffle
    name = "Color Shuffle",
    time = true,
    resettime = true,
    mode_time = 6,

    CustomHud = function( w, h )
        surface.SetDrawColor( Color( 52, 52, 52 ) )
        ColorRun:DrawCircle( w / 2, h - 10, 90 )
        surface.SetDrawColor( ColorRun.GamemodesUtils and ColorRun.GamemodesUtils[1] and ColorRun.GamemodesUtils[1]["ColorToGo"] or Color( 255, 0, 255 ) )
        ColorRun:DrawCircle( w / 2, h - 10, 80 )
        draw.SimpleText( "GO", "ColorRun:54", w / 2, h - 35, Color( 255, 255, 255 ), 1, 1 )
    end,
    timerDelay = 6,
    timerRepeats = 0,
    colorPlayer = false,
    firstCallback = function()
        ColorRun.game["round"].count = 1
        ColorRun:ColorPlates()
    end,
    callbackTimer = function()
        if not ColorRun.game["players"] then timer.Remove( "ColorRun:timers:Round" ) return end

        for k, v in pairs( ColorRun.game["players"]["alive"] ) do
            k:Freeze( true )
            k.detected = false
        end

        for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
            v:SetToWhite() -- Changes plates color which aren't the good color to black 
        end

        local c = ColorRun.game["round"].currentcolor            
        for x, y in pairs( ColorRun.game["players"]["alive"] ) do
            for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
            if v:GetColor().r == c.r and v:GetColor().g == c.g and v:GetColor().b == c.b and x:GetPos():DistToSqr( v:GetPos() ) <= 650 then 
                    x.detected = true
                    break
                end
            end
        end

        for x, y in pairs( ColorRun.game["players"]["alive"] ) do
            if not x.detected then
                if table.Count( ColorRun.game["players"]["alive"] ) == 3 then
                    ColorRun:RoundEnded( 2 )
                elseif table.Count( ColorRun.game["players"]["alive"] ) == 2 then
                    ColorRun:RoundEnded( 3 )
                end
                x:Kill()
                ColorRun.game["players"]["alive"][x] = nil
            end
        end
        if table.Count( ColorRun.game["players"]["alive"] ) <= 1 then
            ColorRun:RoundEnded( 4 )
        else
            timer.Simple( 1, function()
                for k,v in pairs( ColorRun.game["players"]["alive"] ) do
                    k:Freeze( false )
                end
                if table.Count( ColorRun.game["players"]["alive"] ) <= 1 then -- This prevent a bug where the player dies once the timer is ended
                    ColorRun:RoundEnded( 4 )
                else
                    ColorRun:ColorPlates()
                end
            end )
        end
    end,
    plateTouch = function( self, ply )
    end
}
