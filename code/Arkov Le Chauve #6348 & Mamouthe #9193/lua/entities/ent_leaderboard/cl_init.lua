include( "shared.lua" )

/*
    Traitement de la table, il faut la mettre en ordre décroissant et prendre les dix premiers
*/

local scoretbl = {
    [1] = { ent = "Mamouthe", score = 15 },
    [2] = { ent = "Arkov", score = 1 },
    [3] = { ent = "JeanLuc", score = 12 },
    [4] = { ent = "Pierre", score = 16 },
    [5] = { ent = "Claude", score = 15 },
    [6] = { ent = "Kevin", score = 2 },
    [7] = { ent = "Charles", score = 3 },
    [8] = { ent = "Bot01", score = 4 },
    [9] = { ent = "Titouan", score = 6 },
    [10] = { ent = "Séraphin", score = 8 },
    [11] = { ent = "Robert", score = 1 }
}

local newscoretbl = {}
local i = 0

for k, v in SortedPairsByMemberValue( scoretbl, "score", true ) do
    i = i + 1
    local tbln = string.ToTable( v.ent )
    if table.Count( tbln ) > 6 then
        name = tbln[1] .. tbln[2] .. tbln[3] .. tbln[4] .. tbln[5] .. tbln[6] .. "..."
    else
        name = v.ent
    end

    newscoretbl[i] = { ent = name, score = v.score }
end

/*
    Partie 3d2d de l affichage du tableau
*/

function ENT:Draw()
    self:DrawModel()

    if self:GetPos():DistToSqr( LocalPlayer():GetPos() ) < 950000 then 
        cam.Start3D2D( self:LocalToWorld( Vector( self:OBBMaxs().x - 60.25, self:OBBMaxs().y - 84, self:OBBMaxs().z - 70.4 ) ), self:LocalToWorldAngles( Angle( 0, 90, 0 ) ) , 0.85 )
            surface.SetDrawColor( Color( 20, 190, 255 ) )
            surface.DrawRect( 0, 0, self:OBBMaxs().x + 154.5, self:OBBMaxs().y + 98.5 )
            surface.SetDrawColor( color_white )
            surface.DrawRect( 0, 0, self:OBBMaxs().x + 154.5, self:OBBMaxs().y + 2 )
            surface.SetDrawColor( color_black )
            surface.DrawLine( 85, 15, 85, 110 )
            surface.DrawLine( 0, 14.5, 166, 14.5 )
            surface.SetFont( "Default" )
            surface.SetTextColor( Color( 85, 85, 60 ) )
            surface.SetTextPos( 40, 0 ) 
            surface.DrawText( self.PrintName )
            for k, v in pairs( newscoretbl ) do
                if k > 10 then
                    break
                end
                if k > 5 then
                    surface.SetTextPos( 5, 2 + ( k - 5 ) * 18 ) 
                    surface.DrawText( v.ent )
                    surface.SetTextPos( 135, 2 + ( k - 5 ) * 18 ) 
                    surface.DrawText( ": " .. v.score )
                    surface.SetTextPos( 66, 2 + ( k - 5 ) * 18 ) 
                    surface.DrawText( " pts" )
                else
                    surface.SetTextPos( 87, 2 + k * 18 ) 
                    surface.DrawText( v.ent  )
                    surface.SetTextPos( 45, 2 + k * 18 ) 
                    surface.DrawText( ": " .. v.score )
                    surface.SetTextPos( 149, 2 + k * 18 ) 
                    surface.DrawText( " pts" )
                end
                if !( k > 4 ) then
                    surface.DrawLine( 0, 107 + ( k - 5 ) * 18, 166, 107 + ( k - 5 ) * 18 )
                end
            end
        cam.End3D2D() 
    end
end