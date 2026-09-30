local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions' })
local sharedItems = exports['pradipta-core']:GetShared('Items')

local function exploitBan(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(id),
            PradiptaCore.Functions.GetIdentifier(id, 'license'),
            PradiptaCore.Functions.GetIdentifier(id, 'discord'),
            PradiptaCore.Functions.GetIdentifier(id, 'ip'),
            reason,
            2147483647,
            'pradipta-pawnshop'
        })
    TriggerEvent('pradipta-log:server:CreateLog', 'pawnshop', 'Player Banned', 'red',
        string.format('%s was banned by %s for %s', GetPlayerName(id), 'pradipta-pawnshop', reason), true)
    DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

RegisterNetEvent('pradipta-pawnshop:server:sellPawnItems', function(itemName, itemAmount, itemPrice)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    local totalPrice = (tonumber(itemAmount) * itemPrice)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local dist
    for _, value in pairs(Config.PawnLocation) do
        dist = #(playerCoords - value.coords)
        if #(playerCoords - value.coords) < 2 then
            dist = #(playerCoords - value.coords)
            break
        end
    end
    if dist > 5 then
        exploitBan(src, 'sellPawnItems Exploiting')
        return
    end
    if exports['pradipta-inventory']:RemoveItem(src, itemName, tonumber(itemAmount), false, 'pradipta-pawnshop:server:sellPawnItems') then
        if Config.BankMoney then
            Player.AddMoney('bank', totalPrice, 'pradipta-pawnshop:server:sellPawnItems')
        else
            Player.AddMoney('cash', totalPrice, 'pradipta-pawnshop:server:sellPawnItems')
        end
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.sold', { value = tonumber(itemAmount), value2 = sharedItems[itemName].label, value3 = totalPrice }), 'success')
        TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[itemName], 'remove')
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.no_items'), 'error')
    end
    TriggerClientEvent('pradipta-pawnshop:client:openMenu', src)
end)

RegisterNetEvent('pradipta-pawnshop:server:meltItemRemove', function(itemName, itemAmount, item)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if exports['pradipta-inventory']:RemoveItem(src, itemName, itemAmount, false, 'pradipta-pawnshop:server:meltItemRemove') then
        TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[itemName], 'remove')
        local meltTime = (tonumber(itemAmount) * item.time)
        TriggerClientEvent('pradipta-pawnshop:client:startMelting', src, item, tonumber(itemAmount), (meltTime * 60000 / 1000))
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('info.melt_wait', { value = meltTime }), 'primary')
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.no_items'), 'error')
    end
end)

RegisterNetEvent('pradipta-pawnshop:server:pickupMelted', function(item)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local dist
    for _, value in pairs(Config.PawnLocation) do
        dist = #(playerCoords - value.coords)
        if #(playerCoords - value.coords) < 2 then
            dist = #(playerCoords - value.coords)
            break
        end
    end
    if dist > 5 then
        exploitBan(src, 'pickupMelted Exploiting')
        return
    end
    for _, v in pairs(item.items) do
        local meltedAmount = v.amount
        for _, m in pairs(v.item.reward) do
            local rewardAmount = m.amount
            if exports['pradipta-inventory']:AddItem(src, m.item, (meltedAmount * rewardAmount), false, false, 'pradipta-pawnshop:server:pickupMelted') then
                TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[m.item], 'add')
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.items_received', { value = (meltedAmount * rewardAmount), value2 = sharedItems[m.item].label }), 'success')
                TriggerClientEvent('pradipta-pawnshop:client:resetPickup', src)
            else
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.inventory_full', { value = sharedItems[m.item].label }), 'warning', 7500)
            end
        end
    end
    TriggerClientEvent('pradipta-pawnshop:client:openMenu', src)
end)

PradiptaCore.Functions.CreateCallback('pradipta-pawnshop:server:getInv', function(source, cb)
    local Player = exports['pradipta-core']:GetPlayer(source)
    local inventory = Player.PlayerData.items
    return cb(inventory)
end)
