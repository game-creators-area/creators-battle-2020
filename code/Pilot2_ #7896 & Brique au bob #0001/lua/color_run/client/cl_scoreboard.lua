local draw = draw
local surface = surface

local logo = Material( "color_run/logo.png" )

ColorRun:RegisterCallback( ColorRun.ENUMS.EndRound, function()
    local tbl = net.ReadTable()
    local last = net.ReadBool()
    local music_id = net.ReadInt( 6 )
    
    local time = last and 0 or CurTime() + 5

    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScrW() / 1.5, ScrH() / 1.5 )
    frame:Center()
    frame:DockPadding( 0, 0, 0, 0 )
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:MakePopup()
    function frame:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, Color( 52, 52, 52 ) )
    end

    local top = vgui.Create( "DPanel", frame )
    top:Dock( TOP )
    top:SetTall( 84 )
    function top:Paint( w, h )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.SetMaterial( logo )
        surface.DrawTexturedRect( 5, 5, 182, 74 )

        draw.SimpleText( "CLASSEMENT", "ColorRun:32", w - 10, h / 2, Color( 255, 255, 255 ), 2, 1 )
    end

    local bottom = vgui.Create( "DPanel", frame )
    bottom:Dock( BOTTOM )
    bottom:DockPadding( 15, 15, 15, 15 )
    bottom:SetTall( 65 )
    function bottom:Paint() end

    local nextround = vgui.Create( "DPanel", bottom )
    nextround:Dock( LEFT )
    nextround:SetWide( frame:GetWide() / 1.5 )
    function nextround:Paint( w, h )
        draw.SimpleText( last and ColorRun:GetTranslation( "game_end_scoreboard" ) or ColorRun:GetTranslation( "round_end_scoreboard" ):format( math.Round( time - CurTime() ) ), "ColorRun:32", 10, h / 2, Color( 255, 255, 255 ), 0, 1 )
    end
    function nextround:Think()
        if last then return end
        if time - CurTime() <= 0 then
            frame:Close()
            LocalPlayer():StopSound( "colorrun_music_" ..music_id )
        end
    end

    local close = vgui.Create( "DButton", bottom )
    close:Dock( RIGHT )
    close:SetWide( frame:GetWide() / 2.5 )
    close:SetText( "" )
    function close:Paint( w, h )
        draw.SimpleText( last and ColorRun:GetTranslation( "close_menu" ) or ColorRun:GetTranslation( "quit_game" ), "ColorRun:32", w - 10, h / 2, self:IsHovered() and Color( 249, 107, 107 ) or Color( 239, 97, 97 ), 2, 1 )
    end
    function close:DoClick()
        frame:Close()
        LocalPlayer():StopSound( "colorrun_music_" ..music_id )

        if last then return end
        ColorRun:SendNet( ColorRun.ENUMS.QuitGame )
    end


    local scroll = vgui.Create( "DScrollPanel", frame )
    scroll:Dock( FILL )
    scroll:DockMargin( 10, 10, 10, 10 )

    local generate = {}
    for k, v in pairs( tbl ) do
        generate[#generate + 1] = {
            k,
            v
        }
    end

    table.sort( generate, function( a, b )
        return a[2] > b[2]
    end )

    for k, v in pairs( generate ) do
        local panel = vgui.Create( "DPanel", scroll )
        panel:Dock( TOP )
        panel:DockMargin( 0, 10, 0, 0 )
        panel:SetTall( 75 )
        function panel:Paint( w, h )
            draw.RoundedBox( 8, 0, 0, w, h, Color( 62, 62, 62 ) )
            draw.SimpleText( v[1]:Name(), "ColorRun:32", 85, h / 2, Color( 255, 255, 255 ), 0, 1 )
            draw.SimpleText( "#" ..k, "ColorRun:32", w - 10, h / 2, k == 1 and Color( 255, 255, 0 ) or k == 2 and Color( 200, 200, 200 ) or k == 3 and Color( 255, 0, 0 ) or Color( 255, 255, 255 ), 2, 1 )
            draw.SimpleText( v[2] .."points", "ColorRun:32", w / 2, h / 2, Color( 255, 255, 255 ), 1, 1 )
        end

        local avatar = vgui.Create( "AvatarImage", panel )
        avatar:Dock( LEFT )
        avatar:DockMargin( 5, 5, 5, 5 )
        avatar:SetWide( 65 )
        avatar:SetPlayer( v[1], 128 )
    end
end )