local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions' })
local sharedItems = exports['pradipta-core']:GetShared('Items')

-- Functions

local function ResetHouseStateTimer(house)
    CreateThread(function()
        Wait(Config.TimeToCloseDoors * 60000)
        Config.Houses[house]['opened'] = false
        for _, v in pairs(Config.Houses[house]['furniture']) do
            v['searched'] = false
        end
        TriggerClientEvent('pradipta-houserobbery:client:ResetHouseState', -1, house)
    end)
end

-- Callbacks

PradiptaCore.Functions.CreateCallback('pradipta-houserobbery:server:GetHouseConfig', function(_, cb)
    cb(Config.Houses)
end)

-- Events

RegisterNetEvent('pradipta-houserobbery:server:SetBusyState', function(cabin, house, bool)
    Config.Houses[house]['furniture'][cabin]['isBusy'] = bool
    TriggerClientEvent('pradipta-houserobbery:client:SetBusyState', -1, cabin, house, bool)
end)

RegisterNetEvent('pradipta-houserobbery:server:enterHouse', function(house)
    local src = source
    if not Config.Houses[house]['opened'] then
        ResetHouseStateTimer(house)
        TriggerClientEvent('pradipta-houserobbery:client:setHouseState', -1, house, true)
    end
    TriggerClientEvent('pradipta-houserobbery:client:enterHouse', src, house)
    Config.Houses[house]['opened'] = true
end)

RegisterNetEvent('pradipta-houserobbery:server:searchFurniture', function(cabin, house)
    local src = source
    local player = exports['pradipta-core']:GetPlayer(src)

    -- Validate house and cabin exist
    if not Config.Houses[house] or not Config.Houses[house].furniture[cabin] then return end

    -- Validate the house is currently opened (player entered legitimately)
    if not Config.Houses[house]['opened'] then return end

    -- Prevent re-searching the same furniture piece
    if Config.Houses[house]['furniture'][cabin]['searched'] then return end

    -- Proximity check: player must be near the house coords
    local houseCoords = Config.Houses[house]['coords']
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(houseCoords.x, houseCoords.y, houseCoords.z)) > Config.MinZOffset then return end

    local tier = Config.Houses[house].tier
    local availableItems = Config.Rewards[tier][Config.Houses[house].furniture[cabin].type]
    local itemCount = math.random(0, 3)
    if itemCount > 0 then
        for _ = 1, itemCount do
            local selectedItem = availableItems[math.random(1, #availableItems)]
            local itemInfo = sharedItems[selectedItem.item]

            if not itemInfo.unique then
                local amount = math.random(selectedItem.min, selectedItem.max)
                exports['pradipta-inventory']:AddItem(src, selectedItem.item, amount, false, false, 'pradipta-houserobbery:server:searchFurniture')
            else
                exports['pradipta-inventory']:AddItem(src, selectedItem.item, 1, false, false, 'pradipta-houserobbery:server:searchFurniture')
            end
            TriggerClientEvent('pradipta-inventory:client:ItemBox', src, itemInfo, 'add')
            Wait(500)
        end
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.emty_box'), 'error')
    end
    Config.Houses[house]['furniture'][cabin]['searched'] = true
    TriggerClientEvent('pradipta-houserobbery:client:setCabinState', -1, house, cabin, true)
end)

RegisterNetEvent('pradipta-houserobbery:server:removeAdvancedLockpick', function()
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then return end
    exports['pradipta-inventory']:RemoveItem(source, 'advancedlockpick', 1, false, 'pradipta-houserobbery:server:removeAdvancedLockpick')
end)

RegisterNetEvent('pradipta-houserobbery:server:removeLockpick', function()
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then return end
    exports['pradipta-inventory']:RemoveItem(source, 'lockpick', 1, false, 'pradipta-houserobbery:server:removeLockpick')
end)
