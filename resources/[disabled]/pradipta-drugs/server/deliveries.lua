PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions', 'Commands' })
sharedItems = exports['pradipta-core']:GetShared('Items')

-- Functions
exports('GetDealers', function()
    return Config.Dealers
end)

-- Callbacks
PradiptaCore.Functions.CreateCallback('pradipta-drugs:server:RequestConfig', function(_, cb)
    cb(Config.Dealers)
end)

-- Events
RegisterNetEvent('pradipta-drugs:server:updateDealerItems', function(itemData, amount, dealer)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    if Config.Dealers[dealer]['products'][itemData.slot].amount - 1 >= 0 then
        Config.Dealers[dealer]['products'][itemData.slot].amount = Config.Dealers[dealer]['products'][itemData.slot].amount - amount
        TriggerClientEvent('pradipta-drugs:client:setDealerItems', -1, itemData, amount, dealer)
    else
        exports['pradipta-inventory']:RemoveItem(src, itemData.name, amount, false, 'pradipta-drugs:server:updateDealerItems')
        Player.AddMoney('cash', amount * Config.Dealers[dealer]['products'][itemData.slot].price, 'pradipta-drugs:server:updateDealerItems')
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.item_unavailable'), 'error')
    end
end)

RegisterNetEvent('pradipta-drugs:server:giveDeliveryItems', function(deliveryData)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    local item = Config.DeliveryItems[deliveryData.item].item
    if not item then return end
    exports['pradipta-inventory']:AddItem(src, item, deliveryData.amount, false, false, 'pradipta-drugs:server:giveDeliveryItems')
    TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'add')
end)

RegisterNetEvent('pradipta-drugs:server:successDelivery', function(deliveryData, inTime)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    local item = Config.DeliveryItems[deliveryData.item].item
    local itemAmount = deliveryData.amount
    local payout = deliveryData.itemData.payout * itemAmount
    local copsOnline = PradiptaCore.Functions.GetDutyCount('police')
    local invItem = Player.GetItemByName(item)
    if inTime then
        if invItem and invItem.amount >= itemAmount then -- on time correct amount
            exports['pradipta-inventory']:RemoveItem(src, item, itemAmount, false, 'pradipta-drugs:server:successDelivery')
            if copsOnline > 0 then
                local copModifier = copsOnline * Config.PoliceDeliveryModifier
                if Config.UseMarkedBills then
                    local info = { worth = math.floor(payout * copModifier) }
                    exports['pradipta-inventory']:AddItem(src, 'markedbills', 1, false, info, 'pradipta-drugs:server:successDelivery')
                else
                    Player.AddMoney('cash', math.floor(payout * copModifier), 'pradipta-drugs:server:successDelivery')
                end
            else
                if Config.UseMarkedBills then
                    local info = { worth = payout }
                    exports['pradipta-inventory']:AddItem(src, 'markedbills', 1, false, info, 'pradipta-drugs:server:successDelivery')
                else
                    Player.AddMoney('cash', payout, 'pradipta-drugs:server:successDelivery')
                end
            end
            TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'remove')
            TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.order_delivered'), 'success')
            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('pradipta-drugs:client:sendDeliveryMail', src, 'perfect', deliveryData)
                Player.AddRep('dealer', Config.DeliveryRepGain)
            end)
        else
            TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.order_not_right'), 'error') -- on time incorrect amount
            if invItem then
                local newItemAmount = invItem.amount
                local modifiedPayout = deliveryData.itemData.payout * newItemAmount
                exports['pradipta-inventory']:RemoveItem(src, item, newItemAmount, false, 'pradipta-drugs:server:successDelivery')
                TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'remove')
                Player.AddMoney('cash', math.floor(modifiedPayout / Config.WrongAmountFee), 'pradipta-drugs:server:successDelivery')
            end
            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('pradipta-drugs:client:sendDeliveryMail', src, 'bad', deliveryData)
                Player.RemoveRep('dealer', Config.DeliveryRepLoss)
            end)
        end
    else
        if invItem and invItem.amount >= itemAmount then -- late correct amount
            TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.too_late'), 'error')
            exports['pradipta-inventory']:RemoveItem(src, item, itemAmount, false, 'pradipta-drugs:server:successDelivery')
            Player.AddMoney('cash', math.floor(payout / Config.OverdueDeliveryFee), 'pradipta-drugs:server:successDelivery')
            TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'remove')
            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('pradipta-drugs:client:sendDeliveryMail', src, 'late', deliveryData)
                Player.RemoveRep('dealer', Config.DeliveryRepLoss)
            end)
        else
            if invItem then -- late incorrect amount
                local newItemAmount = invItem.amount
                local modifiedPayout = deliveryData.itemData.payout * newItemAmount
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.too_late'), 'error')
                exports['pradipta-inventory']:RemoveItem(src, item, itemAmount, false, 'pradipta-drugs:server:successDelivery')
                Player.AddMoney('cash', math.floor(modifiedPayout / Config.OverdueDeliveryFee), 'pradipta-drugs:server:successDelivery')
                TriggerClientEvent('pradipta-inventory:client:ItemBox', src, sharedItems[item], 'remove')
                SetTimeout(math.random(5000, 10000), function()
                    TriggerClientEvent('pradipta-drugs:client:sendDeliveryMail', src, 'late', deliveryData)
                    Player.RemoveRep('dealer', Config.DeliveryRepLoss)
                end)
            end
        end
    end
end)

RegisterNetEvent('pradipta-drugs:server:dealerShop', function(currentDealer)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local dealerData = Config.Dealers[currentDealer]
    if not dealerData then return end
    local dist = #(playerCoords - vector3(dealerData.coords.x, dealerData.coords.y, dealerData.coords.z))
    if dist > 5.0 then return end
    local curRep = Player.GetRep('dealer')
    local repItems = {}
    for k in pairs(dealerData.products) do
        if curRep >= dealerData['products'][k].minrep then
            repItems[#repItems + 1] = dealerData['products'][k]
        end
    end
    exports['pradipta-inventory']:CreateShop({
        name = dealerData.name,
        label = dealerData.name,
        slots = #repItems,
        coords = dealerData.coords,
        items = repItems,
    })
    exports['pradipta-inventory']:OpenShop(src, dealerData.name)
end)

-- Commands

PradiptaCore.Commands.Add('newdealer', Lang:t('info.newdealer_command_desc'), { {
    name = Lang:t('info.newdealer_command_help1_name'),
    help = Lang:t('info.newdealer_command_help1_help')
}, {
    name = Lang:t('info.newdealer_command_help2_name'),
    help = Lang:t('info.newdealer_command_help2_help')
}, {
    name = Lang:t('info.newdealer_command_help3_name'),
    help = Lang:t('info.newdealer_command_help3_help')
} }, true, function(source, args)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then return end
    local dealerName = args[1]
    local minTime = tonumber(args[2])
    local maxTime = tonumber(args[3])
    local time = json.encode({ min = minTime, max = maxTime })
    local pos = json.encode({ x = coords.x, y = coords.y, z = coords.z })
    local result = MySQL.scalar.await('SELECT name FROM dealers WHERE name = ?', { dealerName })
    if result then return TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.dealer_already_exists'), 'error') end
    MySQL.insert('INSERT INTO dealers (name, coords, time, createdby) VALUES (?, ?, ?, ?)', { dealerName, pos, time, Player.PlayerData.citizenid }, function()
        Config.Dealers[dealerName] = {
            ['name'] = dealerName,
            ['coords'] = {
                ['x'] = coords.x,
                ['y'] = coords.y,
                ['z'] = coords.z
            },
            ['time'] = {
                ['min'] = minTime,
                ['max'] = maxTime
            },
            ['products'] = Config.Products
        }
        TriggerClientEvent('pradipta-drugs:client:RefreshDealers', -1, Config.Dealers)
    end)
end, 'admin')

PradiptaCore.Commands.Add('deletedealer', Lang:t('info.deletedealer_command_desc'), { {
    name = Lang:t('info.deletedealer_command_help1_name'),
    help = Lang:t('info.deletedealer_command_help1_help')
} }, true, function(source, args)
    local dealerName = args[1]
    local result = MySQL.scalar.await('SELECT * FROM dealers WHERE name = ?', { dealerName })
    if result then
        MySQL.query('DELETE FROM dealers WHERE name = ?', { dealerName })
        Config.Dealers[dealerName] = nil
        TriggerClientEvent('pradipta-drugs:client:RefreshDealers', -1, Config.Dealers)
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('success.dealer_deleted', { dealerName = dealerName }), 'success')
    else
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.dealer_not_exists_command', { dealerName = dealerName }), 'error')
    end
end, 'admin')

PradiptaCore.Commands.Add('dealers', Lang:t('info.dealers_command_desc'), {}, false, function(source, _)
    local DealersText = ''
    if Config.Dealers ~= nil and next(Config.Dealers) ~= nil then
        for _, v in pairs(Config.Dealers) do
            DealersText = DealersText .. Lang:t('info.list_dealers_name_prefix') .. v['name'] .. '<br>'
        end
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>' .. Lang:t('info.list_dealers_title') .. '</strong><br><br> ' .. DealersText .. '</div></div>',
            args = {}
        })
    else
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.no_dealers'), 'error')
    end
end, 'admin')

PradiptaCore.Commands.Add('dealergoto', Lang:t('info.dealergoto_command_desc'), { {
    name = Lang:t('info.dealergoto_command_help1_name'),
    help = Lang:t('info.dealergoto_command_help1_help')
} }, true, function(source, args)
    local DealerName = tostring(args[1])
    if Config.Dealers[DealerName] then
        local ped = GetPlayerPed(source)
        SetEntityCoords(ped, Config.Dealers[DealerName]['coords']['x'], Config.Dealers[DealerName]['coords']['y'], Config.Dealers[DealerName]['coords']['z'])
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('success.teleported_to_dealer', { dealerName = DealerName }), 'success')
    else
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.dealer_not_exists'), 'error')
    end
end, 'admin')

CreateThread(function()
    Wait(500)
    local dealers = MySQL.query.await('SELECT * FROM dealers', {})
    if dealers[1] then
        for _, v in pairs(dealers) do
            local coords = json.decode(v.coords)
            local time = json.decode(v.time)

            Config.Dealers[v.name] = {
                ['name'] = v.name,
                ['coords'] = {
                    ['x'] = coords.x,
                    ['y'] = coords.y,
                    ['z'] = coords.z
                },
                ['time'] = {
                    ['min'] = time.min,
                    ['max'] = time.max
                },
                ['products'] = Config.Products
            }
        end
    end
    TriggerClientEvent('pradipta-drugs:client:RefreshDealers', -1, Config.Dealers)
end)
