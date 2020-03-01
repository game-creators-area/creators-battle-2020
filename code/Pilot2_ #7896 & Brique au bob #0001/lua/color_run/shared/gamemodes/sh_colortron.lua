ColorRun.Gamemodes[4] = {
    name = "Color Tron",
    time = false,
    mode_time = 50,
    
    timerDelay = 1,
    timerRepeats = 1,
    colorPlayer = true,
    firstCallback = function()
        for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
            v.iswhite = false 
            v:SetColor( Color( 255, 255, 255 ) )
        end
    end,
    callbackTimer = function()
    end,
    plateTouch = function( self, ply )
        if ply:IsFrozen() then return end
        ply:SetVelocity( ply:GetForward() * 40 )
        local eyes = ply:EyeAngles()
        if eyes.x > 60 then
            ply:SetEyeAngles( Angle( 60, eyes.y, eyes.z) )
        elseif eyes.x < -20 then
            ply:SetEyeAngles( Angle( -20, eyes.y, eyes.z) )
        end
        if self:GetColor().r == 255 and self:GetColor().g == 255 and self:GetColor().b == 255 then
            self:SetColor( ply.color )
            timer.Simple( 3, function()
                if ColorRun.game and ColorRun.game["round"] and ColorRun.game["round"]["gamemode"] == 4 then
                    self:SetColor( Color( 255, 255, 255 ) )
                end
            end )
        end
        if self:GetColor().r ~= ply.color.r and self:GetColor().g ~= ply.color.r and self:GetColor().b ~= ply.color.r then
            if table.Count(ColorRun.game["players"]["alive"]) > 1 then
                ply:Freeze( true )
                ply:Kill()
            end
            if table.Count(ColorRun.game["players"]["alive"]) <= 2 and ColorRun.game["settings"].duos then
                local tbl = {}
                for k, v in pairs(ColorRun.game["players"]["alive"]) do
                    tbl[#tbl + 1] = k
                end
                if IsValid( tbl[1].mate ) and tbl[1].mate == tbl[2] then
                    ColorRun:RoundEnded(2)
                end
            elseif table.Count(ColorRun.game["players"]["alive"]) <= 1 then
                ColorRun:RoundEnded(2)
            end
        end
        if table.Count(ColorRun.game["players"]["alive"]) <= 1 then
                ColorRun:RoundEnded(2)
        end
    end
}