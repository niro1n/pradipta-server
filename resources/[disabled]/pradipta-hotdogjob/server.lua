local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions', 'Commands' })
local Bail = {}

-- Callbacks

PradiptaCore.Functions.CreateCallback('pradipta-hotdogjob:server:HasMoney', function(source, cb)
    local Player = exports['pradipta-core']:GetPlayer(source)

    if Player.PlayerData.money.bank >= Config.StandDeposit then
        Player.RemoveMoney('bank', Config.StandDeposit, 'hot dog deposit')
        Bail[Player.PlayerData.citizenid] = true
        cb(true)
    else
        Bail[Player.PlayerData.citizenid] = false
        cb(false)
    end
end)

PradiptaCore.Functions.CreateCallback('pradipta-hotdogjob:server:BringBack', function(source, cb)
    local Player = exports['pradipta-core']:GetPlayer(source)

    if Bail[Player.PlayerData.citizenid] then
        Player.AddMoney('bank', Config.StandDeposit, 'hot dog deposit')
        cb(true)
    else
        cb(false)
    end
end)

-- Events

RegisterNetEvent('pradipta-hotdogjob:server:Sell', function(coords, amount, price)
    local src = source
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    if #(pCoords - coords) > 4 then exports['pradipta-core']:ExploitBan(src, 'hotdog job') end

    local sellAmount = math.floor(tonumber(amount) or 0)
    local sellPrice = tonumber(price) or 0
    if sellAmount <= 0 or sellPrice <= 0 then return end

    local hotdogItem = Player.Functions.GetItemByName('hotdog')
    if not hotdogItem or not hotdogItem.amount or hotdogItem.amount < sellAmount then return end

    local removed = Player.Functions.RemoveItem('hotdog', sellAmount)
    if not removed then return end

    Player.AddMoney('cash', sellAmount * sellPrice, 'sold hotdog')
end)

RegisterNetEvent('pradipta-hotdogjob:server:UpdateReputation', function(quality)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if quality == 'exotic' then
        if Player.GetRep('hotdog') + 3 > Config.MaxReputation then
            Player.AddRep('hotdog', Config.MaxReputation - Player.GetRep('hotdog'))
        else
            Player.AddRep('hotdog', 3)
        end
    elseif quality == 'rare' then
        if Player.GetRep('hotdog') + 2 > Config.MaxReputation then
            Player.AddRep('hotdog', Config.MaxReputation - Player.GetRep('hotdog'))
        else
            Player.AddRep('hotdog', 2)
        end
    elseif quality == 'common' then
        if Player.GetRep('hotdog') + 1 > Config.MaxReputation then
            Player.AddRep('hotdog', Config.MaxReputation - Player.GetRep('hotdog'))
        else
            Player.AddRep('hotdog', 1)
        end
    end

    TriggerClientEvent('pradipta-hotdogjob:client:UpdateReputation', src, Player.PlayerData.metadata['rep'])
end)

-- Commands

PradiptaCore.Commands.Add('removestand', Lang:t('info.command'), {}, false, function(source, _)
    TriggerClientEvent('pradipta-hotdogjob:staff:DeletStand', source)
end, 'admin')
