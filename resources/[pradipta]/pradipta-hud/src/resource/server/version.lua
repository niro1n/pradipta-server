CreateThread(function()
    local resourceName  = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resourceName, "version", 0) or "2.0.1"

    Wait(1500)
    print("^1===================================================^0")
    print("^2[PRADIPTA HUD]^0 ^7v" .. currentVersion .. " by ^3niroin^0 initialized successfully!^0")
    print("^7Server: ^5PRADIPTA SERVER^0")
    print("^1===================================================^0")
end)
