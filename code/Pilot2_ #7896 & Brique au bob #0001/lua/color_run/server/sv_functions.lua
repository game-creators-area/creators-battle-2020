local math = math
local table = table
local round = {}
local colors = {
    Color( 249, 107, 107 ), -- primary addon color ( pink~red )
    Color( 241, 196, 15 ), -- yellow 
    Color( 52, 152, 219 ), -- blue 
    Color( 46, 204, 113 ), -- green
    Color( 142, 68, 173 ), -- purple
    Color( 230, 126, 34 ), -- orange
    Color( 243, 104, 224 ), -- pink
    Color( 0, 210, 211 ), -- turquoise
}
local current_music = 0
local already_played = {}
ColorRun.startofround = true

function ColorRun:NotifyPlayer( ply, text, type, time )
    ColorRun:SendNet( ColorRun.ENUMS.Notify, function() 
        net.WriteString( text ) 
        net.WriteInt( type, 4 )
        net.WriteInt( time and time or 0, 10 )
    end, ply )
end

function ColorRun:IsInTeam( ply1, ply2 )
    if not ColorRun.game["settings"].duos then return false end
end

function ColorRun:GenerateNewFloor( vector1, vector2 )
    if ColorRun.ZonePos["plates_pos"] then
        for k, v in ipairs( ColorRun.ZonePos["plates_pos"] ) do
            if not IsValid( v ) then continue end
            v:Remove()
        end
    end
    local vector = vector1
    local dist = vector2.x - vector1.x

    dist = math.Round( dist / 34, 0 )

    ColorRun.ZonePos["z"] = nil
    local a = 1
    local plates_pos = {}

    while vector:WithinAABox( vector1, vector2 ) do
        for i = 1, math.abs( dist ) do
            local vecx, vecy = vector:Unpack()
            math.randomseed( vecx and vecx + vecy * os.time() or os.time() * i * 100 )
            colort = colors[ math.random( 1, #colors ) ] -- Take a new color to avoid too much "winning" colors
       
            local prop1 = ents.Create( "colorplate" )            
            if not IsValid( prop1 ) then return end
            prop1:SetPos( ColorRun.ZonePos["z"] and Vector( vecx, vecy, ColorRun.ZonePos["z"] ) or vector )
            prop1:SetColor( Color( colort.r, colort.g, colort.b ) )
            prop1:SetCollisionGroup( COLLISION_GROUP_PLAYER )
            prop1:Spawn()
            if not ColorRun.ZonePos["z"] then
                prop1:DropToFloor()
                local x, y, z = prop1:GetPos():Unpack()
                ColorRun.ZonePos["z"] = z
            end
            plates_pos[#plates_pos + 1] = prop1

            vector = dist > 0 and vector + Vector( 36, 0, 0 ) or vector - Vector( 36, 0, 0 )
        end

        vector = vector1.y < vector2.y and vector1 + Vector( 0, a * 36, 0 ) or vector1 - Vector( 0, a * 36, 0 )
        a = a + 1
    end

    local x, y, z = vector1:Unpack()
    local a, b, c = vector2:Unpack()
    local midx, midy, midz = (x + a) / 2, (y + b) / 2, (z + c) / 2
    local middle = Vector(midx, midy, midz)

    ColorRun.ZonePos = ColorRun.ZonePos or {}
    ColorRun.ZonePos["vector1"] = vector1
    ColorRun.ZonePos["vector2"] = vector2
    ColorRun.ZonePos["middle"] = middle
    ColorRun.ZonePos["plates_pos"] = plates_pos

    ColorRun:SendNet( ColorRun.ENUMS.SendPlatesPos, function() net.WriteTable( plates_pos ) end, player.GetAll() )
end

local function ColorRun_GenerateRound()
    ColorRun.game["round"] = {}

    math.randomseed( os.time() )
    local rand = math.random(1, #ColorRun.game["settings"]["gamemodes"])

    if #ColorRun.game["settings"]["gamemodes"] == #already_played then
        already_played = {}
    end

    while already_played[rand] do
        rand = math.random(1, #ColorRun.game["settings"]["gamemodes"])
    end

    round["gamemode"] = rand
    round["id"] = ColorRun.game.roundsCount
    round["settings"] = ColorRun.Gamemodes[rand]

    ColorRun.game["round"]["gamemode"] = round["gamemode"]

    math.randomseed( os.time() * 10 + round["id"] / 2 + #ColorRun.game["settings"]["gamemodes"] * 10 )

    return round
end

local function FreezeAll()
    for k, v in pairs( ColorRun.game["players"]["all"] ) do
        k:Freeze( true )
    end

    timer.Simple( 3, function()
        if not ColorRun.game or not ColorRun.game["players"] or not ColorRun.game["players"]["all"] then return end
        for k, v in pairs( ColorRun.game["players"]["all"] ) do
            k:Freeze( false )
        end
    end )
end
 
local function TeleportRandom( ply, vector1, vector2 )
    if not IsValid(ply) or not ply:Alive() then return end
    
    vector1 = vector1 or ColorRun.ZonePos["vector1"]
    vector2 = vector2 or ColorRun.ZonePos["vector2"]
    
    local x1, y1, z1 = vector1:Unpack()
    local x2, y2, z2 = vector2:Unpack()
    local rand = Vector( math.random(x1,x2), math.random(y1,y2), math.random(z1,z2) )

    while not rand:WithinAABox( vector1 or ColorRun.ZonePos["vector1"], vector2 or ColorRun.ZonePos["vector2"] ) do
        rand = Vector( math.random( x1, x2 ), math.random( y1, y2 ), Vector( 0, 0, ColorRun.ZonePos["z"] + 10 ) )
    end
    
    ply:SetPos( rand )
end

local function endGame(forced)
    for k, v in pairs( ColorRun.game["players"]["all"] ) do
        ColorRun:NotifyPlayer( k, forced and ColorRun:GetTranslation( "end_game_forced" ) or ColorRun:GetTranslation( "end_game" ) , 0, 3 )
        k:Freeze(false)
        k:Spawn()
        
        TeleportRandom( k, ColorRun.ZonePos["tppos"]["start"], ColorRun.ZonePos["tppos"]["end"] )
        k:SetArmor( k.before.befarmor )
        k:SetHealth( k.before.befhealth )
        for x, y in pairs( k.before.befweapons ) do
            k:Give( y, true )
        end
        for x, y in pairs( k.before.befammos ) do
            k:GiveAmmo( y, game.GetAmmoName( x ), true )
        end

        k.ingame = false
        ColorRun:SendNet( ColorRun.ENUMS.EndGame, _, k )
    end
    
    for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
        if not IsValid(v) then ColorRun.ZonePos["plates_pos"][k] = nil continue end
        math.randomseed( os.time() + k * 100 + CurTime() * 11 + 120 * 12 / math.random(1, #colors) * 12 )

        local colort = colors[math.random(1, #colors) ]
        v:SetColor( Color( colort.r, colort.g, colort.b ) )
    end
    
    ColorRun.game = {}
    hook.Remove( "Think", "ColorRun:Hooks:Think" ) 
end

local function ColorRun_GenerateGame()
    timer.Create( "ColorRun:Timers:startGame", ColorRun.Config.queueTime, 1, function()
        if table.Count(ColorRun.queue["players"]) < 2 then
            for k,v in pairs( ColorRun.queue["players"] ) do
                ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "start_delayed" ), 0, 3 )
            end
            return
        end
        
        ColorRun.game = table.Copy(ColorRun.queue)
        ColorRun.queue = {}

        if ColorRun.game["settings"].duos then
            local plyNumInQueue = table.Count(ColorRun.game["players"])
            if plyNumInQueue > 2 and ( plyNumInQueue % 2 ) == 0 then
                ColorRun.game["duos"] = {}
                local notTeamed = {}
                local alreadyTeamed = {}
                local i = 1

                for k, v in pairs( ColorRun.game["players"] ) do
                    local team = ColorRun:GetPlayerTeam( k:SteamID64() )
                    local mate = nil

                    if table.IsEmpty( team ) then
                        notTeamed[k] = true
                        continue
                    end

                    for a, b in pairs( team ) do
                        if alreadyTeamed[a] then continue end
                        ColorRun.game["duos"][player.GetBySteamID64( a )] = i

                        if mate then
                            local aplayer = player.GetBySteamID64( a )
                            local mateplayer = player.GetBySteamID64( mate )
                            
                            mateplayer.mate = aplayer -- Set the "mate" mate's as "a" 
                            aplayer.mate = mateplayer -- Set the "a" mate's as "mate" 
                        end
                        alreadyTeamed[a] = true
                        mate = a
                    end
                    i = i + 1
                end

                local ii = 1
                local inc = 1
                local prev = nil

                for k, v in pairs( notTeamed ) do
                    ColorRun.game["duos"][k] = i + ii

                    if prev then                                
                        prev.mate = k
                        k.mate = prev
                        
                        ColorRun:NotifyPlayer( prev, ( ColorRun:GetTranslation("forceduowith") ):format( k:Nick() ) , 0, 5 )
                        ColorRun:NotifyPlayer( k, ( ColorRun:GetTranslation("forceduowith") ):format( prev:Nick() ) , 0, 5 )
                    end
                    
                    prev = k
                    if ( inc % 2 ) == 0 then
                        ii = ii + 1
                        prev = nil
                    end                                    
                    inc = inc + 1
                end
                ColorRun.game["settings"].duos = true
            else
                ColorRun:NotifyPlayer( ColorRun.game["owner"], ColorRun:GetTranslation("noduoss"), 0, 5 )
                ColorRun.game["settings"].duos = false
            end
        end

        local tbl = {
            ["alive"] = {},
            ["died"] = {},
            ["all"] = {},
            ["points"] = {}
        }

        for k,v in pairs(ColorRun.game["players"]) do
            tbl["all"][k] = true
            tbl["alive"][k] = true
            tbl["points"][k] = 0
        end

        ColorRun.game["players"] = tbl

        local i = 1        
        for k, v in pairs( ColorRun.game["players"]["all"] ) do

            local weapons = {}
            for i, y in pairs( k:GetWeapons() ) do
                weapons[#weapons + 1] = y:GetClass()
            end

            k.before = {
                befweapons = weapons,
                befammos = k:GetAmmo(),
                befarmor = k:Armor(),
                befhealth = k:Health()
            }

            k:StripWeapons()
            k:SetArmor(0)
            k:SetHealth(100)
            
            math.randomseed( os.time() + i * 1000 + k:UserID() )
            k.color = Color( math.random( 1, 255 ), math.random( 1, 255 ), math.random( 1, 255 ) )
            if k.mate and IsValid( k.mate ) and k.mate.color then
                k.color = Color( k.mate.color.r, k.mate.color.g, k.mate.color.b )
            end

            k.points = 0
            k.ingame = true
            TeleportRandom( k )

            ColorRun:SendNet( ColorRun.ENUMS.InitGame, function()
                ColorRun:WriteTable( {
                    mate = k.mate and k.mate or nil,
                    gameSettings = ColorRun.game["settings"]
                } )
            end, k )

            ColorRun:NotifyPlayer( k, "La partie commence !" , 0, 3 )

            i = i + 1
        end

        FreezeAll()
        ColorRun.game.roundsCount = 0

        ColorRun.startofround = true
        hook.Add( "Think", "ColorRun:Hooks:Think", function()
            if not ColorRun.startofround then return end
            if not ColorRun.game["players"] then hook.Remove( "Think", "ColorRun:Hooks:Think" ) return end

            if ColorRun.startofround and table.Count( ColorRun.game["players"]["all"] ) > 1 then
                ColorRun.game.roundsCount = ColorRun.game.roundsCount + 1
                local round = ColorRun_GenerateRound()

                if round["id"] <= ColorRun.game["settings"]["round_amount"] then
                    math.randomseed( os.time() )
                    local rand = math.random( 1, #ColorRun.Config.Musics )

                    for k, v in pairs( ColorRun.game["players"]["all"] ) do
                        ColorRun:SendNet( ColorRun.ENUMS.MusicInteract, function()
                            net.WriteInt( rand, 6 )
                        end, k )

                        ColorRun:SendNet( ColorRun.ENUMS.StartRound, function()                        
                            ColorRun:WriteTable( {
                                gamemode = round["gamemode"],
                                roundid = round["id"],
                            } )
                            net.WriteTable(ColorRun.game["players"]["all"])
                        end, k )
                    end
                    current_music = rand

                    local roundS = round["settings"]
                    ColorRun.game["settings"].color = roundS.colorPlayer

                    for k,v in pairs( ColorRun.game["players"]["all"] ) do
                        k:Spawn()
                        TeleportRandom( k )
                    end

                    FreezeAll()

                    roundS.firstCallback()

                    timer.Create( "ColorRun:timers:Round", roundS.timerDelay or 1 + 3, roundS.timerRepeats or 0, function()
                        roundS.callbackTimer()
                    end )

                    ColorRun.startofround = false
                else
                    endGame()
                end
            end
        end )
    end )
end

function ColorRun:RefreshQueue( ply, state, bp )
    if state == 1 then
        if not ColorRun.queue["players"] or not bp and table.IsEmpty(ColorRun.queue["players"]) then return end -- The bp is used as bypass when creating a new game
        if ColorRun.queue["players"][ply] then ColorRun:NotifyPlayer( ply, ColorRun:GetTranslation( "already_in_queue" ), 0, 3 ) return end
        ColorRun.queue["players"][ply] = true -- Add the player in the queue
        ply.mate = nil

        for k,v in pairs( ColorRun.queue["players"] ) do
            ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "joinedqueue" ):format(ply:Nick()), 0, 3 )
        end

        if table.Count(ColorRun.queue["players"]) >= 2 then
            if timer.Exists( "ColorRun:Timers:startGame") then return end
            for k,v in pairs( ColorRun.queue["players"] ) do
                ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "startingin" ):format( ColorRun.Config.queueTime ), 0, 3 ) 
            end
            ColorRun_GenerateGame()
        end
    elseif state == 2 then
        if not ColorRun.queue["players"] or table.IsEmpty(ColorRun.queue["players"]) or not ColorRun.queue["players"][ply] then return end
        if ColorRun.queue["owner"] == ply then
            for k,v in pairs( ColorRun.queue["players"] ) do
                ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "game_disbanded" ), 0, 3 )
            end
            ColorRun.queue = {}
            return
        end

        for k,v in pairs( ColorRun.queue["players"] ) do
            ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "leftqueue" ):format(ply:Nick()), 0, 3 )
        end

        ply.ingame = false

        ColorRun:SendNet( ColorRun.ENUMS.EndGame, _, ply )
        ColorRun.queue["players"][ply] = nil
        
        if table.Count( ColorRun.queue["players"] ) < 2 then
            if timer.Exists( "ColorRun:Timers:startGame" ) then
                timer.Remove( "ColorRun:Timers:startGame" )
                for k, v in pairs( ColorRun.queue["players"] ) do
                    ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "start_delayed" ), 0, 3 )
                end
            end
        end
    end
end

function ColorRun:addPoints( ply, amount )
    if not ply or not IsValid( ply ) or not isnumber( amount ) then return end

    ply.points = ply.points + amount
    ColorRun.game["players"]["points"][ply] = ColorRun.game["players"]["points"][ply] + amount
    
end

function ColorRun:RoundEnded( amount )
    local winner = table.KeyFromValue( ColorRun.game["players"]["alive"], true )

    if winner and winner:IsPlayer() then        
        ColorRun:addPoints( winner, isnumber( amount ) and amount or 1 )
        if winner.mate and IsValid( winner.mate ) then
            ColorRun:addPoints( winner.mate, isnumber( amount ) and amount or 1 )
        end
    end

    for k, v in pairs( ColorRun.game["players"]["all"] ) do
        if winner and winner:IsPlayer() then 
            ColorRun:NotifyPlayer( k, ColorRun:GetTranslation( "has_win_round" ):format( winner:Name() ), 0, 3 )
        end

        ColorRun.game["players"]["died"][k] = nil
        ColorRun.game["players"]["alive"][k] = true

        ColorRun:SendNet( ColorRun.ENUMS.EndRound, function()
            net.WriteTable( ColorRun.game["players"]["points"] )
            net.WriteBool( not ( round["id"] <= ColorRun.game["settings"]["round_amount"] ) )

            net.WriteInt( current_music, 6 )
        end, k )
    end

    timer.Simple( 5.1, function()
        if not table.IsEmpty( ColorRun.game ) then
            ColorRun.game["round"]["gamemode"] = 0
            ColorRun.startofround = true
            timer.Remove( "ColorRun:timers:Round" )
        end
    end )
end

function ColorRun:ColorPlates()
    local colorU = {} -- Colors which are used
    ColorRun.game["valid_plates"] = {}
    ColorRun.game["round"].count = ColorRun.game["round"].count or 0 
    local color = colors[math.random(1, #colors)]

    for k, v in pairs( ColorRun.ZonePos["plates_pos"] ) do
        v.iswhite = false
        math.randomseed( os.time() + k * 100 + CurTime() * 11 + 120 * 12 / math.random(1, #colors) * 12 )

        local colort = colors[math.random(1, #colors) ] -- Take a new color into the 48 colors tables  
        
        if not ColorRun.game or not ColorRun.game["round"] then return end
        if (ColorRun.game["round"].count >= 3) then
            while colort.r == color.r and colort.g == color.g and colort.b == color.b do
                colort = colors[ math.random( 1, #colors ) ] -- Take a new color to avoid too much "winning" colors
            end
            v:SetColor( Color( colort.r, colort.g, colort.b ) )
        else
            v:SetColor( Color( colort.r, colort.g, colort.b ) )
        end
    end

    ColorRun.game["round"].currentcolor = Color( color.r, color.g, color.b ) -- Take a new color to avoid too much "winning" colors

    for i = 1, table.Count( ColorRun.game["players"]["alive"] ) do -- Be sure to have a minimum of "winning" plates 
        local randplate = math.random( 1, #ColorRun.ZonePos["plates_pos"] )
        ColorRun.ZonePos["plates_pos"][randplate]:SetColor( ColorRun.game["round"].currentcolor )
    end   
    
    for k,v in pairs( ColorRun.game["players"]["all"] ) do
        ColorRun:SendNet( ColorRun.ENUMS.ColorToGO, function() 
            net.WriteColor( ColorRun.game["round"].currentcolor ) 
        end, k )
    end

    ColorRun.game["round"].count = ColorRun.game["round"].count + 1
end

ColorRun:RegisterCallback( ColorRun.ENUMS.QuitGame, function( p )
    if not ColorRun.game["players"] or not ColorRun.game["players"]["alive"] or not ColorRun.game["players"]["all"][p] then return end
    p:Freeze(false)
    p:Spawn()
        
    TeleportRandom( p, ColorRun.ZonePos["tppos"]["start"], ColorRun.ZonePos["tppos"]["end"] )
    p:SetArmor( p.before.befarmor )
    p:SetHealth( p.before.befhealth )
    for x, y in pairs( p.before.befweapons ) do
        p:Give( y, true )
    end
    for x, y in pairs( p.before.befammos ) do
        p:GiveAmmo( y, game.GetAmmoName( x ), true )
    end
    p.ingame = false

    ColorRun.game["players"]["all"][p] = nil
    ColorRun.game["players"]["died"][p] = nil
    ColorRun.game["players"]["alive"][p] = nil

    ColorRun:SendNet( ColorRun.ENUMS.EndGame, _, p )
    ColorRun:NotifyPlayer( p, "Tu as quitté la partie", 0, 3 )
    
    ColorRun:SendNet( ColorRun.ENUMS.MusicInteract, function()
        net.WriteInt( 2, 3 )
        net.WriteInt( current_music, 6 )
    end, p )
    
    if table.Count(ColorRun.game["players"]["all"]) <= 1 then
        endGame( true )
    end
end )