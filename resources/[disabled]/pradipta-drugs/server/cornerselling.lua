local StolenDrugs = {}

local function getAvailableDrugs(source)
    local AvailableDrugs = {}
    local Player = exports['pradipta-core']:GetPlayer(source)

    if not Player then return nil end

    for k in pairs(Config.DrugsPrice) do
        local item = Player.GetItemByName(k)

        if item then
            AvailableDrugs[#AvailableDrugs + 1] = {
                item = item.name,
                amount = item.amount,
                label = sharedItems[item.name]['label']
            }
        end
    end
    return table.type(AvailableDrugs) ~= 'empty' and AvailableDrugs or nil
end

PradiptaCore.Functions.CreateCallback('pradipta-drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    cb(getAvailableDrugs(source))
end)

RegisterNetEvent('pradipta-drugs:server:giveStealItems', function(drugType, amount)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player or StolenDrugs == {} then return end
    for k, v in pairs(StolenDrugs) do
        if drugType == v.item and amount == v.amount then
            exports['pradipta-inventory']:AddItem(src, drugType, amount, false, false, 'pradipta-drugs:server:giveStealItems')
            table.remove(StolenDrugs, k)
        end
    end
end)

RegisterNetEvent('pradipta-drugs:server:sellCornerDrugs', function(drugType, amount, price)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    local availableDrugs = getAvailableDrugs(src)
    if not availableDrugs or not Player then return end
    local item = availableDrugs[drugType].item
    local hasItem = Player.GetItemByName(item)
    if hasItem.amount >= amount then
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.offer_accepted'), 'success')
        exports['pradipta-inventory']:RemoveItem(src, item, amount, false, 'pradipta-drugs:server:sellCornerDrugs')
        Player.AddMoney('cash', price, 'pradipta-drugs:server:sellCornerDrugs')
        TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'remove')
        TriggerClientEvent('pradipta-drugs:client:refreshAvailableDrugs', src, getAvailableDrugs(src))
    else
        TriggerClientEvent('pradipta-drugs:client:cornerselling', src)
    end
end)

RegisterNetEvent('pradipta-drugs:server:robCornerDrugs', function(drugType, amount)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    local availableDrugs = getAvailableDrugs(src)
    if not availableDrugs or not Player then return end
    local item = availableDrugs[drugType].item
    exports['pradipta-inventory']:RemoveItem(src, item, amount, false, 'pradipta-drugs:server:robCornerDrugs')
    table.insert(StolenDrugs, { item = item, amount = amount })
    TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'remove')
    TriggerClientEvent('pradipta-drugs:client:refreshAvailableDrugs', src, getAvailableDrugs(src))
end)
