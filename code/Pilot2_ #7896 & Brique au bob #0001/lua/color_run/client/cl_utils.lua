surface.CreateFont( "ColorRun:84", {
    font = "Gotham Black",
    weight = 0,
    size = 84,
} )

surface.CreateFont( "ColorRun:54", {
    font = "Gotham Black",
    weight = 0,
    size = 54,
} )

surface.CreateFont( "ColorRun:32", {
    font = "Gotham Black",
    weight = 0,
    size = 32,
} )

surface.CreateFont( "ColorRun:24", {
    font = "Gotham Black",
    weight = 0,
    size = 24,
} )

surface.CreateFont( "ColorRun:16", {
    font = "Gotham Black",
    weight = 0,
    size = 16,
} )

for k, v in pairs( ColorRun.Config.Musics ) do
    sound.Add( {
        name = "colorrun_music_" ..k,
        channel = CHAN_STATIC,
        volume = 0.15,
        level = 80,
        pitch = 100,
        sound = v,
    } )
end

