net.Receive( "ColorRun:Networking", function()
    local netid = net.ReadInt(6)
    if not netid then return end
    if not ColorRun.netsCallbacks[netid] then return end

    ColorRun.netsCallbacks[netid]()
end )