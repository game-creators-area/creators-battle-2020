SWEP.PrintName			= "Color Run Tool"
SWEP.Category = "Color Run"
SWEP.Author			    = ""
SWEP.Instructions		= ""

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

local vector1
local vector2
local spam = 0
local mode = 2
local ent
local entang = 0

local arrowspam = 0
local modes = {
    [1] = {
        name = "Création de zone de jeu",
        primary = function( self )
            if SERVER then return end
            if spam >= CurTime() then return end
        
            if not isvector( vector1 ) and not isvector( vector2 ) then 
                vector1 = self.Owner:GetEyeTrace().HitPos
                spam = CurTime() + 0.5
                return
            end
            if not isvector( vector2 ) and isvector( vector1 ) then
                vector2 = self.Owner:GetEyeTrace().HitPos
                spam = CurTime() + 0.5
                return
            end
        end,
        secondary = function( self )
            if CLIENT then
                if not vector1 and vector2 or not isvector(vector1) or not isvector(vector2) then return end
                ColorRun:SendNet( ColorRun.ENUMS.CreateZone, function() net.WriteVector( vector1 ) net.WriteVector( vector2 ) end )
                vector1 = nil
                vector2 = nil
            end
        end,
        reload = function( self )
            if not vector1 and not vector2 then
                mode = 2
                return
            end
            vector1 = nil
            vector2 = nil
        end
    },
    [2] = {
        name = "Création de npc",
        primary = function( self )
            if SERVER then return end
            if spam >= CurTime() then return end
            
            ColorRun:SendNet( ColorRun.ENUMS.CreateNPC, function() net.WriteInt( entang, 10 ) end )
            spam = CurTime() + 1
        end,
        secondary = function( self )
        end,
        reload = function( self )
            mode = 3
            if IsValid( ent ) then ent:Remove() end
        end,
        think = function( self )
            if SERVER then return end
            if IsValid( ent ) then ent:Remove() end
            if self.Owner:GetActiveWeapon():GetClass() ~= "colorrun_tool" then return end

            if input.IsMouseDown( MOUSE_RIGHT ) then
                entang = entang + 1
                if entang >= 360 then
                    entang = 0
                end
            end

            if input.IsKeyDown( KEY_DOWN ) then
                if arrowspam < CurTime() then
                    entang = entang - 1
                    if entang <= 0 then
                        entang = 360
                    end
                    arrowspam = CurTime() + 0.1
                end
            end

            if input.IsKeyDown( KEY_UP ) then
                if arrowspam < CurTime() then
                    entang = entang + 1
                    if entang >= 360 then
                        entang = 0
                    end
                    arrowspam = CurTime() + 0.1
                end
            end

            ent = ents.CreateClientProp( ColorRun.Config.NpcSkin )
            ent:SetModel( ColorRun.Config.NpcSkin )
            ent:SetPos( self.Owner:GetEyeTrace().HitPos )
            ent:SetAngles( Angle( 0, entang, 0 ) )
            ent:Spawn()
        end
    },
    [3] = {
        name = "Création de zone de téléportation",
        primary = function( self )
            if SERVER then return end
            if spam >= CurTime() then return end
        
            if not isvector( vector1 ) and not isvector( vector2 ) then 
                vector1 = self.Owner:GetEyeTrace().HitPos
                spam = CurTime() + 0.5
                return
            end
            if not isvector( vector2 ) and isvector( vector1 ) then
                vector2 = self.Owner:GetEyeTrace().HitPos
                spam = CurTime() + 0.5
                return
            end
        end,
        secondary = function( self )
            if CLIENT then
                if not vector1 and vector2 or not isvector(vector1) or not isvector(vector2) then return end
                ColorRun:SendNet( ColorRun.ENUMS.CreateTPZone, function() net.WriteVector( vector1 ) net.WriteVector( vector2 ) end )
                vector1 = nil
                vector2 = nil
            end
        end,
        reload = function( self )
            if not vector1 and not vector2 then
                mode = 1
                return
            end
            vector1 = nil
            vector2 = nil
        end
    }
}

function SWEP:PrimaryAttack()
    modes[mode]["primary"]( self )
end

function SWEP:SecondaryAttack()
    modes[mode]["secondary"]( self )
end

function SWEP:Reload()
    if spam >= CurTime() then return end
    modes[mode]["reload"]( self )
    spam = CurTime() + 1
end

function SWEP:Think()
    if isfunction( modes[mode]["think"] ) then
        modes[mode]["think"]( self )
    end
end

function SWEP:OnRemove()
    if IsValid( ent ) then
        ent:Remove()
    end
end

local instructions = {
    [1] = ColorRun:GetTranslation( "SWEP_1" ),
    [2] = ColorRun:GetTranslation( "SWEP_2" ),
    [3] = ColorRun:GetTranslation( "SWEP_3" ),
    [4] = ColorRun:GetTranslation( "SWEP_4" ),
    [5] = ColorRun:GetTranslation( "SWEP_5" ),
}

local LerpCircle = 0
function SWEP:DrawHUD()
    local w, h = ScrW(), ScrH()

    surface.SetFont( "ColorRun:32" )
    local sizex = surface.GetTextSize( modes[mode]["name"] )

    draw.RoundedBox( 8, w - sizex - 30, 10, sizex + 20, 60, Color( 52, 52, 52 ) )
    draw.SimpleText( modes[mode]["name"], "ColorRun:32", w - sizex / 2 - 20, 40, Color( 255, 255, 255 ), 1, 1 )

    if mode == 2 then
        if input.IsMouseDown( MOUSE_RIGHT ) or input.IsKeyDown( KEY_DOWN ) or input.IsKeyDown( KEY_UP ) then
            LerpCircle = Lerp( FrameTime() * 8, LerpCircle, 80 )
        else
            LerpCircle = Lerp( FrameTime() * 2, LerpCircle, 0 )
        end
    else
        LerpCircle = 0
    end

    ColorRun:DrawCircle( w / 2, h, LerpCircle )

    draw.RoundedBox( 8, 10, 10, 410, 320, Color( 52, 52, 52 ) )
    draw.SimpleText( entang .."°", "ColorRun:32", w / 2, h - LerpCircle / 1.8, Color( 255, 255, 255 ), 1, 5 )

    local opx, opy = 20, 30
    for i=1, #instructions do
        local exploded = string.Explode( " ", instructions[i] )

        for x = 1, #exploded do
            surface.SetFont( "ColorRun:24" )
            local sx = surface.GetTextSize( exploded[x] )
            draw.SimpleText( exploded[x], "ColorRun:24", opx, opy, Color( 255, 255, 255 ), 0, 1 )

            opx = opx + sx + 5
            if x == #exploded then
                opx = 20
                opy = opy + 35
                continue
            end
            if opx > 370 then
                opx = 20
                opy = opy + 20
            end
        end
    end
end

hook.Add( "PostDrawOpaqueRenderables", "ColorRun:Hooks:PostDrawOpaqueRenderables:Swep", function()
    local ply = LocalPlayer()
    if not IsValid( ply ) then return end
    if not ply:Alive() then return end
    if not IsValid( ply:GetActiveWeapon() ) then return end
    if ply:GetActiveWeapon():GetClass() ~= "colorrun_tool" then return end

    local ang = Angle( 0, 0, 0 )
    local x, y, z
    local a, b, c
    if isvector( vector1 ) and isvector( vector2 ) then
        x, y, z = vector1:Unpack()
        a, b, c = vector2:Unpack()
    end
    cam.Start3D2D( isvector( vector1 ) and vector1 + Vector( 0, 0, 5 ) or Vector( 0, 0, 0 ), ang, 1 )
        surface.SetDrawColor( Color( 170, 170, 170 ) )
        surface.DrawRect( 0, 0, a and ( a - x ) or 10, b and ( y - b ) or 10 )
    cam.End3D2D()
end )

if SERVER then
    hook.Add( "PlayerSwitchWeapon", "ColorRun:Hooks:PlayerSwitchWeapon:AdminTool:Modify", function( ply, old, new )
        if not IsValid( ply ) then return end
        if not IsValid( old ) then return end
        if old:GetClass() ~= "colorrun_tool" then return end
        timer.Simple( 0, function()
            ply:StripWeapon( "colorrun_tool" )
        end)
    end )
end