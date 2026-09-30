RegisterNetEvent('tackle:server:TacklePlayer', function(playerId)
    TriggerClientEvent('tackle:client:GetTackled', playerId)
end)

PradiptaCore.Commands.Add('id', 'Check Your ID #', {}, false, function(source)
    TriggerClientEvent('PradiptaCore:Notify', source, 'ID: ' .. source)
end)

PradiptaCore.Functions.CreateUseableItem('harness', function(source, item)
    TriggerClientEvent('seatbelt:client:UseHarness', source, item)
end)

RegisterNetEvent('equip:harness', function(item)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    if not Player.PlayerData.items[item.slot].info.uses then
        Player.PlayerData.items[item.slot].info.uses = Config.HarnessUses - 1
        Player.SetInventory(Player.PlayerData.items)
    elseif Player.PlayerData.items[item.slot].info.uses == 1 then
        exports['pradipta-inventory']:RemoveItem(src, 'harness', 1, false, 'equip:harness')
        TriggerClientEvent('pradipta-inventory:client:ItemBox', src, PradiptaCore.Shared.Items['harness'], 'remove')
    else
        Player.PlayerData.items[item.slot].info.uses -= 1
        Player.SetInventory(Player.PlayerData.items)
    end
end)

RegisterNetEvent('seatbelt:DoHarnessDamage', function(hp, data)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    if hp == 0 then
        exports['pradipta-inventory']:RemoveItem(src, 'harness', 1, data.slot, 'seatbelt:DoHarnessDamage')
    else
        Player.PlayerData.items[data.slot].info.uses -= 1
        Player.SetInventory(Player.PlayerData.items)
    end
end)

RegisterNetEvent('pradipta-carwash:server:washCar', function()
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)

    if not Player then return end

    if Player.RemoveMoney('cash', Config.CarWash.defaultPrice, 'car-washed') then
        TriggerClientEvent('pradipta-carwash:client:washCar', src)
    elseif Player.RemoveMoney('bank', Config.CarWash.defaultPrice, 'car-washed') then
        TriggerClientEvent('pradipta-carwash:client:washCar', src)
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.dont_have_enough_money'), 'error')
    end
end)

PradiptaCore.Functions.CreateCallback('smallresources:server:GetCurrentPlayers', function(_, cb)
    cb(#GetPlayers())
end)
