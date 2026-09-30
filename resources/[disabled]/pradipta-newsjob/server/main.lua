local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions', 'Commands' })

RegisterNetEvent('pradipta-newsjob:server:addVehicleItems', function(plate)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
    if not exports['pradipta-vehiclekeys']:HasKeys(src, plate) then return end

    exports['pradipta-inventory']:CreateInventory('trunk-' .. plate)

    for slot, item in pairs(Config.VehicleItems) do
        exports['pradipta-inventory']:AddItem('trunk-' .. plate, item.name, item.amount, slot, item.info, 'pradipta-newsjob:vehicleItems')
    end
end)

if Config.UseableItems then
    PradiptaCore.Functions.CreateUseableItem('newscam', function(source)
        local Player = exports['pradipta-core']:GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Cam:ToggleCam', source)
    end)

    PradiptaCore.Functions.CreateUseableItem('newsmic', function(source)
        local Player = exports['pradipta-core']:GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Mic:ToggleMic', source)
    end)

    PradiptaCore.Functions.CreateUseableItem('newsbmic', function(source)
        local Player = exports['pradipta-core']:GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Mic:ToggleBMic', source)
    end)
else
    PradiptaCore.Commands.Add('newscam', 'Grab a news camera', {}, false, function(source, _)
        local Player = exports['pradipta-core']:GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Cam:ToggleCam', source)
    end)

    PradiptaCore.Commands.Add('newsmic', 'Grab a news microphone', {}, false, function(source, _)
        local Player = exports['pradipta-core']:GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Mic:ToggleMic', source)
    end)

    PradiptaCore.Commands.Add('newsbmic', 'Grab a Boom microphone', {}, false, function(source, _)
        local Player = exports['pradipta-core']:GetPlayer(source)
        if not Player or Player.PlayerData.job.name ~= 'reporter' then return end

        TriggerClientEvent('Mic:ToggleBMic', source)
    end)
end
