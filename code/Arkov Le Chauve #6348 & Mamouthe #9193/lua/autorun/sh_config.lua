/*
    Ne pas toucher.
*/

MJTable = {
    [1] = { name = "Tampon", desc = "Il y a deux équipes de différentes couleurs, les joueurs doivent foncer dans leurs adversaires pour que ce dernier rejoigne son équipe, l’équipe qui n’a plus de joueurs perd la manche.", but = "Foncer dans le joueur adverse pour qu’il rejoigne votre équipe.", howtowin = "Tout les joueurs doivent être capturés par l’équipe adverse.", minplayers = 4, mode = { "Libre", "Equipe" } },
    [2] = { name = "Mélée Générale", desc = "Chaque joueur a une vie de départ, le dernier joueur en vie gagne la partie.", but = "Tuer tout le monde et être le dernier survivant.", howtowin = "Etre la dernière équipe.", minplayers = 2, mode = {"Libre", "Solo"} },
    [3] = { name = "Tamponneuse de Baudruche", desc = "Les joueurs ont plusieurs ballons, le dernier joueur en vie avec ses ballons gagne. ", but = "Éclater les ballons des adversaires.", howtowin = "Etre le dernier survivant avec ses ballon.", minplayers = 2 , mode = {"Libre", "solo"} },
    [4] = { name = "Titan VS Minions", desc = "Il y a un joueur contre tous les autres joueurs. Le joueur contre tousse et le titan avec des capacités spéciales pour combattre tous les joueurs, le but de chaque équipe et de tuer l’adversaire.", but = "Tuer le Titan ou les Minions.", howtowin = "Etre la dernière équipe en vie.", minplayers = 4, mode = {"Libre", "Equipe", "Solo"} },
    [5] = { name = "Footampon", desc = "Il y a deux équipes, chacune des équipes doit marquer 5 buts pour gagner.", but = "Marquer des buts.", howtowin = "Marquer 5 buts avant l'autre équipe.", minplayers = 2, mode = {"Libre", "equipe"} },  
}