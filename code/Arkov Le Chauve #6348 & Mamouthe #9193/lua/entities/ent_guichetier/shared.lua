ENT.Type = "ai"
ENT.Base = "base_ai"

ENT.Author = "Mamouthe & Arkov Le Chauve"
ENT.PrintName = "Guichetier"
ENT.Category = "Creator Battle - Mini jeux"
ENT.Instructions = ""

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "RoundStage" ) -- Le statut de la partie ( Inactif = 0, En attente = 1, En cours = 2, Terminée = 3 )
    self:NetworkVar( "String", 0, "RoundType" ) -- Le mode ( solo, libre, équipe )
    self:NetworkVar( "String", 1, "RoundGameMode" ) -- Le mini-jeu ( Tampon, Mélée Générale, Tamponneuse de Baudruche, Titan VS Minions, Footampon, ect.. )
    self:NetworkVar( "String", 2, "TeamWinning" ) -- L'équipe gagnante
    self:NetworkVar( "Entity", 0, "FirstWinner" ) -- Le premier
    self:NetworkVar( "Entity", 0, "SecondWinner" ) -- Le deuxieme
    self:NetworkVar( "Entity", 0, "ThirdWinner" ) -- Le troisieme
end