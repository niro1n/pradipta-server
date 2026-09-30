local sharedItems = exports['pradipta-core']:GetShared('Items')

function NearTaxi(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for _, v in pairs(Config.NPCLocations.DeliverLocations) do
        local dist = #(coords - vector3(v.x, v.y, v.z))
        if dist < 20 then
            return true
        end
    end
end

RegisterNetEvent('pradipta-taxi:server:NpcPay', function(_, hasReceivedBonus)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if Player.PlayerData.job.name == Config.jobRequired then
        if NearTaxi(src) then
            local payment = math.random(65, 105)
            local randomAmount = math.random(1, 5)
            local r1, r2 = math.random(1, 5), math.random(1, 5)
            if randomAmount == r1 or randomAmount == r2 then payment = payment + math.random(10, 20) end

            if Config.Advanced.Bonus.Enabled then
                local tipAmount = math.floor(payment * Config.Advanced.Bonus.Percentage / 100)

                payment += tipAmount
                if hasReceivedBonus then
                    TriggerClientEvent('PradiptaCore:Notify', src, string.format(Lang:t('info.tip_received'), tipAmount), 'primary', 5000)
                else
                    TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('info.tip_not_received'), 'primary', 5000)
                end
            end

            if Config.Management then
                exports['pradipta-banking']:AddMoney('taxi', payment, 'Customer payment')
            else
                Player.AddMoney('cash', payment, 'Taxi payout')
            end

            local chance = math.random(1, 100)
            if chance < 26 then
                exports['pradipta-inventory']:AddItem(src, Config.Rewards, 1, false, false, 'pradipta-taxi:server:NpcPay')
                TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[Config.Rewards], 'add')
            end
        else
            DropPlayer(src, 'Attempting To Exploit')
        end
    else
        DropPlayer(src, 'Attempting To Exploit')
    end
end)
