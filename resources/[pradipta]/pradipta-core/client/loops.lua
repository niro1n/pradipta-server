CreateThread(function()
    while true do
        local sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * PradiptaCore.Config.UpdateInterval
            TriggerServerEvent('PradiptaCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)
