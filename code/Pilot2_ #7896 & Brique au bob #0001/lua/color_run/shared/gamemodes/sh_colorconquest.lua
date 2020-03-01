ColorRun.Gamemodes[2] = {
    name = "Color Conquest",
    time = true,
    mode_time = 50,

    CustomHud = function( w, h )
        if not ColorRun.CLIENT or not ColorRun.CLIENT.ConquestWinners then return end

        if #ColorRun.CLIENT.ConquestWinners == 2 then
            draw.RoundedBox( 8, w - 335, 10, 325, 210, Color( 52, 52, 52 ) )
        else
            draw.RoundedBox( 8, w - 335, 10, 325, 280, Color( 52, 52, 52 ) )
        end
        draw.SimpleText( "TOP 3", "ColorRun:32", w - 167.5, 46, Color( 255, 255, 255 ), 1, 1 )
        
        if ColorRun.CLIENT.ConquestWinners then
            for k, v in ipairs( ColorRun.CLIENT.ConquestWinners ) do
                draw.RoundedBox( 8, w - 325, 80 + ( k - 1 ) * 70, 305, 60, Color( 62, 62, 62 ) )
                surface.SetDrawColor( v.player1.color )
                ColorRun:DrawCircle( w - 300, 80 + ( k - 1 ) * 70 + 30, 10 )

                if not IsValid(v.player2) then
                    draw.SimpleText( IsValid( v.player1 ) and v.player1:Name() or "disconnected", "ColorRun:32", w - 275,  ( 80 + ( k - 1 ) * 70 + 30 ), Color( 255, 255, 255 ), 0, 1 )
                else
                    draw.SimpleText( v.player1:Name(), "ColorRun:24", w - 275,  ( 80 + ( k - 1 ) * 70 + 20 ), Color( 255, 255, 255 ), 0, 1 )
                    draw.SimpleText( v.player2:Name() or "", "ColorRun:24", w - 275, ( 80 + ( k - 1 ) * 70 + 43 ), Color( 255, 255, 255 ), 0, 1 )
                end
                
                draw.SimpleText( v["percentage"]  .. "%", "ColorRun:32", w - 35, 80 + ( k - 1 ) * 70 +  30, Color( 255, 255, 255 ), 2, 1 )
            end
        end
    end,
    ClientsideCheck = function()
        timer.Create( "ColorRun:ConquestGamemode:Launch", 2, 0, function()
            local ColorsPercentage = {}

            for k, v in pairs( ColorRun.PlatesPos ) do
                local col = v:GetColor()
                ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] = ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] and ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] + 1 or 1
            end

            local top = {}
            for k, v in pairs( ColorRun.GamemodesUtils["players"] ) do
                local col = ColorRun.CLIENT.Conquest[k].color
                k.color = col

                top[#top + 1] = {
                    player1 = k,
                    player2 = ColorRun.CLIENT.Conquest[k].mate,
                    percentage = math.Round( ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] *  100 / #ColorRun.PlatesPos, 0 )
                }
            end

            table.sort( top, function( a, b )
                return a["percentage"] > b["percentage"]
            end )

            ColorRun.CLIENT.ConquestWinners = {}
            ColorRun.CLIENT.ConquestWinners = {
                [1] = top[1],
                [2] = top[2],
                [3] = top[3],
            }
        end )
    end,
    
    timerDelay = ColorRun.Config.colorConquestTime,
    timerRepeats = 1,
    colorPlayer = true,
    firstCallback = function()
        for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
            v:SetColor( Color( 255, 255, 255 ) )
        end

        for k, v in pairs( ColorRun.game["players"]["all"] ) do
            ColorRun:SendNet( ColorRun.ENUMS.SendConquestInfos, function() 
                net.WriteEntity( k ) 
                net.WriteColor( k.color ) 
                if k.mate then 
                    net.WriteEntity( k.mate ) 
                end
            end, player.GetAll() )
        end

        timer.Simple( ColorRun.Config.colorConquestTime, function()
            if not ColorRun.game or not ColorRun.game["round"] or not ColorRun.game["round"]["gamemode"] == 2 then return end

            local ColorsPercentage = {}

            for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
                local col = v:GetColor()
                ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] = ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] and ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] + 1 or 1
            end

            local top = {}
            for k, v in pairs( ColorRun.game["players"]["all"] ) do
                local col = k.color

                top[#top + 1] = {
                    player1 = k,
                    player2 = k.mate,
                    percentage = math.Round( ColorsPercentage[col.r .."-" ..col.g .."-" ..col.b] *  100 / #ColorRun.ZonePos["plates_pos"], 0 )
                }
            end

            table.sort( top, function( a, b )
                return a["percentage"] > b["percentage"]
            end )

            local winner = top[1]
            
            if IsValid( winner["player1"] ) and winner["player1"]:IsPlayer() and ColorRun.game["players"]["all"][winner["player1"]] then
                ColorRun:addPoints( winner["player1"], 2 )
            end
            if IsValid( winner["player2"] ) and winner["player2"]:IsPlayer() and ColorRun.game["players"]["all"][winner["player1"]] then
                ColorRun:addPoints( winner["player2"], 2 )
            end

            ColorRun:RoundEnded( 0 )
        end )
    end,
    callbackTimer = function()
    end,
    plateTouch = function( self, ply )
        self:SetColor( ply.color )
    end
}
