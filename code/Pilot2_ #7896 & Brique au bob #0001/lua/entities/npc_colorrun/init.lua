AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ColorRun.NPC = ColorRun.NPC or {}
ColorRun.NPC.TPPos = Vector( 0, 0, 0 )

function ENT:Initialize( )
	self:SetModel( ColorRun.Config.NpcSkin )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE )
    self:SetUseType( SIMPLE_USE )
    self:DropToFloor()
end

function ENT:OnRemove()   
end

function ENT:AcceptInput( name, ply )
    if name ~= "Use" then return end
    ColorRun:SendNet(ColorRun.ENUMS.OpenMenu, function()
        local table = ColorRun:GetPlayerTeam( ply:SteamID64() )        
        net.WriteTable( table )
        net.WriteBool( ColorRun.queue["players"] and ColorRun.queue["players"][ply] or false )
        net.WriteBool( IsValid(ColorRun.queue["owner"]) and true or false )
    end, ply)
end