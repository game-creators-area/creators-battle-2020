local gamestarted = false

ColorRun.Gamemodes[3] = {
    name = "Color Fade",
    time = true,

    timerDelay = 1,
    timerRepeats = 0,
    colorPlayer = true,
    firstCallback = function()
        ColorRun:ColorPlates()
        timer.Simple( 4, function()
            gamestarted = true
        end )         
    end,
    callbackTimer = function()
    end,
    plateTouch = function( self, ply )
        if not gamestarted then return end
        
        if not self:Getishidden() then
            timer.Simple( 0.4, function()
                if not gamestarted then return end
                self:Setishidden( true )
            end )
        else
            ply:Kill()
            if table.Count( ColorRun.game["players"]["alive"] ) <= 1 then
                gamestarted = false
                for k,v in pairs( ColorRun.ZonePos["plates_pos"] ) do
                    v:Setishidden( false )
                end
                
                ColorRun:RoundEnded( 2 )
            end
        end
    end
}