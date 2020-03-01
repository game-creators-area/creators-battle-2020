AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString( "OuvrePanel" )
util.AddNetworkString( "ManageParty" )

function ENT:Initialize()
    ent = self
    self:SetModel( "models/gman_high.mdl" )
    self:SetHullType( HULL_HUMAN )
    self:SetHullSizeNormal()
    self:SetNPCState( NPC_STATE_SCRIPT )
    self:SetSolid( SOLID_BBOX )
    self:SetUseType( SIMPLE_USE )
    self:DropToFloor()
    self:SetRoundStage( 3 )
end

function ENT:Use( ply )
    if not IsFirstTimePredicted() then return end
    if ply:IsPlayer() then
        net.Start( "OuvrePanel" )
            net.WriteEntity( self )
        net.Send( ply )
	end
end

/*
    Vérification du statut de la partie ( fait les actions nécessaires pour chaque stades de la partie )
*/

net.Receive( "ManageParty", function( len, ply )
    ent:SetRoundStage( net.ReadInt( 4 ) )
    if ent:GetRoundStage() == 0 then
        ent:SetRoundStage( 1 )
        ent:SetRoundType( net.ReadString() )
        ent:SetRoundGameMode( net.ReadString() )
        ply:PrintMessage(HUD_PRINTCENTER, "Votre partie est en attente.")
    elseif ent:GetRoundStage() == 1 then
        ply:PrintMessage(HUD_PRINTCENTER, "Une partie est déjà en attente.")
    elseif ent:GetRoundStage() == 2 then
        ply:PrintMessage(HUD_PRINTCENTER, "Une partie est déjà lancée.")
    elseif ent:GetRoundStage() == 3 then
        /*
            Définition des trois premiers + don de récompense aux trois premiers
            + notifs pour les informer + status défini en attente.
        */
        ent:SetFirstWinner( net.ReadEntity() )
        ent:SetSecondWinner( net.ReadEntity() )
        ent:SetThirdWinner( net.ReadEntity() )

        ent:GetFirstWinner():SetNWInt( "score", ent:GetFirstWinner():GetNWInt( "score" ) + 30 )
        ent:GetSecondWinner():SetNWInt( "score", ent:GetSecondWinner():GetNWInt( "score" ) + 20 )
        ent:GetThirdWinner():SetNWInt( "score", ent:GetThirdWinner():GetNWInt( "score" ) + 10 )

        ent:GetFirstWinner():PrintMessage(HUD_PRINTCENTER, "Félicitations ! Vous gagnez 30 points pour votre premier place.")
        ent:GetSecondWinner():PrintMessage(HUD_PRINTCENTER, "Félicitations ! Vous gagnez 20 points pour votre deuxième place.")
        ent:GetThirdWinner():PrintMessage(HUD_PRINTCENTER, "Félicitations ! Vous gagnez 10 points pour votre troisième place.")

        ent:SetRoundStage( 1 )
        ent:SetRoundType( net.ReadString() )
        ent:SetRoundGameMode( net.ReadString() )
        ply:PrintMessage(HUD_PRINTCENTER, "Votre partie est en attente.")
    end
end )