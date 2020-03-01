include( "shared.lua" )

surface.CreateFont("Texte", {
    font = "bauhaus 93",
    size = 60,
    weight = 150
})

surface.CreateFont("SousTexte", {
    font = "bauhaus 93",
    size = 30,
    weight = 150
})

function ENT:Draw()
    self:DrawModel()
end


-- /!\La mise a l'echelle a été faite sur une résolution 2560x1440./!\
/*
local function DesignMenu() 
    draw.RoundedBox( 10, 6.5, 0, w - 17, h, Color( 33, 36, 61 ) )              -- Contour Bleu foncé                        -- w-8.5, h,
    draw.RoundedBox( 8, 8.5, h / 21 + 1, w - 21, h - 25, color_white )         -- Fond Blanc                                -- w-16, h-4,
    draw.RoundedBox( 0, 9, h / 21, w - 21, 62, Color( 136, 225, 242 ) )        -- Barre du menu des options  Bleu clair     -- w-16, h-424,        
    draw.RoundedBox( 5, 0, 0, w, h / 18, Color( 33, 36, 61 ) )                -- Barre de fenetre  Bleu foncé              -- w, h-430,
end

local function OuvreInteogations()
    InterogationBouton:SetPos(ScrW()*0.042, ScrH()*0.035)     -- (110, 53)
    InterogationBouton:SetSize(ScrW()*0.019, ScrH()*0.034)    -- (50, 50)
    InterogationBouton:SetImage( "interrogation.png" )
end

local function OuvrePlus()
    PlusBouton:SetPos(ScrW()*0.160, ScrH()*0.035)     -- (410, 53)
    PlusBouton:SetSize(ScrW()*0.019, ScrH()*0.034)    -- (50, 50)
    PlusBouton:SetImage( "plus.png" )
    PlusBouton.DoClick = function()
    end  
end

local function OuvreOptions()
    OptionsBouton:SetPos( ScrW()*0.273, ScrH()*0.035 )     -- (700, 53)
    OptionsBouton:SetSize( ScrW()*0.019, ScrH()*0.034 )    -- (50, 50)
    OptionsBouton:SetImage( "options.png" )
    PlusBouton.DoClick = function()
    end  
end
*/

net.Receive( "OuvrePanel", function( len, ply )
    local ent = net.ReadEntity()
    local main = vgui.Create( "DFrame" )
    local newgmtable = {}
    main:SetPos( ScrW() / 3, ScrH() / 5 )
    --main:SetSize( ScrW() / 3, ScrH() / 30 )
    main:SetSize( ScrW() / 3, ScrH() / 1.75 )
    main:SetTitle( "" )
    main:SetAlpha( 0 )
    main:MakePopup()
    main:SetDraggable( false )
    main:ShowCloseButton( false )
    main:AlphaTo( 255, 1, 0, function()
    end )

    function main:Paint( w, h )
        draw.RoundedBox( 10, 6.5, 0, w - 17, h, Color( 33, 36, 61 ) )              -- Contour Bleu foncé                        -- w-8.5, h,
        draw.RoundedBox( 8, 8.5, h / 21 + 1, w - 21, h - 25, color_white )         -- Fond Blanc                                -- w-16, h-4,
        draw.RoundedBox( 0, 9, h / 21, w - 21, 62, Color( 136, 225, 242 ) )        -- Barre du menu des options  Bleu clair     -- w-16, h-424,        
        draw.RoundedBox( 5, 0, 0, w, h / 18, Color( 33, 36, 61 ) )                -- Barre de fenetre  Bleu foncé              -- w, h-430,
        draw.SimpleText( "Libre", "Texte", ScrW() / 6.25, ScrH() / 12.4, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )     -- Taille= 400, 150    4.5
        draw.SimpleText( "Solo", "Texte", ScrW() / 6.25, ScrH() / 4, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )     -- Taille= 400, 270    12.5
        draw.SimpleText( "Equipe", "Texte", ScrW() / 6.25, ScrH() / 2.5, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )    -- Taille= 400, 400    2.5
    end

    FermerMenu = vgui.Create( "DButton", main) 				
    FermerMenu:SetPos( ScrW()*0.318, ScrH()*0.006 )    -- (808, 9) 				
    FermerMenu:SetSize( ScrW()*0.011, ScrH()*0.020 )   -- (30, 30) 
    FermerMenu:SetText("")						
    FermerMenu.DoClick = function()
        main:AlphaTo( 0, 1, 0, function()
            main:Close()
        end )						
    end
    FermerMenu.Paint = function( s, w, h )
        draw.RoundedBox(6,0,0,w ,h , Color(200,43,9) )
    end

    InterogationBoutonAcceuil = vgui.Create( "DImageButton", main )
    --OuvreInteogations()
        if main:IsValid() then
            main:Close() --MenuInformations()
        end
    end*/

    PlusBoutonAccueil = vgui.Create( "DImageButton", main )
    --OuvrePlus()  

    OptionsBoutonAccueil = vgui.Create( "DImageButton", main )
    --OuvreOptions()
    

    -- Logo Libre - Solo - Equipe
    local LibreBouton = vgui.Create( "DImageButton", main )
    LibreBouton:SetPos( ScrW() / 6.90, ScrH() / 7.1 )     -- (410, 180)
    LibreBouton:SetSize( ScrW() / 25, ScrH() / 18 )    -- (100, 60)
    LibreBouton:SetImage( "libre.png" )
    LibreBouton.DoClick = function() 
        for k, v in pairs( MJTable ) do
            for a, b in pairs( v.mode ) do
                if b == "Libre" then
                    newgmtable[ #newgmtable + 1 ] = v
                end
            end
        end
    end
           
    local SoloBouton = vgui.Create( "DImageButton", main )
    SoloBouton:SetPos( ScrW() / 6.40, ScrH() / 3.22 )     -- (437, 300)
    SoloBouton:SetSize( ScrW() / 50, ScrH() / 20 )    -- (50, 70)
    SoloBouton:SetImage( "solo.png" )
    SoloBouton.DoClick = function() 
        for k, v in pairs( MJTable ) do
            for a, b in pairs( v.mode ) do
                if b == "Solo" then
                    newgmtable[ #newgmtable + 1 ] = v
                end
            end
        end       
    end 

    local EquipeBouton = vgui.Create( "DImageButton", main )
    EquipeBouton:SetPos( ScrW() / 6.81, ScrH() / 2.15 )     -- (410, 440)
    EquipeBouton:SetSize( ScrW() / 25, ScrH() / 20 )    -- (100, 50)
    EquipeBouton:SetImage( "equipe.png" )
    EquipeBouton.DoClick = function()
        for k, v in pairs( MJTable ) do
            for a, b in pairs( v.mode ) do
                if b == "Equipe" then
                    newgmtable[ #newgmtable + 1 ] = v
                end
            end
        end     
    end


    function MenuInformations()
        MInformations = vgui.Create( "DFrame" ) 
        MInformations:SetPos( ScrW() / 3, ScrH() / 3 )
        MInformations:SetSize( ScrW() / 10, ScrH() / 10 )
        MInformations:SetTitle( "" )
        MInformations:SetAlpha( 0 )
        MInformations:MakePopup()
        MInformations:SetDraggable( false )
        MInformations:ShowCloseButton( true )
        MInformations:AlphaTo( 255, 1, 0, function()
            MInformations:SizeTo( ScrW() / 3, ScrH() / 3, 1, 0, -1 )
        end )
   

        function MInformations:Paint( w, h )
            --DesignMenu() 

            draw.SimpleText( "Le mode libre", "Texte", ScrW()/0.156, ScrH()/0.104, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )     -- Taille= 
            draw.SimpleText( "Ceci et le mode par defaut, et mélange tous les modes", "SousTexte", ScrW()*0.156, ScrH()*0.135, Color( 100, 287, 218 ), TEXT_ALIGN_CENTER )

            draw.SimpleText( "Le mode solo", "Texte", ScrW()/0.156, ScrH()/0.161, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )      -- Taille= 
            draw.SimpleText( "Ce derrnier n'accepte pas les modes de jeu en équipe.", "SousTexte", ScrW()*0.156, ScrH()*0.192, Color( 100, 287, 218 ), TEXT_ALIGN_CENTER )

            draw.SimpleText( "Le mode equipe", "Texte", ScrW()/0.156, ScrH()/0.223, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )    -- Taille= 
            draw.SimpleText( "Les mini jeux se joue exclusivement en équipe.", "SousTexte", ScrW()*0.146, ScrH()*0.258, Color( 100, 287, 218 ), TEXT_ALIGN_CENTER )

            draw.SimpleText( "Crédits", "Texte", ScrW()/0.156, ScrH()/0.285, Color( 100, 204, 218 ), TEXT_ALIGN_CENTER )
            draw.SimpleText( "Cet addons a été créé par Mamouthe et Arkov le chauve,\n pour le concours Creator Battle organisé par GCA", "SousTexte", ScrW()*0.156, ScrH()*0.316, Color( 100, 287, 218 ), TEXT_ALIGN_CENTER )

        end

        AcceuilBoutonInterogations = vgui.Create( "DImageButton", MInformations )
        --OuvreInteogations()
        InterogationBouton.DoClick = function()
            if MInformations:IsValid() then
                MInformations:Close() 
                --main()
            end

        PlusBoutonInterogations = vgui.Create( "DImageButton", MInformations )
            --OuvrePlus()  
        
        OptionsBoutonInterogations = vgui.Create( "DImageButton", MInformations )
            --OuvreOptions()
        end 
    end
end )
